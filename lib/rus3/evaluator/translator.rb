# frozen_string_literal: true

module Rus3::Evaluator

  # A class to translate an i-exp to r-exp.

  class Translator
    TRANSLATOR_VERSION = "0.1.0"

    def version
      "(scheme-ruby-translator :version #{TRANSLATOR_VERSION})"
    end

    def initialize
      @procedure_map = {}
    end

    def add_procedure_map(map)
      @procedure_map.merge!(map)
    end

    # Reads an i-exp (intermediate-expression, or generally called as
    # AST) then translates it to r-exp (ruby-expression, which can be
    # evaluated by Kernel.eval.  Returns the r-exp.

    def translate(i_exp)
      return ""
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
