# frozen_string_literal: true

module Rus3

  module AST

    TOKEN_TYPE_MAP = {
      program: [],
      dot: [:dot],
      identifier: [:identifier,],
      peculiar_identifier: [:op_proc,],
      self_evaluating: [:boolean, :number, :character, :string,],
      vector: [:vec_lparen,],
      list: [:lparen,],
      quotation: [:quotation,],
      illegal: [:illegal,],
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

      def dot(token)
        DotNode.new(token.literal)
      end

      def identifier(token)
        IdentifierNode.new(token.literal)
      end

      def peculiar_identifier(token)
        PeculiarIdentifier.new(token.literal)
      end

      def self_evaluating(token)
        node_name = "#{camel_case(token.type.to_s)}Node"
        klass = AST.const_get(node_name)
        klass.new(token.literal)
      end

      def procedure_call(_token)
        ProcedureCallNode.new
      end

      def lambda_expression(_token)
        LambdaExpressionNode.new
      end

      def conditional(_token)
        ConditionalNode.new
      end

      def assignment(_token)
        AssignmentNode.new
      end

      def macro_block(token)
        MacroBlockNode.new(token.literal)
      end

      def derived_expression(token)
        # not implemented yet ...
        nil
      end

      def vector(_token = nil)
        VectorNode.new
      end

      def list(_token = nil)
        ListNode.new
      end

      def quotation(_token = nil)
        QuotationNode.new
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

      def [](index)
        raise OutOfRangeError, index if index >= @nodes.size
        @nodes[index]
      end

      def each(&block)
        if block.nil?
          @nodes.each
        else
          @nodes.each(&block)
          self
        end
      end

      def to_s
        @nodes.map(&:to_s).join(" ")
      end

    end

    class ProgramNode < BranchNode
    end

    class BooleanNode < LeafNode
      def initialize(literal)
        super
      end
    end

    class DotNode < LeafNode
    end

    class IdentifierNode < LeafNode
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
      def to_s
        str = "#(" + super + ")"
      end
    end

    class ListNode < BranchNode
      def initialize(first_literal = nil)
        super()
        @nodes << IdentifierNode.new(first_literal) if first_literal
      end

      def car
        @nodes[0]
      end

      def cdr
        @nodes[1..-1]
      end

      def to_s
        str = "(" + super + ")"
      end
    end

    class QuotationNode < ListNode
      def initialize
        super("quote")
      end
    end

    class ProcedureCallNode < ListNode
      def initialize
        super
      end

      def operator
        @nodes[0]
      end

      def operator=(node)
        @nodes[0] = node
      end

      def operands
        @nodes[1..-1]
      end

      def add_operand(node)
        @nodes[0] = nil if @nodes.size < 1 # keep space for operator node
        @nodes << node
      end
    end

    class LambdaExpressionNode < ListNode
      def initialize
        super("lambda")
      end

      def formals
        @nodes[1]
      end

      def formals=(list_node)
        @nodes[1] = list_node
      end

      def body
        @nodes[2..-1]
      end

      def body=(nodes)
        @nodes[0] = nil if @nodes.size < 1 # keep space for `lambda`
        @nodes[1] = nil if @nodes.size < 2 # keep space for formals
        @nodes.concat(nodes)
      end
    end

    class ConditionalNode < ListNode
      def initialize
        super("if")
      end
    end

    class AssignmentNode < ListNode
      def initialize
        super("set!")
      end
    end

    class AndNode < ListNode
      def initialize
        super("and")
      end
    end

    class MacroBlockNode < ListNode
      def initialize(literal)
        super(literal)
      end
    end

    class IllegalNode < Node
      def illegal?
        true
      end
    end

  end

end
