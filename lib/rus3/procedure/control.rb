# frozen_string_literal: true

module Rus3
  module Procedure
    module Control
      extend DebugUtils if Rus3.debug_mode?

      include Predicate
      include List

      # Returns a list of the results produced by applying the given
      # procedure (1st argument) to each element of the list (2nd
      # argument).
      #
      # The procedure to be applied is restricted to ones which
      # accepts only one argument.
      def map1(prc, lst)
        return EMPTY_LIST if null?(lst)
        cons(prc.call(car(lst)), map1(prc, cdr(lst)))
      end

      def zip2(lst1, lst2)
        prc = lambda{ |e| list(e, EMPTY_LIST) }
        if null?(lst2)
          map1(prc, lst1)
        elsif null?(lst1)
          map1(prc, lst2)
        else
          # something goes wrong...
          append(list(car(lst1), car(lst2)), zip2(cdr(lst1), cdr(lst2)))
        end
      end

      def zip(*lists)
        case lists.size
        when 0
          EMPTY_LIST
        when 1
          lists[0]
        else
          zip2(lists[0], zip(*lists[1..-1]))
        end
      end

      def map(prc, *lists)
        case lists.size
        when 0
          EMPTY_LIST
        when 1
          map1(prc, lists[0])
        else
          # TODO: convert to Array?
          args = lists[0].zip(lists[1..-1])
          map1(prc, args)
        end
      end
      module_function :map

      def for_each1(prc, lst)
        return EMPTY_LIST if null?(lst)
        prc.call(car(lst))
        for_each1(prc, cdr(lst))
        UNDEF
      end

      def for_each(prc, *lists)
        EMPTY_LIST
      end
      module_function :for_each

      def fold(prc, initial, lst)
        return initial if null?(lst)
        fold(prc, prc.call(initial, car(lst)), cdr(lst))
      end

    end
  end
end
