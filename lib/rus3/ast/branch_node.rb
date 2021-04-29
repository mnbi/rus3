# frozen_string_literal: true

module Rus3
  module AST

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
      def initialize(_ = nil)
        super(nil)
      end

      def type
        :program
      end
    end

    class VectorNode < BranchNode
      def initialize(_ = nil)
        super(nil)
      end

      def type
        :vector
      end

      def to_s
        "#(" + super + ")"
      end
    end

    class ListNode < BranchNode
      def initialize(first_literal = nil, initial_size = nil)
        super(initial_size)
        @nodes[0] = IdentifierNode.new(first_literal) if first_literal
      end

      def type
        :list
      end

      def car
        @nodes[0]
      end

      def cdr
        @nodes[1..-1]
      end

      def to_s
        "(" + super + ")"
      end
    end

    class QuotationNode < ListNode
      def initialize(_ = nil)
        super("quote")
      end

      def type
        :quotation
      end
    end

    class ProcedureCallNode < ListNode
      def initialize(_ = nil)
        # @nodes = [<operator>, <operand>*]
        super(nil, 1)
      end

      def type
        :procedure_call
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
      def initialize(_ = nil)
        # @nodes = [<lambda>, <formals>, <body> ...]
        super("lambda", 2)
      end

      def type
        :lambda_expression
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
      def initialize(_ = nil)
        # @nodes = [<if>, <test>, <consequent>] or
        #          [<if>, <test>, <consequent>, <alternate>]
        super("if", 3)
      end

      def type
        :conditional
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
      def initialize(_ = nil)
        super("set!", 3)
      end

      def type
        :assignment
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
      def initialize(_ = nil)
        super("and")
      end

      def type
        :and
      end

    end

    class MacroBlockNode < ListNode
      def initialize(literal)
        super(literal)
      end

      def type
        :macro_block
      end

    end

  end
end
