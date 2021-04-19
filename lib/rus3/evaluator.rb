# frozen_string_literal: true

module Rus3

  # An evaluator.

  class Evaluator

    # Indicates the version of the evaluator class.
    VERSION = "0.1.0"

    include EmptyList

    class Environment
      include Rus3

      attr_reader :binding

      def initialize
        @binding = Kernel.binding
      end

    end

    attr_reader :environment

    def initialize
      @env = Environment.new
      define_procs_for_infix_ops
    end

    def eval(exp)
      pp exp
      @env.binding.eval(exp)
    end

    def binding
      @env.binding
    end

    def version
      "Evaluator version: #{VERSION}"
    end

    private

    INFIX_OPS = {
      :+  => :plus,
      :-  => :minus,
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
