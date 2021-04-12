# frozen_string_literal: true

module Rus3

  # Provides a very simple Read Eval Print Loop mechanism of Rus3.
  #
  # Features:
  #
  # Short usage:
  #
  #   require "rus3"
  #   include Rus3
  #
  #   repl = Repl.new(binding)
  #   repl.start

  class Repl

    # Indicates the version of the Repl class.
    VERSION = "0.1.0"

    include EmptyList

    def initialize(bind)
      @binding = bind
      greeting
    end

    # Evaluates an expression.
    def eval_exp(exp)
      @binding.eval(exp)
    end

    # Starts REPL.

    def start
      msg = loop {                          # LOOP
        begin
          print "Rus3 > "
          exp = STDIN.readline(chomp: true) # READ
        rescue EOFError => _
          break "Bye!"
        end

        begin
          v = eval_exp(exp)                   # EVAL
        rescue StandardError => e
          puts "ERROR: %s" % e
          next
        end

        print "==> "
        pretty_print(v)                     # PRINT
      }
      puts "\n#{msg}" unless msg.nil?
    end

    # Shows the greeting message.
    def greeting
      puts "A simple REPL for Rus3:"
      puts "- REPL version: #{VERSION}"
      puts "- Rus3 version: #{Rus3::VERSION}"
    end

    # :stopdoc:

    private

    def pretty_print(obj)
      display(obj)
    end

    # :startdoc:

  end
end
