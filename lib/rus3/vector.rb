# frozen_string_literal: true

require "forwardable"

module Rus3

  # A class to represent a vector structure of Scheme.

  class Vector
    extend Forwardable

    class << self
      # Returns a new Vector instance which elements are the given objs.
      def vector(*objs)
        list_to_vector(objs)
      end

      # Converts a list into a new Vector instance.
      def list_to_vector(lst)
        vec = self.new(lst.size)
        lst.each_with_index {|e, i| vec.set!(i, e)}
        vec
      end

      # Converts a Vector instance into a list.
      def vector_to_list(vec)
        vec.to_a
      end

      # Replaces the k-th element of the given vector with obj.
      def vector_set!(vec, k, obj)
        raise ExceedUpperLimitError.new(k, vec.length) if k >= vec.length
        vec.set!(k, obj)
      end

    end

    def initialize(k, fill = UNDEF)
      @content = Array.new(k, fill)
    end

    def_delegator :@content, :[], :ref
    def_delegator :@content, :[]=, :set!
    def_delegator :@content, :size, :length

    # Returns an Array instance which contains the vector contents.
    def to_a
      @content.dup
    end

    # Converts a string represents as a Scheme vector.
    def to_s
      "#(#{@content.join(' ')})"
    end

  end
end
