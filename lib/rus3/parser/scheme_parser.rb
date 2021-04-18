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
    # Supported S-expression type:
    #
    #   - primitive expression
    #     - variable reference
    #       - identifier (symbol) -> "foo"
    #
    #     - literal expression
    #       - boolean: #f or #t   -> `false` or `true`
    #       - string              -> "hoge", "bogo", ...
    #       - number              -> 1.23, Rational(4, 5), Complex(6, 7), ...
    #
    #     - procedure call
    #       - (+ (* 3 4) (/ 5 6))
    #         -> [:plus, [:multiply, 3, 4], [:divide, 5, 6]]
    #         -> "plus(multiply(3, 4), divide(5, 6))""
    #       - ((lambda (x) (+ x x)) 4)
    #         -> "lambda { |x| plus(x, x) }.call(4)"
    #
    #     - procedure
    #       - (lambda (x) (+ x x))
    #         -> "lambda { |x| plus(x, x) }"
    #
    #     - conditionals
    #       - (if (= n 0) 1 (* n (- n 1)))
    #         -> "if eqv?(n, 0)\n
    #               1\n
    #             else\n
    #               multiply(n, minus(n, 1))\n
    #             end"
    #
    #     - assignment
    #       - (set! x 2)
    #         -> "x = 2"
    #
    #     - define procedure
    #       - (define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))
    #         -> [:define, [:fact, :n],
    #                      [:if, [:==, :n, 0], 1,
    #                      [:*, :n, [:fact, [:-, n, 1]]]]]
    #         -> "def fact(n)\n
    #                if n == 0\n
    #                  1\n
    #                else\n
    #                  n * fact((n - 1))\n
    #             end"
    #
    #   - derived expression
    #     - conditionals
    #       - (cond ((> 3 2) "greater")
    #               ((< 3 2) "less")
    #               (else "equal"))
    #         -> "if gt(3,2)\n
    #               'greater'\n
    #             elsif lt(3,2)\n
    #               'less'\n
    #             else\n
    #               'equal'
    #             end"
    #
    #     - building construct
    #       - (let ((x 2) (y 3))
    #              (* x y))
    #         -> "lambda { |x, y| multiply(x, y) }.call(2, 3)
    #
    #  - list
    #    - (1 2 3 (4 5) (6 7 8) 9 0)
    #      -> [1, 2, 3, [4, 5], [6, 7, 8], 9, 0]

    def parse(exp)
      rexp = []
      token = nil
      l = Lexer.new(exp)
      loop {
        token = l.next
        case token.type
        when :ident, :string
          rexp << token.literal
        when :boolean, :string, :number
          t_method_name = "translate_#{token.type}".intern
          rexp << self.send(t_method_name, token.literal)
        when :lparen
          # ...
        end
      }
      rexp.join("\n")
    end

    def translate_boolean(sexp_literal)
      # literal == "#f" or #t"
      (sexp_literal[1] == "f") ? false : true
    end

    def translate_number(sexp_literal)
      if sexp_literal.include?("/") # rational?
        denominator, numerator = sexp_literal.split("/").map{|s| Kernel.eval(s)}
        "Rational(#{denominator}, #{numerator})"
      else
        Kernel.eval(sexp_literal)
      end
    end

  end
end
