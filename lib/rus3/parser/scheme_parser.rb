# frozen_string_literal: true

module Rus3

  module Parser

    # A simple parser to read a s-expression for Scheme.
    class SchemeParser < Parser

      # Indicates the version of the parser class
      PARSER_VERSION = "0.2.0"

      # Constructs the version string.

      def version
        vmsg = "(scheme-parser :version #{PARSER_VERSION})"
        vmsg += " #{Lexer.version}"
        super + " (#{vmsg})"
      end

      def initialize
        super
        @lexer = nil
        @curr_token = @peek_token = nil
      end

      # Parses a portion of or the whole program source then returns a
      # AST structure.

      def parse(program_source)
        @lexer = Lexer.new(program_source)
        parse_program
      end

      # :stopdoc:

      private

      def next_token
        if @peek_token
          @curr_token = @peek_token
          @peek_token = nil
        else
          @curr_token = @lexer.next
        end
        @curr_token
      end

      def peek_token
        if @peek_token.nil?
          @peek_token = @lexer.next
        end
        @peek_token
      end

      def current_token
        @curr_token
      end

      def push_back_token(token)
        @peek_token = token
      end

      # <program> -> <expression>*
      def parse_program
        program = Rus3::AST.instantiate(:program)
        Kernel.loop {
          node = parse_expression
          program << node
        }
        program
      end

      TOKEN_START_DELIMITERS = [  # :nodoc:
        :lparen,                  # list: ( ... )
        :vec_lparen,              # vector: #( ... )
        :bytevec_lparen,          # bytevector: #u8( ... )
        :quotation,               # quotation: '<something>
        :backquote,               # quasiquote: `<something>
        :comma,                   # used in quasiquote
        :comma_at,                # used in quasiquote
        :comment_lparen,          # comment start
      ]

      def start_delimiter?(token)
        TOKEN_START_DELIMITERS.include?(token.type)
      end

      # <expression> -> <simple expression> | <compound expression>
      # <compound expression> -> <start delimiter> <expression>* <end delimiter>
      # <start delimiter> -> <lparen> | <vec lparen> | <bytevec lparen> |
      #   <quotation> |
      #   <backquote> | <comma> | <comma at> |
      #   <comment lparen>
      # <end delimier> -> <rparen> | <comment_rparen>
      def parse_expression
        if start_delimiter?(peek_token)
          parse_compound_expression
        else
          parse_simple_expression
        end
      end

      # <simple expression> -> <identifier> | <self evaluating>
      # <self evaluating> -> <boolean> | <number> | <character> | <string>
      def parse_simple_expression
        type, literal = *next_token
        type = :peculiar_identifier if type == :op_proc
        Rus3::AST.instantiate(type, literal)
      end

      def parse_identifier
        Rus3::AST.instantiate(:identifier, next_token.literal)
      end

      # <compound expression> -> <quotation> |
      #   <vector> |
      #   <list expression>
      def parse_compound_expression
        node = nil
        token = peek_token
        case token.type
        when :vec_lparen
          node = parse_vector
        when :lparen
          node = parse_list_expression
        when :quotation
          node = parse_quotation
        else
          raise Rus3::SchemeSynaxError, token.to_a
        end
        node
      end

      # <list expression> ->
      #   <procedure call> |
      #   <lambda expression> |
      #   <conditional> |
      #   <assignment> |
      #   <macro use> |
      #   <macro block> |
      #   <definition> |
      #   <derived expression> |
      #   <includer>
      def parse_list_expression
        node = nil
        next_token        # read :lparen
        case peek_token.type
        when :rparen
          # an empty list
          node = Rus3::AST.instantiate(:list)
          next_token            # skip :rparen
        when :identifier
          case peek_token.literal
          when "lambda"           # lambda expression
            node = parse_lambda_expression
          when "if"               # conditional
            node = parse_conditional
          when "set!"             # assignment
            node = parse_assignment
          when "let-syntax", "letrec-syntax" # macro block
            node = parse_macro_block
          when "define", "define-syntax", "define-values", "define-record-type", "begin"
            node = parse_definition
          else
            node = parse_derived_expression
            node = parse_macro_use if node.nil?
          end
        end
        node || parse_procedure_call
      end

      def parse_macro_use
        nil
      end

      # <procedure call> -> ( <operator> <operand>* )
      def parse_procedure_call
        proc_call_node = Rus3::AST.instantiate(:procedure_call,
                                               current_token.literal)
        proc_call_node.operator = parse_operator

        Kernel.loop {
          if peek_token.type == :rparen
            next_token            # skip :rparen
            break
          end
          proc_call_node.add_operand(parse_operand)
        }
        proc_call_node
      end

      # <operator> -> <expression>
      def parse_operator
        parse_expression
      end

      # <operand> -> <expression>
      def parse_operand
        parse_expression
      end

      # <lambda expression> -> ( lambda <formals> <body> )
      # <sequence> -> <command>* <expression>
      # <command> -> <expression>
      # <definition> ... see parse_definition
      def parse_lambda_expression
        lambda_node = Rus3::AST.instantiate(:lambda_expression,
                                            next_token.literal)
        lambda_node.formals = parse_formals
        lambda_node.body = read_body
        next_token            # skip :rparen
        lambda_node
      end

      # <formals> -> ( <identifier>* ) | <identifier> |
      #   ( <identifier>+ . <identifier> )
      def parse_formals
        token = next_token
        formals = nil
        if token.type == :lparen
          formals = Rus3::AST.instantiate(:list)
          Kernel.loop {
            if peek_token.type == :rparen
              next_token
              break
            end
            formals << Rus3::AST.instantiate(:identifier, next_token.literal)
          }
        else
          formals = Rus3::AST.instantiate(:identifier, token.literal)
        end
        formals
      end

      # <body> -> <definition>* <sequence>
      def read_body
        body = []
        Kernel.loop {
          break if peek_token.type == :rparen # end of <lambda expression>
          body << parse_expression
        }
        body
      end

      # <conditional> -> ( if <test> <consequent> <alternamte> )
      def parse_conditional
        cond_node = Rus3::AST.instantiate(:conditional, next_token.literal)
        cond_node.test = parse_test
        cond_node.consequent = parse_consequent
        if peek_token.type != :rparen
          cond_node.alternate = parse_alternate
        end
        next_token              # skip :rparen
        cond_node
      end

      # <test> -> <expression>
      def parse_test
        parse_expression
      end

      # <consequent> -> <expression>
      def parse_consequent
        parse_expression
      end

      # <alternate> -> <expression> | <empty>
      # <empty> -> ""
      def parse_alternate
        parse_expression
      end

      # <assignment> -> ( set! <identifier> <expression> )
      def parse_assignment
        assignment_node = Rus3::AST.instantiate(:assignment, next_token.literal)
        assignment_node.identifier = parse_identifier
        assignment_node.expression = parse_expression
        next_token              # skip :rparen
        assignment_node
      end

      def parse_macro_block
        nil
      end

      # <definition> -> ( define <identifier> <expression> ) |
      #   ( define ( <identifier> <def formals> ) <body> ) |
      #   <syntax definition> |
      #   ( define-values <formals> <body> ) |
      #   ( define-record-type <identifier>
      #                        <constructor> <identifier> <field spec>* ) |
      #   ( begin <definition>* )
      #
      # <def formals> -> <identifier>* |
      #   <identifier>* . <identifier>
      # <constructor> -> ( <identifier> <field name>* )
      # <field spec> -> ( <field name> <accessor> ) |
      #   ( <field name> <accessor> <mutator> )
      # <field name> -> <identifier>
      # <accessor> -> <identifier>
      # <mutator> -> <identifier>
      # <syntax definition> -> ( define-syntax <keyword> <transformer spec> )
      # <transformer spec> -> ...
      #  :
      def parse_definition
        case peek_token.literal
        when "define"
          parse_identifier_definition
        when "define-syntax"
          nil                   # not implemented yet
        when "define-values"
          nil                   # not implemented yet
        when "define-record-type"
          nil                   # not implemented yet
        when "begin"
          nil                   # not implemented yet
        else
          raise Rus3::SchemeSynaxError, token.to_a
        end
      end

      # ( define <identifier> <expression> )
      # ( define ( <identifier> <def formals> ) <body> )
      #
      #   ( define foo 3 )
      #   ( define bar ( lambda ( x y ) ( + x y )))
      #   ( deifne ( hoge n m ) ( * n m ))

      def parse_identifier_definition
        token = next_token      # define
        define_node = Rus3::AST.instantiate(:identifier_definition, token.literal)
        case peek_token.type
        when :lparen
          next_token            # skip :lparen
          # procedure name
          define_node.identifier = parse_identifier

          def_formals = Rus3::AST.instantiate(:list)
          Kernel.loop {
            if peek_token.type == :rparen
              next_token
              break
            end
            def_formals << parse_identifier
          }

          lambda_node = Rus3::AST.instantiate(:lambda_expression, nil)
          lambda_node.formals = def_formals
          lambda_node.body = read_body
          next_token            # skip :rparen

          define_node.expression = lambda_node
        when :identifier
          define_node.identifier = parse_identifier
          define_node.expression = parse_expression
          next_token
        else
          raise Rus3::SchemeSynaxError, current_token.to_a
        end
        define_node
      end

      # <quotation> -> '<datum> | ( quote <datum> )
      def parse_quotation
        token = next_token
        quote_node = Rus3::AST.instantiate(:quotation, token.literal)
        quote_node << parse_datum
        quote_node
      end

      # <vetor> -> #( <datum>* )
      def parse_vector
        parse_data_to_rparen
      end

      def parse_data_to_rparen
        token = next_token
        ast_type = nil
        case token.type
        when :lparen
          ast_type = :list
        when :vec_lparen
          ast_type = :vector
        else
          ast_type = :list
        end
        node = Rus3::AST.instantiate(ast_type, nil)
        raise Rus3::SchemeSyntaxError, token.to_a unless node.branch?
        Kernel.loop {
          token = peek_token
          break if token.type == :rparen
          node << parse_datum
        }
        next_token                # skip :rparen
        node
      end

      # <datum> -> <simple datum> | <compound datum>
      def parse_datum
        if start_delimiter?(peek_token)
          parse_compound_datum
        else
          parse_simple_datum
        end
      end

      # <simple datum> -> <boolean> | <number> | <character> |
      #     <string> | <symbol>
      # <symbol> -> <identifier>
      #
      # See `parse_simple_expression`.
      def parse_simple_datum
        parse_simple_expression
      end

      # <compound datum> -> <list> | <vector> | <bytevector> | <abbreviation>
      # <abbreviation> -> <abbrev prefix> <datum>
      def parse_compound_datum
        case peek_token.type
        when :lparen
          parse_list
        when :vec_lparen
          parse_vector
        else
          raise Rus3::SchemeSyntaxError, peek_token.to_a
        end
      end

      # <list> -> ( <datum>* ) | ( <datum>+ . <datum> )
      def parse_list
        parse_data_to_rparen
      end

      DERIVED_IDENTIFIERS = [
        "cond", "case", "and", "or", "when", "unless",
        "let", "let*", "letrec", "letrec*",
        "let-values", "let*-values",
        "begin", "do",
        "delay", "delay-force",
        "parameterize",
        "guard",
        "case-lambda",
      ]

      # <derived expression> ->
      #   ( cond <cond clause>+ ) |
      #   ( cond <cond cluase>* ( else <sequence> ) ) |
      #   ( case <expression> <case caluse>+ ) |
      #   ( case <expression> <case caluse>* ( else <sequence> ) ) |
      #   ( case <expression> <case caluse>* ( else => <recipient> ) ) |
      #   ( and <test>* ) |
      #   ( or <test>* ) |
      #   ( when <test> <sequence> ) |
      #   ( unless <test> <sequence> ) |
      #   ( let ( <binding spec>* ) <body> ) |
      #   ( let* ( <binding spec>* ) <body> ) |
      #   ( letrec ( <binding spec>* ) <body> ) |
      #   ( letrec* ( <binding spec>* ) <body> ) |
      #   ( let-values ( <my binding spec>* ) <body> ) |
      #   ( let*-values ( <my binding spec>* ) <body> ) |
      #   ( begin <sequence> ) |
      #   ( do ( <iteration spec>* ) ( <test> <do result> ) <command>* ) |
      #   ( delay <expression> ) |
      #   ( delay-force <expression> ) |
      #   ( parameterize ( ( <expression> <expression> )* ) <body> ) |
      #   ( guard ( <identifier> <cond clause>* ) <body> ) |
      #   ( case-lambda <case-lambda clause>* ) |
      #   <quasiquotation>
      def parse_derived_expression
        node = nil
        token = next_token
        if token.type == :identifier
          if DERIVED_IDENTIFIERS.include?(token.literal)
            method_name = compose_method_name("parse_", token.literal).intern
            method = self.method(method_name)
            node = method.call
          else
            node = parse_quasiquotation
          end
        end
        push_back_token(token) if node.nil?
        node
      end

      SCM_CHAR_TO_RB_MAP = {
        "*" => "_star",
        "-" => "_",
      }

      def compose_method_name(prefix, type_name)
        converted_name = type_name.gsub(/[*\-]/, SCM_CHAR_TO_RB_MAP)
        prefix + converted_name
      end

      def not_implemented_yet(feature)
        raise Rus3::NotImplementedYetError, feature
      end

      # ( cond <cond clause>+ )
      # ( cond <cond cluase>* ( else <sequence> ) )
      def parse_cond
        cond_node = Rus3::AST.instantiate(:cond, current_token.literal)
        next_token              # skip "cond"

        Kernel.loop {
          if peek_token.type == :rparen
            next_token          # skip :rparen
            break
          end
          cond_node.add_clause(parse_cond_clause)
        }
        cond_node
      end

      # <cond cluase> -> ( <test> <sequence> ) |
      #   ( <test> ) |
      #   ( <test> => <recipient> )
      # <test> -> <expression>
      # <recipient> -> <expression>
      # <sequence> -> <command>* <expression>
      # <command> -> <expression>
      def parse_cond_clause
        clause_node = Rus3::AST.instantiate(:list)

        test_node = parse_test
        clause_node << test_node

        Kernel.loop {
          if peek_token.type == :rparen
            next_token
            break
          end
          clause_node << parse_expression
        }
        clause_node
      end

      def prase_test
        parse_expression
      end

      def parse_case
        not_implemented_yet("case")
      end

      def parse_and
        not_implemented_yet("and")
      end

      def parse_or
        not_implemented_yet("or")
      end

      def parse_when
        not_implemented_yet("when")
      end

      def parse_unless
        not_implemented_yet("unless")
      end

      def parse_let
        not_implemented_yet("let")
      end

      def parse_let_star
        not_implemented_yet("let*")
      end

      def parse_letrec
        not_implemented_yet("letrec")
      end

      def parse_letrec_star
        not_implemented_yet("letrec*")
      end

      def parse_let_values
        not_implemented_yet("let-values")
      end

      def parse_let_star_values
        not_implemented_yet("let*-values")
      end

      def parse_begin
        not_implemented_yet("begin")
      end

      def parse_do
        not_implemented_yet("do")
      end

      def parse_delay
        not_implemented_yet("delay")
      end

      def parse_delay_force
        not_implemented_yet("delay-force")
      end

      def parse_parameterize
        not_implemented_yet("parameterize")
      end

      def parse_guard
        not_implemented_yet("guard")
      end

      def parse_case_lambda
        not_implemented_yet("case-lambda")
      end

      def parse_quasiquotation
        nil
      end

      # :startdoc:

    end
  end
end
