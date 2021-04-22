# frozen_string_literal: true

module Rus3::Procedure

  # The module holds list operation proceduress of Scheme.  Most of
  # those procedures are defined in R(n)RS (the specification of
  # Scheme language).
  #
  #   - R5RS 6.3.2 Pairs and lists
  #   - R7RS 6.4   Pairs and lists

  module List

    include Utils
    include Predicate
    include Rus3::EmptyList

    # Constructs a Pair object with arguments.
    #
    #   - procedure (R5RS): (cons obj1 obj2)

    def cons(obj1, obj2)
      case obj2
      when Rus3::Pair
        if null?(obj2.cdr)    # (foo . ())
          [obj1, obj2.car]
        else
          Rus3::Pair.new(obj1, obj2)
        end
      when Array
        [obj1].concat(obj2)
      else
        Rus3::Pair.new(obj1, obj2)
      end
    end

    # Returns the CAR part of the argument.  If the arguemnt is not
    # a pair, raises PairRequiredError.
    #
    #   - procedure (R5RS): (car pair)

    def car(pair)
      case pair
      when Rus3::Pair
        pair.car
      when Array
        raise Rus3::PairOrListRequiredError, pair if pair.empty?
        pair[0]
      else
        raise Rus3::PairOrListRequiredError, pair
      end
    end

    # Returns the CDR part of the argument.  If the arguemnt is not
    # a pair, raises PairRequiredError.
    #
    #   - procedure (R5RS): (cdr pair)

    def cdr(pair)
      case pair
      when Rus3::Pair
        pair.cdr
      when Array
        raise Rus3::PairOrListRequiredError, pair if pair.empty?
        pair[1..-1]
      else
        raise Rus3::PairOrListRequiredError, pair
      end
    end

    # Replaces the CAR part with the 2nd argument and returns UNDEF.
    # If the 1st arguemnt is not a pair, raises PairRequiredError.
    #
    #   - procedure (R5RS): (set-car! pair obj)

    def set_car!(pair, obj)
      case pair
      when Rus3::Pair
        pair.set_car!(obj)
      when Array
        pair[0] = obj
      else
        raise Rus3::PairOrListRequiredError, pair
      end
      Rus3::UNDEF
    end

    # Replaces the CDR part with the 2nd argument and returns UNDEF.
    # If the 1st arguemnt is not a pair, raises PairRequiredError.
    #
    #   - procedure (R5RS): (set-cdr! pair obj)

    def set_cdr!(pair, obj)
      case pair
      when Rus3::Pair
        pair.set_cdr!(obj)
      when Array
        case obj
        when Array
          pair.slice!(1, pair.size - 1)
          pair.concat(obj)
        else
          # If `obj` was not a proper list of Scheme, the result of
          # `set_cdr!` would be a Pair instance.  However, in this
          # case, the given `pair` is an Array instance, there is no
          # way to replace it with a new Pair instance.
          raise UnsupportedFeatureError.new("set_cdr!", obj)
        end
      else
        raise Rus3::PairOrListRequiredError, pair
      end
      Rus3::UNDEF
    end

    # Retrieves the CAR part of the CAR part of the given pair.
    #
    #   - library procedure (R5RS): (caar pair)
    #   - procedure (R7RS): (caar pair)

    def caar(pair)
      car(car(pair))
    end

    # Retrieves the CAR part of the CDR part of the given pair.
    #
    #   - library procedure (R5RS): (cadr pair)
    #   - procedure (R7RS): (cadr pair)

    def cadr(pair)
      car(cdr(pair))
    end

    # Retrieves the CDR part of the CAR part of the given pair.
    #
    #   - library procedure (R5RS): (cdar pair)
    #   - procedure (R7RS): (cdar pair)

    def cdar(pair)
      cdr(car(pair))
    end

    # Retrieves the CDR part of the CDR part of the given pair.
    #
    #   - libbrary procedure (R5RS): (cddr pair)
    #   - procedure (R7RS): (cddr pair)

    def cddr(pair)
      cdr(cdr(pair))
    end

    # :stopdoc:

    #    - procedure (R7RS): (make-list k)
    #    - procedure (R7RS): (make-list k fill)

    # :startdoc:

    # Constructs a list from arguments in its order.
    #
    #   - library procedure (R5RS): (list obj ...)

    def list(*objs)
      Array[*objs]
    end

    # Returns the length of the arguemnt.  If the argument is not a
    # proper list, raises ListRequiredError.
    #
    #   - library procedure (R5RS): (length list)
    #   - procedure (R7RS): (length list)

    def length(lst)
      check_list(lst)
      lst.size
    end

    # Concatenates given lists into a single list.  Each argument
    # must be a proper list, otherwise raises ListRequiredError.
    #
    #   - library procedure (R5RS): (append list ...)
    #   - procedure (R7RS): (append list ...)

    def append(*lists)
      lists.each { |lst|
        check_list(lst)
      }
      [].concat(*lists)
    end

    # Returns a list of the same elements in reverse order.
    #
    #   - library procedure (R5RS): (reverse list)
    #   - procedure (R7RS): (reverse list)

    def reverse(lst)
      check_list(lst)
      lst.sort {|a, b| b <=> a}
    end

    # Returns the sublist of the arguemnt by omitting the first k
    # elements.  The 2nd argument, k must be in 0..length(lst),
    # otherwise raises ExceedUppeerLimitError.
    #
    # This implementation logic comes from R5RS 6.3.2.
    #
    #   - library procedure (R5RS): (list-tail list k)
    #   - procedure (R7RS): (list-tail list k)

    def list_tail(lst, k)
      check_list(lst)
      check_upper_limit(k, length(lst)+1)

      lst.drop(k)
    end

    # Returns kth element of the argument.  k must be less than the
    # length of the list, otherwise, raises ExceedUppeerLimitError.
    #
    #   - library procedure (R5RS): (list-ref list k)
    #   - procedure (R7RS): (list-ref list k)

    def list_ref(lst, k)
      check_list(lst)
      check_upper_limit(k, length(lst))

      lst[k]
    end

    # :stopdoc:

    #   - procedure (R7RS): (list-set! list k obj)

    # :startdoc:

    # :stopdpc:

    #   - library procedure (R5RS): (memq obj list)
    #   - procedure (R7RS): (memq obj list)

    #   - library procedure (R5RS): (memv obj list)
    #   - procedure (R7RS): (memv obj list)

    #   - library procedure (R5RS): (member obj list)
    #   - procedure (R7RS): (member obj list)

    #   - procedure (R7RS): (member obj list compare)

    # :startdoc:

    # :stopdpc:

    #   - library procedure (R5RS): (assq obj alist)
    #   - procedure (R7RS): (assq obj alist)

    #   - library procedure (R5RS): (assv obj alist)
    #   - procedure (R7RS): (assv obj alist)

    #   - library procedure (R5RS): (assoc obj alist)
    #   - procedure (R7RS): (assoc obj alist)

    #   - procedure (R7RS): (assoc obj alist compare)

    # :startdoc:

    # :stopdoc:

    #   - procedure (R7RS): (list-copy obj)

    # :startdoc:

  end
end
