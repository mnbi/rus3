# frozen_string_literal: true

module Rus3::Evaluator

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
      @translator = Translator.new

      define_procs_for_infix_ops
    end

    def instance_eval(&proc)
      if proc
        @env.binding.receiver.instance_eval(&proc)
      else
        super
      end
    end

    def eval(i_exps)
      r_exps = i_exps.map { |exp| @translator.translate(exp) }.join("\n")
      pp r_exps if @verbose
      @env.binding.eval(r_exps)
    end

    def binding
      @env.binding
    end

    private

    INFIX_OPS = {
      :+  => :add,
      :-  => :subtract,
      :*  => :mul,
      :/  => :div,
      :%  => :mod,
      :<  => :lt?,
      :<= => :le?,
      :>  => :gt?,
      :>= => :ge?,
      :== => :eqv?,
    }

    def define_procs_for_infix_ops
      r = @env.binding.receiver
      INFIX_OPS.each { |op, proc_name|
        r.instance_eval("def #{proc_name}(op1, op2); op1 #{op} op2; end")
      }
    end

  end
end
