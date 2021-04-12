# frozen_string_literal: true

module Rus3

  # An evaluator.

  class Evaluator

    # Indicates the version of the evaluator class.
    VERSION = "0.1.0"

    include EmptyList

    class Environment
      attr_reader :binding

      def initialize
        @binding = Kernel.binding
      end

    end

    attr_reader :environment

    def initialize
      @env = Environment.new
    end

    def eval(exp)
      @env.binding.eval(exp)
    end

    def binding
      @env.binding
    end

    def version
      "Evaluator version: #{VERSION}"
    end

  end
end
