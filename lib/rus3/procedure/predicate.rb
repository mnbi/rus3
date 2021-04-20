# frozen_string_literal: true

module Rus3::Procedure

  module Predicate

    include Rus3::EmptyList

    # Returns true if the arguemnt represents a list structure.
    # Note that an empty list is a list.
    def list?(obj)
      obj.instance_of?(Array)
    end

    # :stopdoc:

    # Equivalence predicates:
    #
    # In R5RS, three equivalence predicates are defined such as eqv?,
    # eq? and equal?.
    #
    # `equal?` has been defined in Object class and the reference
    # manual says that this method must not re-defined.  So,
    # `equal?` is not defined here.

    # :startdoc:

    def eqv?(obj1, obj2)
      obj1 == obj2
    end

    def eq?(obj1, obj2)
      obj1.equal?(obj2)
    end

    # :stopdoc:

    # Value types:
    #
    # R5RS says "no objects satiscies more than one of the following
    # predicates".  That is, Scheme has 9 value types at least.
    #
    # Most of them have suitable types in Ruby built-in classes.  Rus3
    # provides some classes for the rest of them.
    #
    #   boolean? ---> FalseClass or TrueClass
    #   pair? ------> Rus3::Pair
    #   symbol? ----> Symbol
    #   number? ----> Numeric
    #   char? ------> Rus3::Char
    #   string? ----> String
    #   vector? ----> Array
    #   port? ------> Rus3::Port
    #   procedure? -> Proc

    # :startdoc:

    def boolean?(obj)
      obj.instance_of?(FalseClass) or obj.instance_of?(TrueClass)
    end

    def pair?(obj)
      obj.instance_of?(Array) or obj.instance_of?(Rus3::Pair)
    end

    def symbol?(obj)
      obj.is_a?(Symbol) && obj != Rus3::UNDEF
    end

    def number?(obj)
      obj.is_a?(Numeric)
    end

    def char?(obj)
      false
    end

    def string?(obj)
      obj.kind_of?(String)
    end

    def vector?(obj)
      false
    end

    def port?(obj)
      false
    end

    def procedure?(obj)
      obj.instance_of?(Proc)
    end

    # :startdoc:

    # :stopdoc:

    # Numeric types:
    #
    # Scheme has more predicates for number values.
    #
    #   complex
    #   real
    #   rational
    #   integer
    #
    # R5RS says, "Mathematically, numbers may be arranged into a tower
    # of subtypes in which each level is a subset of the level above
    # it:"
    #
    # That is, {integer} < {rational} < {real} < {complex}.

    # :startdoc:

    def complex?(num)
      num.is_a?(Complex) || real?(num)
    end

    def real?(num)
      num.is_a?(Float) || rational?(num)
    end

    def rational?(num)
      num.is_a?(Rational) || integer?(num)
    end

    def integer?(num)
      num.is_a?(Integer)
    end

    # :stopdoc:

    # Tests a number for a particular property.

    # :startdoc:

    def zero?(z)
      raise Rus3::NumberRequiredError, z unless number?(z)
      z.zero?
    end

    def positive?(r)
      raise Rus3::RealNumberRequiredError, r unless real?(r)
      r.positive?
    end

    def negative?(r)
      raise Rus3::RealNumberRequiredError, r unless real?(r)
      r.negative?
    end

    def odd?(n)
      raise Rus3::IntegerRequiredError, n unless integer?(n)
      n.odd?
    end

    def even?(n)
      raise Rus3::IntegerRequiredError, n unless integer?(n)
      n.even?
    end

    # :stopdoc:

    # Characters:
    #
    # ...

    # :startdoc:

    def char_eq?(char1, char2)
      false
    end

    def char_lt?(char1, char2)
      false
    end

    def char_gt?(char1, char2)
      false
    end

    def char_le?(char1, char2)
      false
    end

    def char_ge?(char1, char2)
      false
    end

    def char_ci_eq?(char1, char2)
      false
    end

    def char_ci_lt?(char1, char2)
      false
    end

    def char_ci_gt?(char1, char2)
      false
    end

    def char_ci_le?(char1, char2)
      false
    end

    def char_ci_ge?(char1, char2)
      false
    end

    def char_alphabetic?(char)
      false
    end

    def char_numeric?(char)
      false
    end

    def char_whitespace?(char)
      false
    end

    def char_upper_case?(letter)
      false
    end

    def char_lower_case?(letter)
      false
    end

    # :stopdoc:

    # Strings:

    # :startdoc:

    def check_string(*objs)
      objs.each { |obj|
        raise Rus3::StringRequiredError, obj unless string?(obj)
      }
    end
    private :check_string

    def string_eq?(str1, str2)
      check_string(str1, str2)
      str1 == str2
    end

    def string_ci_eq?(str1, str2)
      check_string(str1, str2)
      str1.downcase == str2.downcase
    end

    def string_lt?(str1, str2)
      check_string(str1, str2)
      str1 < str2
    end

    def string_gt?(str1, str2)
      check_string(str1, str2)
      str1 > str2
    end

    def string_le?(str1, str2)
      check_string(str1, str2)
      str1 <= str2
    end

    def string_ge?(str1, str2)
      check_string(str1, str2)
      str1 >= str2
    end

    def string_ci_lt?(str1, str2)
      check_string(str1, str2)
      str1.downcase < str2.downcase
    end

    def string_ci_gt?(str1, str2)
      check_string(str1, str2)
      str1.downcase > str2.downcase
    end

    def string_ci_le?(str1, str2)
      check_string(str1, str2)
      str1.downcase <= str2.downcase
    end

    def string_ci_ge?(str1, str2)
      check_string(str1, str2)
      str1.downcase >= str2.downcase
    end

    # :stopdoc:

    # Ports:

    # :startdoc:

    def input_port?(obj)
      false
    end

    def output_port?(obj)
      false
    end

  end
end
