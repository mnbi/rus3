# frozen_string_literal: true

module Rus3
  module Procedure

    # The module holds list operation proceduress of Scheme.  Most of
    # those procedures are defined in R(n)RS (the specification of
    # Scheme language).
    #
    #   - R5RS 6.3.2 Pairs and lists
    #   - R7RS 6.4   Pairs and lists

    module List
      extend DebugUtils if Rus3.debug_mode?

      include Predicate
      include Rus3::EmptyList

      # Constructs a Pair object with arguments.
      #
      #   - R5RS procedure: (cons obj1 obj2)

      def cons(obj1, obj2)
        Pair.new(obj1, obj2)
      end

      # Returns the CAR part of the argument.  If the arguemnt is not
      # a pair, raises PairRequiredError.
      #
      #   - R5RS procedure: (car pair)

      def car(pair)
        check_pair(pair)
        pair.car
      end

      # Returns the CDR part of the argument.  If the arguemnt is not
      # a pair, raises PairRequiredError.
      #
      #   - R5RS procedure: (cdr pair)

      def cdr(pair)
        check_pair(pair)
        pair.cdr
      end

      # Replaces the CAR part with the 2nd argument and returns UNDEF.
      # If the 1st arguemnt is not a pair, raises PairRequiredError.
      #
      #   - R5RS procedure: (set-car! pair obj)

      def set_car!(pair, obj)
        check_pair(pair)
        pair.set_car!(obj)
        UNDEF
      end

      # Replaces the CDR part with the 2nd argument and returns UNDEF.
      # If the 1st arguemnt is not a pair, raises PairRequiredError.
      #
      #   - R5RS procedure: (set-cdr! pair obj)

      def set_cdr!(pair, obj)
        check_pair(pair)
        pair.set_cdr!(obj)
        UNDEF
      end

      # Retrieves the CAR part of the CAR part of the given pair.
      #
      #   - R5RS library procedure: (caar pair)
      #   - R7RS procedure: (caar pair)

      def caar(pair)
        car(car(pair))
      end

      # Retrieves the CAR part of the CDR part of the given pair.
      #
      #   - R5RS library procedure: (cadr pair)
      #   - R7RS procedure: (cadr pair)

      def cadr(pair)
        car(cdr(pair))
      end

      # Retrieves the CDR part of the CAR part of the given pair.
      #
      #   - R5RS library procedure: (cdar pair)
      #   - R7RS procedure: (cdar pair)

      def cdar(pair)
        cdr(car(pair))
      end

      # Retrieves the CDR part of the CDR part of the given pair.
      #
      #   - R5RS library procedure: (cddr pair)
      #   - R7RS procedure: (cddr pair)

      def cddr(pair)
        cdr(cdr(pair))
      end

      # :stopdoc:

      #    - R7RS: procedure: (make-list k)

      #    - R7RS: procedure: (make-list k fill)

      # :startdoc:

      # Constructs a list from arguments in its order.
      #
      #   - R5RS library procedure: (list obj ...)

      def list(*objs)
        Pair.list(*objs)
      end

      # Returns the length of the arguemnt.  If the argument is not a
      # proper list, raises ListRequiredError.
      #
      #   - R5RS library procedure: (length list)
      #   - R7RS procedure: (length list)

      def length(lst)
        check_list(lst)

        count = 0
        until null?(lst)
          count += 1
          lst = cdr(lst)
        end
        count
      end

      # Concatenates given lists into a single list.  Each argument
      # must be a proper list, otherwise raises ListRequiredError.
      #
      #   - R5RS library procedure: (append list ...)
      #   - R7RS procedure: (append list ...)

      def append(*lists)
        lists.each { |lst|
          check_list(lst)
        }

        case lists.size
        when 0
          EMPTY_LIST
        when 1
          lists[0]
        when 2
          append2(*lists)
        else
          append2(lists[0], append(*lists[1..-1]))
        end
      end

      # Returns a list of the same elements in reverse order.
      #
      #   - R5RS library procedure: (reverse list)
      #   - R7RS procedure: (reverse list)

      def reverse(lst)
        check_list(lst)

        if null?(lst)
          EMPTY_LIST
        else
          append2(reverse(cdr(lst)), list(car(lst)))
        end
      end

      # Returns the sublist of the arguemnt by omitting the first k
      # elements.  The 2nd argument, k must be in 0..length(lst),
      # otherwise raises OutOfRangeError.
      #
      # This implementation logic comes from R5RS 6.3.2.
      #
      #   - R5RS library procedure: (list-tail list k)
      #   - R7RS procedure: (list-tail list k)

      def list_tail(lst, k)
        check_list(lst)
        check_upper_limit(k, length(lst)+1)

        if zero?(k)
          lst
        else
          list_tail(cdr(lst), k - 1)
        end
      end

      # Returns kth element of the argument.  If the 2nd argument is
      # greater than length of the list, raises OutOfRangeError.
      #
      #   - R5RS library procedure: (list-ref list k)
      #   - R7RS procedure: (list-ref list k)

      def list_ref(lst, k)
        check_list(lst)

        car(list_tail(lst, k))
      end

      # :stopdoc:

      #   - R7RS procedure: (list-set! list k obj)

      # :startdoc:

      # :stopdpc:

      #   - R5RS library procedure: (memq obj list)
      #   - R7RS procedure: (memq obj list)

      #   - R5RS library procedure: (memv obj list)
      #   - R7RS procedure: (memv obj list)

      #   - R5RS library procedure: (member obj list)
      #   - R7RS procedure: (member obj list)

      #   - R7RS procedure: (member obj list compare)

      # :startdoc:

      # :stopdpc:

      #   - R5RS library procedure: (assq obj alist)
      #   - R7RS procedure: (assq obj alist)

      #   - R5RS library procedure: (assv obj alist)
      #   - R7RS procedure: (assv obj alist)

      #   - R5RS library procedure: (assoc obj alist)
      #   - R7RS procedure: (assoc obj alist)

      #   - R7RS procedure: (assoc obj alist compare)

      # :startdoc:

      # :stopdoc:

      #   - R7RS procedure: (list-copy obj)

      # :startdoc:

      private

      def check_pair(pair)      # :nodoc:
        raise PairRequiredError, pair unless pair?(pair)
      end

      def check_list(lst)       # :nodoc:
        raise ListRequiredError, lst unless list?(lst)
      end

      # To make sure the number is less than its upper limit.
      def check_upper_limit(k, limit) # :nodoc:
        raise OutOfRangeError, k if k >= limit
      end

      def append2(lst1, lst2)   # :nodoc:
        if null?(lst1)
          lst2
        else
          cons(car(lst1), append2(cdr(lst1), lst2))
        end
      end

    end
  end
end
