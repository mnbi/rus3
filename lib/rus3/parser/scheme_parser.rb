# frozen_string_literal: true

module Rus3::Parser

  # A simple parser to read a s-expression for Scheme.
  class SchemeParser < Parser
    # Indicates the version of the parser class
    PARSER_VERSION = "0.1.0"

    # Set the prompt which includes "scheme" label.

    def prompt=(str)
      index = str.index(">")
      @prompt = str[0...index] + "(scheme)" + str[index..-1]
    end

    S2R_MAP = { "(" => "[ ", ")" => " ]" } # :nodoc:

    # Reads a s-expression then converts it to a expression for Ruby.
    #
    #   (+ 1 (* 3 4) (/ 5 6) 7)
    #   --> [:+, 1, [:*, 3, 4], [:/, 5, 6], 7]
    #
    #   (define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))
    #   --> [:define, [:fact, :n],
    #                 [:if, [:==, :n, 0], 1,
    #                       [:*, :n, [:fact, [:-, n, 1]]]]]
    #
    def read(io = STDIN)
      s_exp = Readline::readline(@prompt, true)
      return nil if s_exp.nil?

      # (foo 1 2) -> [ foo 1 2 ]
      r_exp = s_exp.gsub(/[()]/, S2R_MAP)

      r_exp.split(" ").map { |e|
        case e
        when "[", "]"
          e
        when "="
          ":=="
        when /\A[+\-*\/%]\Z/        # arithmetic operator
          ":#{e}"
        when /\A[+-]?[0-9].*\Z/     # number
          e
        when /\A[a-zA-z_][\w]*\Z/   # identifier
          ":#{e}"
        when /\A\"[^\"]*\"\Z/       # string
          e
        else
          "#{e}"
        end
      }.join(", ").gsub(/\[\,/, "[")
    end

    # Constructs the version string.
    def version
      super + " (Scheme Parser version: #{PARSER_VERSION})"
    end

  end

end
