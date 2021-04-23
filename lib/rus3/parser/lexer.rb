# frozen_string_literal: true

module Rus3::Parser

  class Lexer < Enumerator

    # Indicates the version of the lexer class
    LEXER_VERSION = "0.1.1"

    # :stopdoc:

    TYPES = [
      # delimiters
      :lparen,
      :rparen,
      :vec_lparen,
      # value types
      :boolean,
      :ident,
      :char,
      :string,
      :number,
      # operators
      :op_proc,
      # keywords
      :if,
      :define,
      # control
      :illegal,
    ]

    BOOLEAN    = /\A#(f|t)\Z/
    STRING     = /\A\"[^\"]*\"\Z/

    # idents
    EXTENDED   = "\\->"
    IDENT_PAT  = "[a-zA-Z_][\\w?!#{EXTENDED}]*"
    IDENTIFIER = Regexp.new("\\A#{IDENT_PAT}\\Z")

    EXTENDED_REGEXP = Regexp.new("[#{EXTENDED}]")
    EXTENDED_MAP = { "-" => "_", ">" => "to_"}

    # operators
    ARITHMETIC_OPS = /\A[+\-*\/%]\Z/
    COMPARISON_OPS = /\A[<>]=?\Z/

    # numbers
    REAL_PAT   = "(([1-9][0-9]*)|0)(\.[0-9]+)?"
    RAT_PAT    = "#{REAL_PAT}\\/#{REAL_PAT}"
    C_REAL_PAT = "(#{REAL_PAT}|#{RAT_PAT})"
    C_IMAG_PAT = "#{C_REAL_PAT}"
    COMP_PAT   = "#{C_REAL_PAT}(\\+|\\-)#{C_IMAG_PAT}i"

    REAL_NUM   = Regexp.new("\\A[+-]?#{REAL_PAT}\\Z")
    RATIONAL   = Regexp.new("\\A[+-]?#{RAT_PAT}\\Z")
    COMPLEX    = Regexp.new("\\A[+-]?#{COMP_PAT}\\Z")
    PURE_IMAG  = Regexp.new("\\A[+-](#{C_IMAG_PAT})?i\\Z")

    # char
    SINGLE_CHAR_PAT = "."
    SPACE_PAT       = "space"
    NEWLINE_PAT     = "newline"

    CHAR_PREFIX = "\#\\\\"
    CHAR_PAT    = "(#{SINGLE_CHAR_PAT}|#{SPACE_PAT}|#{NEWLINE_PAT})"
    CHAR        = Regexp.new("\\A#{CHAR_PREFIX}#{CHAR_PAT}\\Z")

    KEYWORDS = {
      "LAMBDA" => :lambda,
      "IF"     => :if,
      "SET!"   => :set!,
      "DEFINE" => :define,
      "COND"   => :cond,
      "LET"    => :let,
      "ELSE"   => :else,        # may use with :cond
    }

    # :startdoc:

    Token = Struct.new(:type, :literal) # :nodoc:

    class << self

      def new(exp, _ = nil)
        tokens = tokenize(exp)
        super(tokens.size) { |y|
          tokens.each { |tk|
            y.yield(tk)
          }
        }
      end

      S2R_MAP = { "(" => "[ ", ")" => " ]" } # :nodoc:

      def tokenize(exp)
        source = exp.gsub(/[()]/, S2R_MAP)

        source.split(" ").map { |literal|
          case literal
          when "["
            Token.new(:lparen, literal)
          when "]"
            Token.new(:rparen, literal)
          when "#["
            Token.new(:vec_lparen, literal)
          when BOOLEAN
            Token.new(:boolean, literal)
          when IDENTIFIER
            key = literal.upcase
            if KEYWORDS.keys.include?(key)
              Token.new(KEYWORDS[key], literal)
            else
              Token.new(:ident, literal.gsub(EXTENDED_REGEXP, EXTENDED_MAP))
            end
          when CHAR
            Token.new(:char, literal)
          when STRING
            Token.new(:string, literal)
          when "="
            Token.new(:op_proc, "==")
          when ARITHMETIC_OPS, COMPARISON_OPS
            Token.new(:op_proc, literal)
          when REAL_NUM, RATIONAL, COMPLEX, PURE_IMAG
            Token.new(:number, literal)
          else
            Token.new(:illegal, literal)
          end
        }
      end

    end

  end
end
