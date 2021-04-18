# frozen_string_literal: true

module Rus3::Parser

  # A simple parser to read a s-expression for Scheme.
  class SchemeParser < Parser

    # Indicates the version of the parser class
    PARSER_VERSION = "0.1.0"

    # Constructs the version string.

    def version
      vmsg = "(scheme-parser-version . #{PARSER_VERSION})"
      vmsg += " (scheme-lexer-version . #{Lexer::LEXER_VERSION})"
      super + " (#{vmsg})"
    end

    def initialize
      super
    end

    # Set the prompt which includes "scheme" label.

    def prompt=(str)
      index = str.index(">")
      @prompt = str[0...index] + "(scheme)" + str[index..-1]
    end

    OP_PROCS = {
      :+  => :plus,
      :-  => :minus,
      :*  => :multiply,
      :/  => :divide,
      :%  => :modulo,
      :<  => :lt,
      :<= => :le,
      :>  => :gt,
      :>= => :ge,
      :== => :eqv,
    }

    # Parses a s-expression then translates it to a expression for Ruby.
    #
    # Converts a s-expression (scheme-expression or just S expression)
    # to an i-expression (intermediate-expression), then translate an
    # i-expression into a r-expression (ruby-expression).  An
    # i-expression is represented with an Array object in Ruby.  A
    # r-expression is a String object which could be directly
    # evaluated by `Kernel.eval`.
    #
    # Supported S-expression type:
    #
    #   - primitive expression (s_exp -> r_exp)
    #     - variable reference
    #       - identifier (symbol) -> "foo"
    #
    #     - literal expression
    #       - boolean: #f or #t   -> `false` or `true`
    #       - string              -> "hoge", "bogo", ...
    #       - number              -> 1.23, Rational(4, 5), Complex(6, 7), ...
    #
    #     - procedure call (s_exp -> i_exp -> r_exp)
    #       - (+ (* 3 4) (/ 5 6)) ... s_exp
    #         -> [:plus, [:multiply, 3, 4], [:divide, 5, 6]] ... i_exp
    #         -> "plus(multiply(3, 4), divide(5, 6))"" ... r_exp

    #       - ((lambda (x) (+ x x)) 4) ... s_exp
    #         -> [[:lambda, [:x], [:+, :x, :x]], 4] ... i_exp
    #         -> "lambda { |x| plus(x, x) }.call(4)" ... r_exp
    #
    #     - procedure (s_exp -> i_exp -> r_exp)
    #       - (lambda (x) (+ x x)) ... s_exp
    #         -> [:lambda, [:x], [:+, :x, :x]] ... i_exp
    #         -> "lambda { |x| plus(x, x) }" ... r_exp
    #
    #     - conditionals (s_exp -> i_exp -> r_exp)
    #       - (if (= n 0) 1 (* n (- n 1))) ... s_exp
    #         -> [:if, [:==, :n, 0], 1 [:*, :n, [:-, :n, 1]]] ... i_exp
    #         -> "if eqv?(n, 0)\n
    #               1\n
    #             else\n
    #               multiply(n, minus(n, 1))\n
    #             end" ... r_exp
    #
    #     - assignment (s_exp -> i_exp -> r_exp)
    #       - (set! x 2) ... s_exp
    #         -> [:set!, :x, 2] ... i_exp
    #         -> "x = 2" ... r_exp
    #
    #     - define procedure (s_exp -> i_exp -> r_exp)
    #       - (define (fact n) (if (= n 0) 1 (* n (fact (- n 1))))) ... s_exp
    #         -> [:define, [:fact, :n],
    #                      [:if, [:==, :n, 0], 1,
    #                      [:*, :n, [:fact, [:-, n, 1]]]]] ... i_exp
    #         -> "def fact(n)\n
    #                if n == 0\n
    #                  1\n
    #                else\n
    #                  n * fact((n - 1))\n
    #             end" ... r_exp
    #
    #   - derived expression
    #     - conditionals (s_exp -> i_exp -> r_exp)
    #       - (cond ((> 3 2) "greater")
    #               ((< 3 2) "less")
    #               (else "equal")) ... s_exp
    #         -> [:cond, [[[:>, 3, 2], "greater"],
    #                     [[:<, 3, 2], "less"],
    #                     [:else, "equal"]]] ... i_exp
    #         -> "if gt(3,2)\n
    #               'greater'\n
    #             elsif lt(3,2)\n
    #               'less'\n
    #             else\n
    #               'equal'
    #             end" ... r_exp
    #
    #     - building construct (s_exp -> i_exp -> r_exp)
    #       - (let ((x 2) (y 3))
    #              (* x y)) ... s_exp
    #         -> [:let, [[:x, 2], [:y, 3]], [:*, :x, :y]] ... i_exp
    #         -> "lambda { |x, y| multiply(x, y) }.call(2, 3)" ... r_exp
    #
    #  - list (s_exp -> r_exp)
    #    - (1 2 3 (4 5) (6 7 8) 9 0)
    #      -> "[1, 2, 3, [4, 5], [6, 7, 8], 9, 0]"

    def parse(s_exp)
      parse_tokens(Lexer.new(s_exp))
    end

    def parse_tokens(lexer)     # :nodoc:
      r_exp = nil
      token = lexer.next
      if token.type == :lparen
        i_exp = parse_compound(lexer)
        r_exp = translate(i_exp)
      else
        r_exp = parse_primitive(token)
      end
      r_exp
    end

    def translate(i_exp)
      r_exp = i_exp.map { |e|
        e.instance_of?(Array) ? translate(e) : e
      }.join(", ")

      "[#{r_exp}]"
    end

    def parse_primitive(token)  # :nodoc:
      r_exp = nil
      case token.type
      when *Lexer::KEYWORDS.values
        r_exp = translate_ident(token.literal)
      when :string
        r_exp = token.literal
      when :ident, :boolean, :number
        trans_method_name = "translate_#{token.type}".intern
        r_exp = self.send(trans_method_name, token.literal)
      else
        raise Rus3::SchemeSyntaxError, token.literal
      end
      r_exp
    end

    def parse_compound(lexer)  # :nodoc:
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

    def translate_ident(s_exp_literal) # :nodoc:
      ":#{s_exp_literal}"
    end

    def translate_boolean(s_exp_literal) # :nodoc:
      # literal == "#f" or #t"
      (s_exp_literal[1] == "f") ? false : true
    end

    def translate_number(s_exp_literal) # :nodoc:
      if s_exp_literal.include?("/") # rational?
        denominator, numerator = s_exp_literal.split("/").map{|s| Kernel.eval(s)}
        "Rational(#{denominator}, #{numerator})"
      else
        Kernel.eval(s_exp_literal).to_s
      end
    end

  end
end
