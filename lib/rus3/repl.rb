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

    # Indicates the version of the Repl class.
    REPL_VERSION = "0.2.1"

    class << self

      # Starts REPL.
      def start(evaluator: nil, verbose: false)
        repl = Repl.new(evaluator: evaluator, verbose: verbose)
        repl.loop
      end

    end

    # Hods major component names of the REPL.
    COMPONENTS = {
      :parser    => Rubasteme::Parser,
      :evaluator => Evaluator::DEFAULT_EVALUATOR,
      :printer   => Printer::ChainPrinter,
    }

    # Prompt for input.
    PROMPT = "Rus3> "

    # A message to print at exitting.
    FAREWELL_MESSAGE = "Bye!"

    @@value_history = []        # :nodoc:

    attr_accessor :verbose      # :nodoc:
    attr_accessor :prompt       # :nodoc:

    def initialize(evaluator: nil, verbose: false)
      comps = COMPONENTS.dup

      comps[:evaluator] = Evaluator.const_get("#{evaluator.capitalize}Evaluator") if evaluator

      comps.each { |name, klass|
        instance_variable_set("@#{name}", klass.new)
      }

      @prompt = PROMPT

      @verbose = verbose
      @evaluator.verbose = verbose
      @printer.verbose = verbose

      define_constants
      define_help_feature
      define_history_feature
      define_load_feature

      greeting
    end

    def loop
      msg = Kernel.loop {       # LOOP
        begin
          source = read(STDIN)  # READ
          break FAREWELL_MESSAGE if source.nil?
          ast = @parser.parse(Rbscmlex::Lexer.new(source))
        rescue SchemeSyntaxError => e
          puts "ERROR" + (@verbose ? "(READ)" : "")  + ": %s" % e
          next
        end

        begin
          value = @evaluator.eval(ast) # EVAL
        rescue SyntaxError, StandardError => e
          puts "ERROR" + (@verbose ? "(EVAL)" : "")  + ": %s" % e
          next
        end

        history_push(value)

        @printer.print(value)   # PRINT
      }
      puts "#{msg}" unless msg.nil?
    end

    # Shows the greeting message.
    def greeting
      puts "A simple REPL to run Rus3:"
      return unless @verbose

      vmsg =  "(rus3 :version #{Rus3::VERSION} :release #{Rus3::RELEASE}\n"
      vmsg += "  (repl :version #{REPL_VERSION}\n"

      comp_vmsgs = []
      COMPONENTS.keys.each { |comp_name|
        comp_vmsgs << "    (#{version_message(comp_name)})"
      }
      vmsg += comp_vmsgs.join("\n")
      vmsg += "))"

      puts vmsg
    end

    # :stopdoc:

    protected

    require "readline"

    def read(io = STDIN)
      program_source = nil
      if io == STDIN
        program_source = Readline::readline(@prompt, true)
      else
        program_source = io.readlines(chomp: true).join(" ")
      end
      program_source
    end

    private

    def version_message(comp_name)
      vmsg = ""
      component = instance_variable_get("@#{comp_name}")
      if component.class.respond_to?(:version)
        vmsg = "#{component.class.version}"
      elsif component.respond_to?(:version)
        vmsg = "#{component.version}"
      end
      vmsg
    end

    def define_constants        # :nodoc:
      return if @evaluator.nil?

      @evaluator.instance_eval {
        self.class.const_set(:RUS3_VERSION, "#{VERSION}")
      }
    end

    def define_help_feature     # :nodoc:
      return if @evaluator.nil?

      @evaluator.instance_eval {
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
      return if @evaluator.nil?

      @evaluator.instance_variable_set(:@value_history, @@value_history)
      @evaluator.instance_eval {

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

    def define_load_feature
      return if @evaluator.nil?

      @evaluator.instance_variable_set(:@scm_parser, @parser)
      @evaluator.instance_variable_set(:@scm_evaluator, @evaluator)
      @evaluator.instance_eval {
        def load_scm(path)
          raise Rus3::CannotFindFileError, path unless FileTest.exist?(path)
          scheme_source = File.readlines(path, chomp: true).join(" ")
          result = ast = nil
          if @scm_parser.respond_to?(:parse)
            lexer = Rbscmlex::Lexer.new(scheme_source)
            ast = @scm_parser.parse(lexer)
          end
          if @scm_evaluator.respond_to?(:eval)
            result = @scm_evaluator.eval(ast)
          end
          pp result
        end
      }
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
