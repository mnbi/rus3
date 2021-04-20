# frozen_string_literal: true

require "test_helper"

class Rus3ProcedurePredicateTest < Minitest::Test
  include Rus3::Procedure::Predicate

  # list?

  def test_list_predicate_succeeds_against_a_proper_list
    lst = Array[1, 2, 3]
    assert list?(lst)
  end

  def test_list_predicate_fails_against_a_non_proper_list
    p = cp = Rus3::Pair.new(1)
    [2, 3, 4].each { |e|
      cp.set_cdr!(Rus3::Pair.new(e))
      cp = cp.cdr
    }
    cp.set_cdr!(5)

    refute list?(p)
  end

  def test_list_predicate_fails_other_than_a_list
    prepare_values_except(:list).each { |value|
      refute list?(value)
    }
  end

  # equivalence predicates
  def test_eqv_compares_object_values
    p0 = Rus3::Pair.new(1, 2)
    p1 = p0.clone
    assert eqv?(p0, p1)
  end

  def test_eq_compares_object_identities
    p0 = Rus3::Pair.new(10, 11)
    p1 = p0.clone
    refute eq?(p0, p1)
  end

  # value types

  # boolean

  def test_true_and_false_is_a_boolean
    assert boolean?(true)
    assert boolean?(false)
  end

  def test_boolean_fails_other_than_true_or_false
    prepare_values_except(:boolean).each { |value|
      refute boolean?(value)
    }
  end

  # pair

  def test_pair_succeeds_against_a_pair
    p = Rus3::Pair.new(20, 21)
    assert pair?(p)
  end

  def test_pair_fails_other_than_pair
    prepare_values_except(:pair).each { |value|
      refute pair?(value)
    }
  end

  # numbers

  def test_number_succeeds_against_a_number_in_various_types
    [
      65536,                    # integer
      Rational(11, 99),         # rational
      Math::PI,                 # real
      Complex(Rational(-1,2), Rational(Math.sqrt(3),2)), # complex
    ].each { |value|
      assert number?(value)
    }
  end

  def test_number_fails_other_than_number
    prepare_values_except(:number).each { |value|
      refute number?(value)
    }
  end

  # numeric types

  def test_complex_succeeds_against_all_numeric_types
    [
      65536,                    # integer
      Rational(11, 99),         # rational
      Math::PI,                 # real
      Complex(Rational(-1,2), Rational(Math.sqrt(3),2)), # complex
    ].each { |value|
      assert complex?(value)
    }
  end

  def test_complex_fails_other_than_number
    prepare_values_except(:number).each { |value|
      refute complex?(value)
    }
  end

  def test_real_succeeds_against_all_numerics_except_complex
    [
      65536,                    # integer
      Rational(11, 99),         # rational
      Math::PI,                 # real
    ].each { |value|
      assert real?(value)
    }
    refute real?(Complex(Rational(-1,2), Rational(Math.sqrt(3),2)))
  end

  def test_real_fails_other_than_number
    prepare_values_except(:number).each { |value|
      refute real?(value)
    }
  end

  def test_rational_succeeds_against_rational_and_integer
    assert rational?(2*32)
    assert rational?(Rational(100, 101))
    refute rational?(Math::PI * Math::PI)
    refute rational?(Complex(1.23, 45.6))
  end

  def test_rational_fails_other_than_number
    prepare_values_except(:number).each { |value|
      refute rational?(value)
    }
  end

  def test_integer_succeeds_against_only_integer
    assert integer?(2**32 - 1)
    [
      Rational(11, 99),         # rational
      Math::PI,                 # real
    ].each { |value|
      refute integer?(value)
    }
  end

  def test_integer_fails_other_than_number
    prepare_values_except(:number).each { |value|
      refute integer?(value)
    }
  end

  # particular numeric properties

  def test_zero_value
    assert zero?(0)
    assert zero?(0.0)
    assert zero?(Rational(0, 200))
    assert zero?(Complex(0, 0))
  end

  def test_zero_raise_an_error_other_than_number
    assert_raises(Rus3::NumberRequiredError) {
      prepare_values_except(:number).each { |value|
        zero?(value)
      }
    }
  end

  def test_positive_raises_an_error_other_than_real_number
    assert_raises(Rus3::RealNumberRequiredError) {
      prepare_values_except(:number).each { |value|
        positive?(value)
      }
      positive?(Complex(78.9, 10.11))
    }
  end

  def test_negative_raises_an_error_other_than_real_number
    assert_raises(Rus3::RealNumberRequiredError) {
      prepare_values_except(:number).each { |value|
        negative?(value)
      }
      negative?(Complex(12.13, 14.15))
    }
  end

  def test_odd_raises_an_error_other_than_integer
    assert_raises(Rus3::IntegerRequiredError) {
      prepare_values_except(:number).each { |value|
        odd?(value)
      }
      [
        Rational(11, 99),         # rational
        Math::PI,                 # real
        Complex(Rational(-1,2), Rational(Math.sqrt(3),2)), # complex
      ].each { |value|
        odd?(value)
      }
    }
  end

  def test_even_raises_an_error_other_than_integer
    assert_raises(Rus3::IntegerRequiredError) {
      prepare_values_except(:number).each { |value|
        even?(value)
      }
      [
        Rational(11, 99),         # rational
        Math::PI,                 # real
        Complex(Rational(-1,2), Rational(Math.sqrt(3),2)), # complex
      ].each { |value|
        even?(value)
      }
    }
  end

  # character
  # TODO: write tests when Char class was defined.

  # string

  def test_string_succeeds_against_string
    assert string?("foo")
  end

  def test_string_fails_other_than_string
    prepare_values_except(:string).each { |value|
      string?(value)
    }
  end

  # string comparison

  def test_string_predicate_raises_other_than_strings
    [
      :string_eq?,
      :string_ci_eq?,
      :string_lt?,
      :string_gt?,
      :string_le?,
      :string_ge?,
      :string_ci_lt?,
      :string_ci_gt?,
      :string_ci_le?,
      :string_ci_ge?,
    ].each { |predicate|
      assert_raises(Rus3::StringRequiredError) {
        m = method(predicate)
        m.call("foo", :bar)
      }
    }
  end

  # port
  # TODO: write tests when Port class was defined.

  private

  VALUES = {
    :boolean   => false,
    :pair      => Rus3::Pair.new(1, 2),
    :symbol    => :foo,
    :number    => Math::PI,
    :char      => :not_ready,
    :string    => "hoge",
    :vector    => :not_ready,
    :port      => :not_ready,
    :procedure => lambda{ |x| x * x },
  }

  def prepare_values_except(*except_types)
    VALUES.map{ |key, value|
      next if value == :not_ready
      value unless except_types.include?(key)
    }
  end

end
