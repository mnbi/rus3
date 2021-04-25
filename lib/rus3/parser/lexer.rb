# frozen_string_literal: true

module Rus3::Parser

  class Lexer < Enumerator

    # Indicates the version of the lexer class
    LEXER_VERSION = "0.1.1"

    class << self

      def version
        "(scheme-lexer :version #{LEXER_VERSION})"
      end

    end

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
    EXTENDED_CHARS = "!\\$%&\\*\\+\\-\\./:<=>\\?@\\^_~"
    EXTENDED_REGEXP = Regexp.new("[#{EXTENDED_CHARS}]")
    IDENT_PAT  = "[a-zA-Z_][a-zA-Z0-9#{EXTENDED_CHARS}]*"
    IDENTIFIER = Regexp.new("\\A#{IDENT_PAT}\\Z")

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

    SCM_KEYWORDS = {
      "LAMBDA" => :lambda,
      "IF"     => :if,
      "SET!"   => :set!,
      "DEFINE" => :define,
      "COND"   => :cond,
      "LET"    => :let,
      "ELSE"   => :else,        # may use with :cond
    }

    # :startdoc:

    Token = Struct.new(:type, :literal) { # :nodoc:
      alias :to_s :literal
    }

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
            if SCM_KEYWORDS.keys.include?(key)
              Token.new(SCM_KEYWORDS[key], literal)
            else
              Token.new(:ident, replace_extended_char(literal))
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

      COMPARISON_OPS_MAP = {
        "="  => "eq",
        "<"  => "lt",
        ">"  => "gt",
        "<=" => "le",
        ">=" => "ge",
      }

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

    end

  end
end
