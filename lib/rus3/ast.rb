# frozen_string_literal: true

module Rus3

  module AST

    TOKEN_TYPE_MAP = {
      :program => [],
      :identifier => [:identifier,],
      :keyword => [:lambda, :if, :set!, :define, :cond, :let, :else,],
      :peculiar_identifier => [:op_proc,],
      :self_evaluating => [:boolean, :number, :character, :string,],
      :derived_expression_types => [
        :cond, :case, :and, :or, :let, :let_star, :letrec, :begin, :do, :delay,
      ],
      :vector => [:vec_lparen,],
      :list => [:lparen,],
      :illegal => [:illegal,],
    }

    class << self
      def instantiate(token)
        node_type = :illegal
        TOKEN_TYPE_MAP.each { |ast_node_type, token_types|
          if token_types.include?(token.type)
            node_type = ast_node_type
            break
          end
        }
        method = self.singleton_method(node_type)
        method.call(token)
      end

      def program(_ = nil)
        ProgramNode.new
      end

      def identifier(token)
        IdentifierNode.new(token.literal)
      end

      def keyword(token)
        KeywordNode.new(token.literal)
      end

      def peculiar_identifier(token)
        PeculiarIdentifier.new(token.literal)
      end

      def self_evaluating(token)
        node_name = "#{camel_case(token.type.to_s)}Node"
        klass = AST.const_get(node_name)
        klass.new(token.literal)
      end

      def vector(_ = nil)
        VectorNode.new
      end

      def list(_ = nil)
        ListNode.new
      end

      def illegal(token)
        IllegalNode.new(token.literal)
      end

      private

      def camel_case(snake_case)
        snake_case.split("_").map(&:capitalize).join("")
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

      def to_s
        @literal
      end
    end

    class LeafNode < Node
      def leaf?
        true
      end
    end

    class BranchNode < Node
      include Enumerable

      def initialize
        super
        @nodes = []
      end

      def branch?
        true
      end

      def <<(node)
        @nodes << node
      end

      def each(&block)
        @nodes.each(&block)
      end

    end

    class ProgramNode < BranchNode
    end

    class BooleanNode < LeafNode
      def initialize(literal)
        super
      end
    end

    class IdentifierNode < LeafNode
    end

    class KeywordNode < IdentifierNode
    end

    class PeculiarIdentifier < IdentifierNode
    end

    class CharacterNode < LeafNode
    end

    class StringNode < LeafNode
    end

    class NumberNode < LeafNode
    end

    class OpProcNode < LeafNode
    end

    class VectorNode < BranchNode
    end

    class ListNode < BranchNode
      def car
        @nodes[0]
      end

      def cdr
        @nodes[1..-1]
      end
    end

    class LambdaExpressionNode < BranchNode
      def formals
        @node[0]
      end

      def formals=(list_node)
        @node[0] = list_node
      end

      def body
        @node[1..-1]
      end

      def body=(*nodes)
        @node.concat(nodes)
      end
    end

    class ConditionalNode < BranchNode
    end

    class MacroBlockNode < BranchNode
    end

    class IllegalNode < Node
      def illegal?
        true
      end
    end

  end

end
