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
      :parser => nil,
      :evaluator => Evaluator,
      :printer => nil,
    }

    @@value_history = []        # :nodoc:

    def initialize
      COMPONENTS.each { |name, klass|
        instance_variable_set("@#{name}", klass.nil? ? self : klass.new)
      }

      define_history_feature
      greeting
    end

    def loop
      msg = Kernel.loop {               # LOOP
        begin
          print "Rus3> "
          exp = @parser.read(STDIN)     # READ
        rescue EOFError => _
          break "Bye!"
        end

        begin
          value = @evaluator.eval(exp)  # EVAL
        rescue SyntaxError, StandardError => e
          puts "ERROR: %s" % e
          next
        end

        history_push(value)

        print "==> "
        @printer.pp(value)              # PRINT
      }
      puts "\n#{msg}" unless msg.nil?
    end

    # Shows the greeting message.
    def greeting
      puts "A simple REPL for Rus3:"
      puts "- Rus3 version: #{Rus3::VERSION}"
      puts "  - REPL version: #{VERSION}"
      COMPONENTS.keys.each { |comp_name|
        print "    - "
        print_version(comp_name)
      }
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
              print "#{i}: "
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
