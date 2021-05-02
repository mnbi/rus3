# frozen_string_literal: true

module Rus3

  module Evaluator

    class SchemeEvaluator < Evaluator
      EVALUATOR_VERSION = "0.1.0"

      def version
        vmsg = "(scheme-evaluator :version #{EVALUATOR_VERSION})"
        if @translator
          vmsg += " #{@translator.version}"
        end
        super + " (#{vmsg})"
      end

      def initialize
        super

        @env = Environment.new
        define_procs_for_infix_ops

        @translator = Translator.new
        @translator.add_procedure_map(INFIX_OPS_MAP)
      end

      def verbose=(verbose)
        super
        @translator and @translator.verbose = verbose
      end

      def instance_variable_set(var, value)
        @env.binding.receiver.instance_variable_set(var, value)
      end

      def instance_eval(&proc)
        @env.binding.receiver.instance_eval(&proc)
      end

      def eval(ast)
        ruby_source = translate_ast(ast)
        pp ruby_source if @verbose
        @env.binding.eval(ruby_source)
      end

      def binding
        @env.binding
      end

      INFIX_OPS_MAP = {
        "+"  => "add",
        "-"  => "subtract",
        "*"  => "mul",
        "/"  => "div",
        "%"  => "mod",
        "<"  => "lt?",
        "<=" => "le?",
        ">"  => "gt?",
        ">=" => "ge?",
        "==" => "eqv?",
      }

      private

      def translate_ast(ast)
        ast.map{|node| @translator.translate(node)}.join("\n")
      end

      def define_procs_for_infix_ops
        r = @env.binding.receiver
        INFIX_OPS_MAP.each { |op, proc_name|
          r.instance_eval("def #{proc_name}(op1, op2); op1 #{op} op2; end")
        }
      end

    end
  end
end
