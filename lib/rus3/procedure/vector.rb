# frozen_string_literal: true

module Rus3::Procedure

  # Provides procedures to operate a vector.

  module Vector

    include Utils
    include List
    include Predicate
    include Rus3::EmptyList

    UNDEF = Rus3::UNDEF

    #   - procedure (R5RS/R7RS): (make-vector k) or (make-vector k fill)

    def make_vector(k, fill = UNDEF)
      Rus3::Vector.new(k, fill)
    end

    #   - library procedure (R5RS/R7RS): (vector obj ...)

    def vector(*objs)
      Rus3::Vector.vector(*objs)
    end

    #   - procedure (R5RS/R7RS): (vector-length vector)

    def vector_length(vec)
      check_vector(vec)
      vec.length
    end

    #   - procedure (R5RS/R7RS): (vector-ref vector, k)

    def vector_ref(vec, k)
      check_vector(vec)
      check_upper_limit(k, vec.length)
      vec.ref(k)
    end

    #   - procedure (R5RS/R7RS): (vector-set! vector k obj)

    def vector_set!(vec, k, obj)
      check_vector(vec)
      Rus3::Vector.vector_set!(vec, k, obj)
    end

    #   - library procedure (R5RS): (vector->list vector)
    #   - procedure (R7RS):
    #       (vector->list vector)
    #       (vector->list vector start)
    #       (vector->list vector start end)

    def vector_to_list(vec, start_index = 0, end_index = -1)
      end_index = vec.length if end_index == -1

      check_vector(vec)
      check_limits(start_index, end_index, vec.length)

      list(*vec.ref(start_index...end_index))
    end

    #   - library procedure (R5RS): (list->vector list)
    #   - procedre (R7RS): (list->vector list)

    def list_to_vector(lst)
      Rus3::Vector.list_to_vector(lst)
    end

    #   - library procedure (R5RS): (vector-fill! vector fill)
    #   - procedure (R7RS): (vector-fill! vector fill start end)

    def vector_fill!(vec, fill, start_index = 0, end_index = -1)
      end_index = vec.length if end_index == -1

      check_vector(vec)
      check_limits(start_index, end_index, vec.length)

      start_index.upto(end_index - 1) {|i| vec.set!(i, fill)}
    end

    # :stopdoc:

    private

    # Makes sure that start_index < end_index <= limit.
    def check_limits(start_index, end_index, limit)
      check_upper_limit(start_index, limit)
      check_upper_limit(start_index, end_index)
      check_upper_limit(end_index, limit + 1)
    end

    # :startdoc:

  end
end
