# frozen_string_literal: true

module Rus3
  module AST

    class LeafNode < Node
      def leaf?
        true
      end
    end

    class BooleanNode < LeafNode
      def type
        :boolean
      end
    end

    class IdentifierNode < LeafNode
      def type
        :identifier
      end
    end

    class PeculiarIdentifierNode < IdentifierNode
      def type
        :peculiar_identifier
      end
    end

    class CharacterNode < LeafNode
      def type
        :character
      end
    end

    class StringNode < LeafNode
      def type
        :string
      end
    end

    class NumberNode < LeafNode
      def type
        :number
      end
    end

    class DotNode < LeafNode
      def type
        :dot
      end
    end

  end
end
