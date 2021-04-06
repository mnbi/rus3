# frozen_string_literal: true

module Rus3
  module Procedure
    module List
      extend DebugUtils if Rus3.debug_mode?

      include Predicate

      # Constructs a Pair object with arguments.
      def cons(car, cdr)
        Pair.new(car, cdr)
      end
      module_function :cons

      def check_pair(pair)      # :nodoc:
        raise PairRequiredError, pair unless pair?(pair)
      end

      # Returns the CAR part of the argument.  If the arguemnt is not
      # a pair, raises PairRequiredError.
      def car(pair)
        check_pair(pair)
        pair.car
      end
      module_function :car

      # Returns the CDR part of the argument.  If the arguemnt is not
      # a pair, raises PairRequiredError.
      def cdr(pair)
        check_pair(pair)
        pair.cdr
      end
      module_function :cdr

      # Replaces the CAR part with the 2nd argument and returns UNDEF.
      # If the 1st arguemnt is not a pair, raises PairRequiredError.
      def set_car!(pair, obj)
        check_pair(pair)
        pair.set_car!(obj)
        UNDEF
      end
      module_function :set_car!

      # Replaces the CDR part with the 2nd argument and returns UNDEF.
      # If the 1st arguemnt is not a pair, raises PairRequiredError.
      def set_cdr!(pair, obj)
        check_pair(pair)
        pair.set_cdr!(obj)
        UNDEF
      end
      module_function :set_cdr!

      # Constructs a list from arguments in its order.
      def list(*objs)
        objs.reverse_each.reduce(nil) { |r, obj|
          cons(obj, r)
        }
      end
      module_function :list

      def append_2(lst1, lst2)
        if null?(lst1)
          lst2
        else
          cons(car(lst1), append_2(cdr(lst1), lst2))
        end
      end

      # Concatenates given lists into a single list.  Each argument
      # must be a proper list, otherwise raises ListRequiredError.
      def append(*lists)
        lists.each { |lst|
          raise ListRequiredError, lst unless list?(lst)
        }

        case lists.size
        when 0
          EMPTY_LIST
        when 1
          lists[0]
        when 2
          append_2(*lists)
        else
          append_2(lists[0], append(*lists[1..-1]))
        end
      end
      module_function :append

      # Returns the sublist of the arguemnt by omitting the first k
      # elements.  The 2nd argument, k must be in 0..(length(lst)-1).
      #
      # This implementation logic comes from R5RS 6.3.2.
      def list_tail(lst, k)
        raise ListRequiredError, lst unless list?(lst)
        raise OutOfRangeError, k if k >= length(lst)
        if zero?(k)
          lst
        else
          list_tail(cdr(lst), k - 1)
        end
      end
      module_function :list_tail

      # Returns kth element of the argument.
      def list_ref(lst, k)
        raise ListRequiredError, lst unless list?(lst)

        car(list_tail lst, k)
      end
      module_function :list_ref

      # Returns the length of the arguemnt.  If the argument is not a
      # proper list, raises ListRequiredError.
      def length(lst)
        raise ListRequiredError, lst unless list?(lst)
        count = 0
        until null?(lst)
          count += 1
          lst = cdr(lst)
        end
        count
      end
      module_function :length

      # Returns a list of the same elements in reverse order.
      def reverse(lst)
        raise ListRequiredError, lst unless list?(lst)
        if null?(lst)
          EMPTY_LIST
        else
          append_2(reverse(cdr(lst)), list(car(lst)))
        end
      end
      module_function :reverse

    end
  end
end
