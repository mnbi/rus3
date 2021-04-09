# frozen_string_literal: true

module Rus3

  # An enumerator to handle a Scheme list structure build with Pair
  # instances.  It also returns a Scheme list in calling '#map'.
  #
  # Use to define '#each' or '#map' in a Class which includes
  # Enumerable and holds a list structure.
  #
  #   class SomethingHoldsList
  #     include Enumerable

  #     def initialize(lst)
  #       @head_pair = lst
  #     end
  #
  #     def each(&block)
  #       enum = Rus3::PairEnumerator.new(@head_pair)
  #       block.nil? ? enum : enum.each(&block)
  #     end
  #
  #     def map(&block)
  #       enum = Rus3::PairEnumerator.new(@head_pair)
  #       block.nil? ? enum : enum.map(&block)
  #     end
  #   end
  #
  #   lst = Pair.list(1, 2, 3)
  #   foo = SomethingHoldsList.new(lst)
  #   foo.each { |e| puts e }
  #   # ==> 1
  #         2
  #         3
  #
  #   bar = foo.map { |e| e**2 }
  #   bar.to_s
  #   # ==> "(1 . (4 . (9)))"

  class PairEnumerator < Enumerator

    class << self
      include EmptyList

      # :call-seq:
      #   new(head_pair_of_list, size = nil) -> PairEnumerator
      #     - head_pair_of_list: Pair
      #     - size: Integer

      def new(head_pair, size = nil)
        super(size) { |y|
          cp, np = head_pair, head_pair.cdr
          loop {
            y.yield(cp.car)
            break if null?(np)
            cp, np = np, np.cdr
          }
        }
      end

      # Not implemented yet...
      def produce(initial = nil)
        raise UnsupportedMethodError
      end

    end

    # Applies 'block' to each element of the target list and returns
    # a list of the results.

    def map(&block)
      if block.nil?
        self
      else
        Pair.list(*entries.map(&block))
      end
    end
  end

  # A fundamental building block of a Scheme list structure.
  class Pair
    include Enumerable
    include Procedure::Predicate
    include EmptyList

    class << self
      include EmptyList

      # Returns true if the argument is an instance of Pair.

      def pair?(obj)
        obj.instance_of?(self)
      end

      # Constructs a Scheme list structure from Pair instances.  Each
      # argument will be an element of the list.  That is:
      #
      #   [obj1, obj2, obj3, ...] -> (obj1 obj2 obj3 ...)
      #
      # :call-seq:
      #   list(obj1, obj2, obj3) -> Pair (head pair of the list)

      def list(*objs)
        objs.reverse_each.reduce(EMPTY_LIST) { |r, obj|
          self.new(obj, r)
        }
      end

      # Distinguishes a proper list and non-proper one.
      #
      # For example:
      #   - Proper list: (1 . (2 . (3 . (4 . ()))))
      #   - Non-proper list: (1 . (2 . (3 . 4)))

      def list?(obj)
        if null?(obj)
          true
        elsif pair?(obj)
          cdr_part = obj.cdr
          cdr_part = cdr_part.cdr while pair?(cdr_part)
          null?(cdr_part)
        else
          false
        end
      end
    end

    # CAR part of the pair.
    attr_reader :car

    # CDR part of the pair.
    attr_reader :cdr

    # :call-seq:
    #   new(car, cdr) -> a new Pair object

    def initialize(car = EMPTY_LIST, cdr = EMPTY_LIST)
      @car = car
      @cdr = cdr
    end

    # Replaces the CAR part with the argument.

    def set_car!(obj)
      @car = obj
    end

    # Replaces the CDR part with the argument.

    def set_cdr!(obj)
      @cdr = obj
    end

    # Compares to an other pair.

    def ==(other)
      if other.instance_of?(Pair)
        @car == other.car && @cdr == other.cdr
      else
        raise WrongTypeError.new(other.class, Pair)
      end
    end

    # Applies the given block once for the CAR element, then follows
    # the CDR part and repeats to apply until an empty list is found
    # as CDR.
    #
    # If block is not given, returns an Enumerator object.

    def each(&block)
      enum = PairEnumerator.new(self)
      block.nil? ? enum : enum.each(&block)
    end

    # Original 'map' defined in Enumerator.
    define_method(:map_array, instance_method(:map))

    # Applies the given block once to the each CAR element, then
    # follows the CDR part and repests to apply until an empty list is
    # found as CDR.  Returns a list structure which elements is a
    # result of the appliction of the block.

    def map(&block)
      enum = PairEnumerator.new(self)
      block.nil? ? enum : enum.map(&block)
    end

    alias :map_list :map

    # Converts to an Array, which looks like as follows:
    #
    #   [CAR, CDR]

    def to_a
      [@car, @cdr]
    end

    # Converts to a String.  Normally, uses the dot-pair notaion which
    # looks like "(CAR . CDR)".  If the CDR part is an empty string,
    # looks like a normal list which has a single element, like
    # "(CAR)".

    def to_s
      car_part = null?(@car) ? "()" : @car
      if null?(@cdr)
        "(#{car_part})"
      else
        "(#{car_part} . #{@cdr})"
      end
    end
  end
end
