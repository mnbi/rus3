# frozen_string_literal: true

module Rus3

  module Parser
    require "readline"

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

      # Reads an expression from the passed IO instance.  Returns nil
      # when reaches to EOF.

      def read(io = STDIN)
        nil
      end

      # Constructs the version string.

      def version
        "Parser version #{VERSION}"
      end
    end

    require_relative "parser/scheme_parser"

    # :stopdoc:

    class PassthroughParser < Parser
      PARSER_VERSION = "0.1.0"

      def read(io = STDIN)
        Readline::readline(@prompt, true)
      end

      def version
        super + " (Pass Through Parser version: #{PARSER_VERSION})"
      end
    end

    # :startdoc:

  end

end
