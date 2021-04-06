# frozen_string_literal: true

module Rus3
  # A fundamental building block of a Scheme list structure.
  class Pair

    # CAR part of the pair.
    attr_reader :car

    # CDR part of the pair.
    attr_reader :cdr

    # :call-seq:
    #   new(car, cdr) -> a new Pair object
    def initialize(car, cdr)
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
      @car == other.car && @cdr == other.cdr
    end

    # Converts to an Array, which looks like as follows:
    #
    #   [CAR, CDR]
    #
    def to_a
      [@car, @cdr]
    end

    include Rus3::Procedure::Predicate

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
