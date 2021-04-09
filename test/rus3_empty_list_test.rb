# coding: utf-8
# frozen_string_literal: true

require "test_helper"

class Rus3EmptyListTest < Minitest::Test
  include Rus3::EmptyList

  def test_it_has_a_predicate
    assert null?(EMPTY_LIST)
  end

  def test_null_predicate_returns_false_other_than_an_empty_list
    # boolean
    refute null?(true)
    refute null?(false)

    # pair
    refute null?(Rus3::Pair.new(1, 2))

    # number
    refute null?(1)
    refute null?(Rational(1, 9))
    refute null?(Math::PI)
    refute null?(Complex(Rational(-1,2), Rational(Math.sqrt(3),2)))

    # char
    # TODO: write tests when Char class was defined.

    # string
    refute null?("foo")
    refute null?("ほげ")

    # vector
    refute null?([1, 2, 3])

    # port
    # TODO: write tests when Port class was defined.

    # procedure
    refute null?(lambda{ |x| x ** x })
  end

end
