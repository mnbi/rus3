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
  #   repl = Repl.new
  #   repl.start

  class Repl

    # Indicates the version of the Repl class.
    VERSION = "0.1.0"

    include EmptyList

    # Hods major component names of the REPL.
    COMPONENTS = {
      :parser => nil,
      :evaluator => Evaluator,
      :printer => nil,
    }

    def initialize
      COMPONENTS.each { |name, klass|
        instance_variable_set("@#{name}", klass.nil? ? self : klass.new)
      }
      greeting
    end

    # Starts REPL.

    def start
      msg = loop {                      # LOOP
        begin
          print "Rus3 > "
          exp = @parser.read(STDIN)     # READ
        rescue EOFError => _
          break "Bye!"
        end

        begin
          value = @evaluator.eval(exp)  # EVAL
        rescue StandardError => e
          puts "ERROR: %s" % e
          next
        end

        print "==> "
        @printer.pp(value)              # PRINT
      }
      puts "\n#{msg}" unless msg.nil?
    end

    # Shows the greeting message.
    def greeting
      puts "A simple REPL for Rus3:"
      COMPONENTS.keys.each {|comp_name| print_version(comp_name)}
      puts "- REPL version: #{VERSION}"
      puts "- Rus3 version: #{Rus3::VERSION}"
    end

    # :stopdoc:

    protected

    def read(io = STDIN)
      io.readline(chomp: true)
    end

    def pp(obj)
      display(obj)
    end

    private

    def print_version(comp_name)
      component = instance_variable_get("@#{comp_name}")
      if component.nil? or component == self
        puts "- using built-in #{comp_name.upcase}"
      else
        puts "- #{component.version}"
      end
    end

    # :startdoc:

  end
end
