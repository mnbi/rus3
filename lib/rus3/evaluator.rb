# frozen_string_literal: true

module Rus3

  module Evaluator
    require_relative "evaluator/environment"

    # Indicates the version of the evaluator module.
    VERSION = "0.2.0"

    # An evaluator.
    class Evaluator

      attr_reader :verbose

      def initialize
        @verbose = false
      end

      def verbose=(verbose)
        @verbose = verbose
      end

      def instance_eval(&proc)
        super
      end

      def eval(ast); nil; end

      def version
        "evaluator-module version: #{VERSION}"
      end

    end

    class PassthroughEvaluator < Evaluator
      EVALUATOR_VERSION = "0.1.0"

      def version
        super + " (pass-through-evaluator version: #{EVALUATOR_VERSION})"
      end

      def eval(ast)
        if @verbose
          ast.each { |node|
            print "  evaluator(pass-through): "
            pp node
          }
        end
        ast.to_s
      end

    end

    require_relative "evaluator/scheme_evaluator"
    require_relative "evaluator/translator"

    DEFAULT_EVALUATOR = SchemeEvaluator # :nodoc:

  end
end
