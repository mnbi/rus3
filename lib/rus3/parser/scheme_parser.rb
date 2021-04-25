# frozen_string_literal: true

module Rus3::Parser

  # A simple parser to read a s-expression for Scheme.
  class SchemeParser < Parser

    # Indicates the version of the parser class
    PARSER_VERSION = "0.1.1"

    # Constructs the version string.

    def version
      vmsg = "(scheme-parser :version #{PARSER_VERSION})"
      vmsg += " #{Lexer.version}"
      super + " (#{vmsg})"
    end

    def initialize
      super
    end

    # Parses s-expressions then constructs i-expressions.  An
    # i-expression is represented with an Array object in Ruby.

    def parse(s_exp)
      parse_tokens(Lexer.new(s_exp))
    end

    def parse_tokens(lexer)     # :nodoc:
      i_exps = []
      loop { i_exps << parse_s_exp(lexer) }
      i_exps
    end

    def parse_s_exp(lexer)
      i_exp = nil
      token = lexer.next
      case token.type
      when :lparen
        i_exp = parse_compound(lexer)
      when :vec_lparen
        i_exp = parse_vector(lexer)
      else
        i_exp = parse_primitive(token)
      end
      i_exp
    end

    def parse_primitive(token)
      i_exp = nil
      case token.type
      when *Lexer::SCM_KEYWORDS.values
        i_exp = token.to_a
      when :string
        i_exp = token.to_a
      when :ident, :boolean, :char, :number, :op_proc
        i_exp = token.to_a
      else
        raise Rus3::SchemeSyntaxError, token.to_a
      end
      i_exp
    end

    def parse_vector(lexer)
      i_exp = [[:ident, "vector"]]
      Kernel.loop {
        token = lexer.peek
        case token.type
        when :lparen
          lexer.next
          i_exp << parse_compound(lexer)
        when :vec_lparen
          lexer.next
          i_exp << parse_vector(lexer)
        when :rparen
          lexer.next
          break
        else
          i_exp << parse_s_exp(lexer)
        end
      }
      i_exp
    end

    def parse_compound(lexer)
      i_exp = []
      Kernel.loop {
        token = lexer.next
        case token.type
        when :lparen
          i_exp << parse_compound(lexer)
        when :rparen
          break
        else
          i_exp << parse_primitive(token)
        end
      }
      i_exp
    end

  end
end
