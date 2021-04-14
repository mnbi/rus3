# frozen_string_literal: true

module Rus3

  # Provides a very simple Read Eval Print Loop mechanism of Rus3.
  #
  # Features:
  #
  #   Each evaluated value is recorded into the value history.
  #
  #     _, _last_value       : retrieves the last evaluated value
  #     _his(n), _history(n) : retrieves the n-th value in the
  #     history.
  #     _his, _history       : prints all values in the history
  #
  # Short usage:
  #
  #   require "rus3"
  #   Rus3::Repl.start

  class Repl
    include Procedure::Write

    # Indicates the version of the Repl class.
    VERSION = "0.1.0"

    class << self

      # Starts REPL.
      def start
        repl = Repl.new
        repl.loop
      end

    end

    # Hods major component names of the REPL.
    COMPONENTS = {
      :parser => Parser::Parser,
      :evaluator => Evaluator,
      :printer => nil,
    }

    # Prompt for input.
    PROMPT = "Rus3> "

    # A message to print at exitting.
    FAREWELL_MESSAGE = "Bye!"

    @@value_history = []        # :nodoc:

    def initialize
      COMPONENTS.each { |name, klass|
        instance_variable_set("@#{name}", klass.nil? ? self : klass.new)
      }

      @prompt = nil
      @parser.prompt = PROMPT

      define_help_feature
      define_history_feature

      greeting
    end

    def loop
      msg = Kernel.loop {               # LOOP
        exp = @parser.read(STDIN)       # READ
        break FAREWELL_MESSAGE if exp.nil?

        begin
          value = @evaluator.eval(exp)  # EVAL
        rescue SyntaxError, StandardError => e
          puts "ERROR: %s" % e
          next
        end

        history_push(value)

        @printer.print(value)              # PRINT
      }
      puts "\n#{msg}" unless msg.nil?
    end

    # Shows the greeting message.
    def greeting
      puts "A simple REPL for Rus3:"
      puts "- Rus3 version: #{Rus3::VERSION}"
      puts "  - REPL version: #{VERSION}"
      COMPONENTS.keys.each { |comp_name|
        Kernel.print "    - "
        print_version(comp_name)
      }
    end

    # :stopdoc:

    protected

    def read(io = STDIN)
      Kernel.print @prompt
      begin
        io.readline(chomp: true)
      rescue EOFError => _
        nil
      end
    end

    def print(obj)
      Kernel.print "==> "
      display(obj)
    end

    private

    def define_help_feature     # :nodoc:
      r = @evaluator.binding.receiver
      r.instance_eval {
        def _help
          puts <<HELP
A simple REPL for Rus3.

FEATURES:

  History of evaluated values:
    - `_last_value` : refers the last evaluated value (short: `_`)
    - `_history(n)` : refers the n-th value in the history (short: `_his(n)`)
    - `_history`    : prints all entries in the history (short: `_his`)

  Help:
    - `_help` : prints this message
HELP
        end
      }
    end

    def define_history_feature  # :nodoc:
      r = @evaluator.binding.receiver

      r.instance_variable_set(:@value_history, @@value_history)
      r.instance_eval {

        def _last_value
          @value_history[-1]
        end
        alias :_ :_last_value

        def _history(arg = nil)
          if arg.nil?
            @value_history.each_with_index { |value, i|
              Kernel.print "#{i}: "
              display(value)
            }
            UNDEF
          else
            num = arg.to_i
            if (0...@value_history.size).cover?(num)
              @value_history[num]
            else
              raise OutOfRangeError, num
            end
          end
        end
        alias :_his :_history

      }
    end

    def print_version(comp_name)
      component = instance_variable_get("@#{comp_name}")
      if component.nil? or component == self
        puts "using built-in #{comp_name.upcase}"
      else
        puts "#{component.version}"
      end
    end

    def history_push(value)
      prev_value = @@value_history[-1]
      if prev_value != value and UNDEF != value
        @@value_history << value if prev_value != value
      end
    end

    # :startdoc:

  end
end
