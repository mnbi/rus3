# frozen_string_literal: true

module Rus3

  # Provides a very simple Read Eval Print Loop mechanism of Rus3.
  #
  # Features:
  #
  #   `_`            : Refers the last evaluated value.
  #   `_history(n)`  : Refers the n-th entry of the history.
  #   `_history`     : shows all entries in the history.
  #   `_his` or `_h` : an alias of `history`
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

    def initialize
      @history = []
      greeting
    end

    # Returns the last value evaluated by "eval_exp".
    def last_value
      @history[-1]
    end
    alias :_ :last_value

    # Saves the last value evaluated by "eval_exp"
    def save_last_value(value)
      unless UNDEF == value or @history[-1] == value
        @history << value unless UNDEF == value
      end
    end

    # Shows history entries.
    def _history(num = nil)
      unless num.nil?
        @history[num]
      else
        if @history.empty?
          puts "(no entry)"
        else
          @history.each_with_index { |e, i|
            print "#{i}: "
            pretty_print(e)
          }
        end
        UNDEF
      end
    end
    alias :_his :_history
    alias :_h :_history

    # Evaluates an expression.
    def eval_exp(exp)
      eval(exp)
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

        save_last_value(v)
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
