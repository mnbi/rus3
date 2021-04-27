# frozen_string_literal: true

module Rus3::Parser

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
      @curr_token = @peek_token = nil
    end

    # Parses a portion of or the whole program source then returns a
    # AST structure.

    def parse(program_source)
      parse_program(Lexer.new(program_source))
    end

    # :stopdoc:

    private

    # <program> -> <expression>*
    def parse_program(lexer)
      program = Rus3::AST.program
      Kernel.loop {
        node = parse_expression(lexer)
        program << node
      }
      program
    end

    def peek_token(lexer)
      if @peek_token.nil?
        @peek_token = lexer.next
      end
      @peek_token
    end

    def next_token(lexer)
      token = nil
      if @peek_token
        token = @peek_token
        @peek_token = nil
      else
        token = lexer.next
      end
      token
    end

    def delimiter?(token)
      [:lparen, :vec_lparen].include?(token.type)
    end

    # <expression> -> <simple expression> | <compound expression>
    def parse_expression(lexer)
      if delimiter?(peek_token(lexer))
        parse_compound_expression(lexer)
      else
        parse_simple_expression(lexer)
      end
    end

    # <simple expression> -> <identifier> | <self evaluating>
    # <self evaluating> -> <boolean> | <number> | <character> | <string>
    def parse_simple_expression(lexer)
      Rus3::AST.instantiate(next_token(lexer))
    end

    # <compound expression> -> <vector> |
    #   <procedure call> |
    #   <lambda expression> |
    #   <conditional> |
    #   <assignment> |
    #   <derived expression> |
    #   <macro use> |
    #   <macro block> |
    def parse_compound_expression(lexer)
      node = nil
      token = peek_token(lexer)
      case token.type
      when :vec_lparen
        node = parse_vector(lexer)
      when :lparen
        node = parse_list(lexer)
      else
        raise Rus3::SchemeSynaxError, token.to_a
      end
    end

    # <vetor> -> #( <datum>* )
    def parse_vector(lexer)
      parse_data_to_rparen(lexer)
    end

    def parse_data_to_rparen(lexer)
      token = next_token(lexer)
      node = Rus3::AST.instantiate(token)
      raise Rus3::SchemeSyntaxError, token.to_a unless node.branch?
      Kernel.loop {
        token = peek_token(lexer)
        break if token.type == :rparen
        node << parse_datum(lexer)
      }
      next_token(lexer)         # skip :rparen
      node
    end

    # <datum> -> <simple datum> | <compound datum>
    def parse_datum(lexer)
      if delimiter?(peek_token(lexer))
        parse_compound_datum(lexer)
      else
        parse_simple_datum(lexer)
      end
    end

    # <simple datum> -> <boolean> | <number> | <character> |
    #     <string> | <symbol> | <bytevector>
    # <symbol> -> <identifier>
    #
    # See `parse_simple_expression`.
    def parse_simple_datum(lexer)
      Rus3::AST.instantiate(next_token(lexer))
    end

    # <compound datum> -> <list> | <vector> | <abbreviation>
    # <abbreviation> -> <abbrev prefix> <datum>
    def parse_compound_datum(lexer)
      case peek_token(lexer).type
      when :lparen
        parse_list(lexer)
      when :vec_lparen
        parse_vector(lexer)
      else
        raise Rus3::SchemeSyntaxError, peek_token(lexer).to_a
      end
    end

    # <list> -> ( <datum>* ) | ( <datum>+ . <datum> )
    def parse_list(lexer)
      parse_data_to_rparen(lexer)
    end

    # :startdoc:

  end
end
