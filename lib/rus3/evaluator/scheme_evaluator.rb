# frozen_string_literal: true

module Rus3

  module Evaluator

    class SchemeEvaluator < Evaluator
      EVALUATOR_VERSION = "0.2.0"

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
        @translator = Translator.new
        @translator.add_procedure_map(ARITHMETIC_OPS_MAP)
        @translator.add_procedure_map(COMPARISON_OPS_MAP)
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

      ARITHMETIC_OPS_MAP = {
        "+"  => "add",
        "-"  => "subtract",
        "*"  => "mul",
        "/"  => "div",
        "%"  => "mod",
      }

      COMPARISON_OPS_MAP = {
        "<"  => "lt?",
        "<=" => "le?",
        ">"  => "gt?",
        ">=" => "ge?",
        "=" => "same_value?",
      }

      private

      def translate_ast(ast)
        ast.map{|node| @translator.translate(node)}.join("\n")
      end

    end
  end
end
