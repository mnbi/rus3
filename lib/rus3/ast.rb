# frozen_string_literal: true

module Rus3

  module AST

    TOKEN_TYPE_MAP = {
      program:    [],
      dot:        [:dot],
      identifier: [:identifier,],
      peculiar_identifier: [:op_proc,],
      self_evaluating: [:boolean, :number, :character, :string,],
      vector:     [:vec_lparen,],
      list:       [:lparen,],
      quotation:  [:quotation,],
      illegal:    [:illegal,],
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

      def initialize(size = nil)
        super(nil)
        @nodes = size.nil? ? [] : Array.new(size)
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
      def initialize(first_literal = nil, initial_size = nil)
        super(initial_size)
        @nodes[0] = IdentifierNode.new(first_literal) if first_literal
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
        # @nodes = [<operator>, <operand>]
        super(nil, 1)
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
        @nodes << node
      end
    end

    class LambdaExpressionNode < ListNode
      def initialize
        # @nodes = [<lambda>, <formals>, <body> ...]
        super("lambda", 2)
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
        nodes.each_with_index { |node, i|
          @nodes[i + 2] = node
        }
      end
    end

    class ConditionalNode < ListNode
      def initialize
        super("if", 4)
      end

      def test
        @nodes[1]
      end

      def consequent
        @nodes[2]
      end

      def alternate
        if @nodes.size > 3
          @nodes[3]
        else
          nil
        end
      end

      def test=(node)
        @nodes[1] = node
      end

      def consequent=(node)
        @nodes[2] = node
      end

      def alternate=(node)
        @nodes[3] = node
      end
    end

    class AssignmentNode < ListNode
      def initialize
        super("set!", 3)
      end

      def identifier
        @nodes[1]
      end

      def identifier=(node)
        @nodes[1] = node
      end

      def expression
        @nodes[2]
      end

      def expression=(node)
        @nodes[2] = node
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
