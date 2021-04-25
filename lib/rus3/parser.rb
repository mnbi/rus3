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

      # Reads an expression from the passed IO instance.  Returns nil
      # when reaches to EOF.

      def read(io = STDIN)
        exp = nil
        if io == STDIN
          exp = Readline::readline(@prompt, true)
        else
          exp = io.readlines(chomp: true).join(" ")
        end
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

    # :stopdoc:

    class PassthroughParser < Parser
      PARSER_VERSION = "0.1.0"

      def version
        vmsg = "(pass-through-parser version: #{PARSER_VERSION})"
        vmsg += " #{Lexer.version}"
        super + " (#{vmsg})"
      end

      def parse(exp)
        [Lexer.new(exp).map {|tk| tk.to_s}]
      end

    end

    # :startdoc:

    DEFAULT_PARSER = SchemeParser # :nodoc:

  end

end
