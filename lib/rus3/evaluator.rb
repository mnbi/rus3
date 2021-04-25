# frozen_string_literal: true

module Rus3

  module Evaluator
    require_relative "evaluator/environment"

    # Indicates the version of the evaluator module.
    VERSION = "0.1.0"

    # An evaluator.
    class Evaluator

      attr_accessor :verbose

      def initialize
        @verbose = false
      end

      def instance_eval(&proc)
        super
      end

      def eval(i_exps); nil; end

      def version
        "evaluator-module version: #{VERSION}"
      end

    end

    class PassthroughEvaluator < Evaluator
      EVALUATOR_VERSION = "0.1.0"

      def version
        super + " (pass-through-evaluator version: #{EVALUATOR_VERSION})"
      end

      def eval(i_exps)
        if @verbose
          i_exps.each { |i_exp|
            print "  evaluator(pass-through): "
            pp i_exp
          }
        end
        i_exps.join(" ")
      end

    end

    require_relative "evaluator/scheme_evaluator"
    require_relative "evaluator/translator"

    DEFAULT_EVALUATOR = SchemeEvaluator # :nodoc:

  end
end
