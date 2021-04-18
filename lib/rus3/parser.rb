# frozen_string_literal: true

module Rus3

  module Parser
    require "readline"
    require_relative "parser/lexer"

    # Indicates the version of the parser module.
    VERSION = "0.1.0"

    # A base class to derived a parser.
    class Parser

      # Holds a prompt string.  It is intended to be set in the REPL
      # loop.
      attr_accessor :prompt

      def initialize
        @prompt = ""
      end

      # Constructs the version string.

      def version
        "Parser version #{VERSION}"
      end

      # Reads an expression from the passed IO instance.  Returns nil
      # when reaches to EOF.

      def read(io = STDIN)
        exp = Readline::readline(@prompt, true)
        exp.nil? ? nil : parse(exp)
      end

      protected

      # Parses the passed expression, then returns the processed
      # expression to be evaluated by an evaluator.  How to process
      # depends on each derived parser class.

      def parse(exp)
        nil
      end

    end

    require_relative "parser/scheme_parser"

    DEFAULT_PARSER = SchemeParser # :nodoc:

    # :stopdoc:

    class PassthroughParser < Parser
      PARSER_VERSION = "0.1.0"

      def version
        super + " (Pass Through Parser version: #{PARSER_VERSION})"
      end
    end

    def parse(exp)
      exp
    end

    # :startdoc:

  end

end
