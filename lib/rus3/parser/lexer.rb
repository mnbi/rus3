# frozen_string_literal: true

module Rus3::Parser

  class Lexer < Enumerator

    # Indicates the version of the lexer class
    LEXER_VERSION = "0.1.0"

    # :stopdoc:

    TYPES = [
      # delimiters
      :lparen,
      :rparen,
      # value types
      :boolean,
      :ident,
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
    IDENTIFIER = /\A[a-zA-Z_][\w?!]*\Z/
    STRING     = /\A\"[^\"]*\"\Z/

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

    KEYWORDS = {
      "IF" => :if,
      "DEFINE" => :define,
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

        source.split(" ").map { |tk|
          case tk
          when "["
            Token.new(:lparen, tk)
          when "]"
            Token.new(:rparen, tk)
          when BOOLEAN
            Token.new(:boolean, tk)
          when IDENTIFIER
            key = tk.upcase
            if KEYWORDS.keys.include?(key)
              Token.new(KEYWORDS[key], tk)
            else
              Token.new(:ident, tk)
            end
          when STRING
            Token.new(:string, tk)
          when "="
            Token.new(:op_proc, "==")
          when ARITHMETIC_OPS, COMPARISON_OPS
            Token.new(:op_proc, tk)
          when REAL_NUM, RATIONAL, COMPLEX, PURE_IMAG
            Token.new(:number, tk)
          else
            Token.new(:illegal, tk)
          end
        }
      end

    end

  end
end
