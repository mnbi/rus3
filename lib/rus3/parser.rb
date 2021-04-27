# frozen_string_literal: true

module Rus3

  module Parser
    require "readline"
    require_relative "parser/lexer"

    # Indicates the version of the parser module.
    VERSION = "0.2.0"

    # A base class to derived a parser.
    class Parser

      # Holds a prompt string.  It is intended to be set in the REPL
      # loop.
      attr_accessor :prompt

      # Constructs the version string.

      def version
        "parser-module :version #{VERSION}"
      end

      def initialize
        @prompt = ""
      end

      def prompt=(str)
        index = str.index(">")
        class_name = self.class.name.split("::")[-1]
        parser_name = class_name.delete_suffix("Parser").downcase
        @prompt = str[0...index] + "(#{parser_name})" + str[index..-1]
      end

      # Reads program source from the passed IO instance, then returns
      # the AST (abstract syntax tree).  Returns nil when reaches to
      # EOF.

      def read(io = STDIN)
        program_source = nil
        if io == STDIN
          program_source = Readline::readline(@prompt, true)
        else
          program_source = io.readlines(chomp: true).join(" ")
        end
        program_source.nil? ? nil : parse(program_source)
      end

      protected

      # Parses the passed program source, then returns the AST to be
      # evaluated by an evaluator.  How to process depends on each
      # derived parser class.

      def parse(program_source)
        nil
      end

    end

    require_relative "parser/scheme_parser"

    # :stopdoc:

    class PassthroughParser < Parser
      PARSER_VERSION = "0.2.0"

      def version
        vmsg = "(pass-through-parser version: #{PARSER_VERSION})"
        vmsg += " #{Lexer.version}"
        super + " (#{vmsg})"
      end

      def parse(program_source)
        [Lexer.new(program_source).map {|tk| tk.to_s}]
      end

    end

    # :startdoc:

    DEFAULT_PARSER = SchemeParser # :nodoc:

  end

end
