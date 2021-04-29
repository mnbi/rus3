# frozen_string_literal: true

module Rus3

  module AST

    require_relative "ast/error"

    module Utils
      class << self
        def camel_case(snake_case)
          snake_case.to_s.split("_").map(&:capitalize).join("")
        end
      end
    end

    class Node
      attr_reader :literal

      def initialize(literal = nil)
        @literal = literal
      end

      def leaf?;    false; end
      def branch?;  false; end
      def illegal?; false; end

      def type; nil; end

      def to_s
        @literal
      end
    end

    class IllegalNode < Node
      def initialize(ast_type, literal)
        super(literal)
        @given_type = ast_type
      end

      def illegal?
        true
      end

      def type
        @given_type
      end

      def to_s
        "type: #{@given_type}, literal: #{@literal}"
      end
    end

    require_relative "ast/leaf_node"
    require_relative "ast/branch_node"

    class << self
      def instantiate(ast_type, literal = nil)
        klass_name = Utils.camel_case(ast_type) + "Node"
        klass = AST.const_get(klass_name)
        if klass.nil?
          IllegalNode.new(ast_type, literal)
        else
          klass.new(literal)
        end
      end

    end
  end
end
