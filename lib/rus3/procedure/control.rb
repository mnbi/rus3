# frozen_string_literal: true

module Rus3
  module Procedure
    module Control
      extend DebugUtils if Rus3.debug_mode?

      include Predicate
      include List

      def map1(proc, lst)
        return EMPTY_LIST if null?(lst)
        cons(proc.call(car(lst)), map1(proc, cdr(lst)))
      end

      def zip_2(lst1, lst2)
        proc = lambda{ |e| list(e, EMPTY_LIST) }
        if null?(lst2)
          map1(proc, lst1)
        elsif null?(lst1)
          map1(proc, lst2)
        else
          # something goes wrong...
          append(list(car(lst1), car(lst2)), zip_2(cdr(lst1), cdr(lst2)))
        end
      end

      def zip(*lists)
        case lists.size
        when 0
          EMPTY_LIST
        when 1
          lists[0]
        else
          zip_2(lists[0], zip(*lists[1..-1]))
        end
      end

      def map(proc, *lists)
        case lists.size
        when 0
          EMPTY_LIST
        when 1
          map1(proc, lists[0])
        else
          # TODO: convert to Array?
          args = lists[0].zip(lists[1..-1])
          map1(proc, args)
        end
      end
      module_function :map

    end
  end
end
