# frozen_string_literal: true

require "test_helper"

class Rus3PairTest < Minitest::Test
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

  def test_it_raise_when_compare_to_other_type_object
    p0 = Rus3::Pair.new(13, 14)
    other = [13, 14]
    assert_raises(Rus3::WrongTypeError) {
      p0 == other
    }
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

  def test_a_list_can_be_constructed
    lst = Rus3::Pair.list(100, 101, 102)
    refute_nil(lst)
    assert_equal 100, lst.car
    assert_instance_of Rus3::Pair, lst.cdr
    assert_equal 101, lst.cdr.car
    assert_instance_of Rus3::Pair, lst.cdr.cdr
    assert_equal 102, lst.cdr.cdr.car
    assert empty_list?(lst.cdr.cdr.cdr)
  end

  def test_a_list_is_enumerable_each
    ary = [110, 111, 112, 113]
    lst = Rus3::Pair.list(*ary)
    i = 0
    lst.each { |e|
      assert_equal ary[i], e
      i += 1
    }
  end

  def test_map_constructs_a_list
    ary = [120, 121, 122, 123, 124]
    lst = Rus3::Pair.list(*ary)
    result = lst.map{ |e| e*2 }
    assert_instance_of Rus3::Pair, result
    i = 0
    cp = result
    until empty_list?(cp)
      assert_equal ary[i]*2, cp.car
      i += 1
      cp = cp.cdr
    end
  end

  def test_map_array_construct_an_arry
    ary = [130, 131, 132, 133, 134, 135]
    lst = Rus3::Pair.list(*ary)
    result = lst.map_array{ |e| e*3 }
    assert_instance_of Array, result
    result.each_with_index { |e, i|
      assert_equal ary[i]*3, e
    }
  end

  private

  def empty_list?(obj)
    Rus3::EmptyList::EMPTY_LIST == obj
  end
end
