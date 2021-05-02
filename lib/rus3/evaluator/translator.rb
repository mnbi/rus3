# frozen_string_literal: true

module Rus3

  module Evaluator

    # A class to translate an i-exp to r-exp.

    class Translator
      TRANSLATOR_VERSION = "0.1.0"

      def version
        "(scheme-ruby-translator :version #{TRANSLATOR_VERSION})"
      end

      def initialize
        @verbose = false
        @procedure_map = {}
      end

      def verbose=(verbose)
        @verbose = verbose
      end

      def add_procedure_map(map)
        @procedure_map.merge!(map)
      end

      # Translates an AST node into Ruby code.

      def translate(ast_node)
        return nil if ast_node.nil?

        if @verbose
          print "- translater ==> "
          pp ast_node
        end

        method_name = "translate_#{ast_node.type}".intern
        begin
          m = method(method_name)
        rescue
          raise SchemeSyntaxError.new([ast_node.type, ast_node.to_s])
        end
        m.call(ast_node)
      end

      # :stopdoc:

      private

      def translate_boolean(ast_node)
        case ast_node.literal[0..1]
        when "#f"
          "false"
        when "#t"
          "true"
        else
          raise SchemeSyntaxError.new([:boolean, ast_node.to_s])
        end
      end

      def translate_identifier(ast_node)
        replace_extended_char(ast_node.literal)
      end

      def translate_character(ast_node)
        character = ast_node.literal[2..-1]
        case character
        when "space"
          character = " "
        when "newline"
          character = "\n"
        end
        "Char.new(\"#{character}\")"
      end

      def translate_string(ast_node)
        "#{ast_node.literal}"
      end

      def translate_number(ast_node)
        converter = nil
        case ast_node.literal
        when /\A0\Z/
          converter = "Integer"
        when /\A[+-]?[1-9][0-9]*\Z/ # 123
          converter = "Integer"
        when /\A[+-]?([0-9]?|[1-9][0-9]*)\.[0-9]+\Z/ # 0.123 or 123.456
          converter = "Float"
        when /\A[+-]?[0-9]+\/[1-9][0-9]*\Z/ # 1/2
          converter = "Rational"
        else
          converter = "Complex"
        end
        "#{converter}(\"#{ast_node.literal}\")"
      end

      def translate_peculiar_identifier(ast_node)
        op_literal = ast_node.literal == "=" ? "==" : ast_node.literal
        sym = SchemeEvaluator::INFIX_OPS_MAP[op_literal]
        sym.to_s
      end

      def translate_list(ast_node)
        elements = ast_node.map{|e| translate(e)}.join(", ")
        "[#{elements}]"
      end

      def translate_vector(ast_node)
        obj_src = ast_node.map{|e| translate(e)}.join(", ")
        "vector(#{obj_src})"
      end

      def translate_procedure_call(ast_node)
        operands = ast_node.operands.map{|e| translate(e)}.join(", ")
        operator = translate(ast_node.operator)
        if ast_node.operator.type == :lambda_expression
          "#{operator}.call(#{operands})"
        else
          "#{operator}(#{operands})"
        end
      end

      def translate_lambda_expression(ast_node)
        formals = translate_formals(ast_node)
        body = translate_body(ast_node)
        "lambda{|#{formals}| #{body}}"
      end

      def translate_formals(ast_node)
        ast_node.formals.map{|node| translate_identifier(node)}.join(", ")
      end

      def translate_body(ast_node)
        ast_node.body.map{|node| translate(node)}.join("; ")
      end

      def translate_conditional(ast_node)
        test = translate(ast_node.test)
        consequent = translate(ast_node.consequent)
        alternate = translate(ast_node.alternate)
        rb_src = "if #{test}; #{consequent}"
        if alternate
          rb_src += "; else; #{alternate}"
        end
        rb_src += "; end"
        rb_src
      end

      def translate_assignment(ast_node)
        identifier = translate_identifier(ast_node.identifier)
        expression = translate(ast_node.expression)
        "#{identifier} = #{expression}"
      end

      def translate_quotation(ast_node)
        propagate_quotation(ast_node[1])
      end

      def propagate_quotation(ast_node)
        case ast_node.type
        when :list, :procedure_call, :lambda_expression, :conditional, :assignment
          elements = ast_node.map{|child| propagate_quotation(child)}
          "[" + elements.join(", ") + "]"
        when :vector
          elements = ast_node.map{|child| propagate_quotation(child)}
          "vector(" + elements.join(", ")  + ")"
        when :boolean, :character, :string
          translate(ast_node)
        when :number
          ast_node.to_s
        when :identifier, :peculiar_identifier
          ":#{ast_node.to_s}"
        else
          raise SchemeSyntaxError.new([ast_node.type, ast_node.to_s])
        end
      end

      def translate_identifier_definition(ast_node)
        name = translate_identifier(ast_node.identifier)
        if ast_node.expression.type == :lambda_expression
          def_formals = translate_formals(ast_node.expression)
          body = translate_body(ast_node.expression)
          "def #{name}(#{def_formals}); #{body}; end"
        else
          rb_value = translate(ast_node.expression)
          "#{name} = #{rb_value}"
        end
      end

      def translate_cond(ast_node)
        test_and_exps = ast_node.cond_clauses.map{|e| translate(e)}

        first = intermediate = last = nil

        first = test_and_exps[0]

        if test_and_exps.size > 1
          last = test_and_exps[-1]
        end

        if test_and_exps.size > 2
          intermediate = test_and_exps[1..-2]
        end

        rb_src = []
        rb_src << "if #{first}"

        if intermediate
          rb_src.concat(intermediate.map{|e| " elsif #{e}"})
        end

        if last
          if /\Aelse/ === last
            rb_src << last
          else
            rb_src << " elsif #{last}"
          end
        end

        rb_src.join(";") + "; end"
      end

      def translate_cond_clause(ast_node)
        test_src = translate(ast_node.test)
        exps_src = ast_node.sequence.map{|e| translate(e)}.join(";")
        "#{test_src}; #{exps_src}"
      end

      def translate_let(ast_node)
        formals = []
        args = []

        ast_node.bind_specs.each { |spec|
          formals << translate_identifier(spec.identifier)
          args << translate(spec.expression)
        }

        body = translate_body(ast_node)

        "lambda{|#{formals.join(', ')}| #{body}}.call(#{args.join(', ')})"
      end

      RB_KEYWORDS_MAP = {
        "BEGIN"    => nil,
        "END"      => nil,
        "alias"    => nil,
        "and"      => nil,
        "begin"    => nil,
        "break"    => nil,
        "case"     => nil,
        "class"    => nil,
        "def"      => nil,
        "defined?" => nil,
        "do"       => nil,
        "else"     => nil,
        "elsif"    => nil,
        "end"      => nil,
        "ensure"   => nil,
        "false"    => nil,
        "for"      => nil,
        "if"       => nil,
        "in"       => nil,
        "module"   => nil,
        "next"     => nil,
        "nil"      => nil,
        "not"      => nil,
        "or"       => nil,
        "redo"     => nil,
        "rescue"   => nil,
        "retry"    => nil,
        "return"   => nil,
        "self"     => nil,
        "super"    => nil,
        "then"     => nil,
        "true"     => nil,
        "undef"    => nil,
        "unless"   => nil,
        "until"    => nil,
        "when"     => nil,
        "while"    => nil,
        "yield"    => nil,
        "__LINE__" => nil,
        "__FILE__" => nil,
        "__ENCODING__" => nil,
      }

      COMPARISON_OPS_MAP = {
        "="  => "eq",
        "<"  => "lt",
        ">"  => "gt",
        "<=" => "le",
        ">=" => "ge",
      }

      EXTENDED_REGEXP = Regexp.new("[#{Rus3::Lexer::EXTENDED_CHARS}]")

      EXTENDED_CHARS_MAP = {
        "!" => "!",             # no conversion
        "$" => "$",             # no conversion
        "%" => "%",             # no conversion
        "&" => "&",             # no conversion
        "*" => "*",             # no conversion
        "+" => "+",             # no conversion
        "-" => "_",
        "." => ".",             # no conversion
        "/" => "/",             # no conversion
        ":" => ":",             # no conversion
        "<" => "<",             # no conversion
        "=" => "=",             # no conversion
        ">" => "to_",
        "?" => "?",             # no conversion
        "@" => "@",             # no conversion
        "^" => "^",             # no conversion
        "_" => "_",             # no conversion
        "~" => "~",             # no conversion
      }

      def replace_extended_char(literal)
        result = literal

        COMPARISON_OPS_MAP.each { |op, word|
          comparison_regexp = Regexp.new("#{op}\\?\\Z")
          if comparison_regexp === literal
            result = literal.sub(comparison_regexp, "_#{word}?")
          end
        }

        result.gsub(EXTENDED_REGEXP, EXTENDED_CHARS_MAP)
      end

      # :startdoc:
    end
  end
end
