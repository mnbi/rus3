# frozen_string_literal: true

require "test_helper"

class Rus3PairTest < Minitest::Test
  include Rus3::EmptyList

  def test_it_can_be_instantiated_and_access_to_its_car_and_cdr
    p = Rus3::Pair.new(0, 1)
    refute_nil p
    assert_equal 0, p.car
    assert_equal 1, p.cdr
  end

  def test_it_can_be_instantiated_with_no_args
    p1 = Rus3::Pair.new
    refute_nil p1
    assert empty_list?(p1.car)
    assert empty_list?(p1.cdr)

    p2 = Rus3::Pair.new(2)
    refute_nil p2
    assert_equal 2, p2.car
    assert empty_list?(p2.cdr)
  end

  def test_it_can_replace_value_with_set_car
    p = Rus3::Pair.new(3, 4)
    p.set_car!(5)
    assert_equal 5, p.car
  end

  def test_it_can_replace_value_with_set_cdr
    p = Rus3::Pair.new(6, 7)
    p.set_cdr!(8)
    assert_equal 8, p.cdr
  end

  def test_it_can_check_sameness_to_other_pair
    p0 = Rus3::Pair.new(9, 10)
    p1 = Rus3::Pair.new(9, 10)
    p2 = Rus3::Pair.new(9)
    p3 = Rus3::Pair.new(9, 11)
    p4 = Rus3::Pair.new(10, 10)
    p5 = Rus3::Pair.new(11, 12)

    assert p0 == p1
    refute p0 == p2
    refute p0 == p3
    refute p0 == p4
    refute p0 == p5
  end

  def test_it_always_return_false_when_compare_to_other_type_object
    p0 = Rus3::Pair.new(13, 14)
    other = [13, 14]
    refute p0 == other
  end

  def test_it_can_be_converted_to_array
    p = Rus3::Pair.new(20, 21)
    assert_equal [20, 21], p.to_a
  end

  def test_it_generates_dot_notation
    p = Rus3::Pair.new(30, 31)
    assert_equal "(30 . 31)", p.to_s
  end

  def test_it_generates_the_notation_ommiting_empty_list_at_cdr
    p = Rus3::Pair.new(40)
    assert_equal "(40)", p.to_s
  end

  private

  def empty_list?(obj)
    null?(obj)
  end
end
