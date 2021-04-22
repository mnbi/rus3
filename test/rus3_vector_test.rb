# frozen_string_literal: true

require "test_helper"

class Rus3VectorTest < Minitest::Test

  include Rus3::Procedure::List

  def test_it_can_be_instantiated_by_new
    vec = Rus3::Vector.new(3)
    refute vec.nil?
  end

  def test_it_can_refers_its_element_with_index
    k = 5
    fill = 8
    vec = Rus3::Vector.new(k, fill)
    0.upto(k - 1) { |i|
      assert_equal fill, vec.ref(i)
    }
  end

  def test_it_can_set_its_element_with_index
    k = 6
    fill = 9
    vec = Rus3::Vector.new(k, fill)
    0.upto(k - 1) { |i|
      vec.set!(i, fill + i)
      assert_equal fill + i, vec.ref(i)
    }
  end

  def test_it_can_get_its_length
    k = 7
    fill = 10
    vec = Rus3::Vector.new(k, fill)
    assert_equal k, vec.length
  end

  def test_it_can_be_made_by_vector_proc
    vec = Rus3::Vector.vector(1, "two", 3)
    refute vec.nil?
    assert_instance_of Rus3::Vector, vec
  end

  def test_it_can_be_made_from_a_list
    vec = Rus3::Vector.list_to_vector(list(4, 5, 6))
    refute vec.nil?
    assert_instance_of Rus3::Vector, vec
  end

  def test_it_can_be_converted_to_a_list
    vec = Rus3::Vector.new(5, 7)
    lst = Rus3::Vector.vector_to_list(vec)
    refute lst.nil?
    assert_instance_of Array, lst
  end

  def test_it_raises_if_exceeded_index_is_given_to_vector_set
    k = 8
    fill = 11
    vec = Rus3::Vector.new(k, fill)
    assert_raises(Rus3::ExceedUpperLimitError) {
      Rus3::Vector.vector_set!(vec, k, 0)
    }
  end

  def test_it_can_be_converted_to_an_array
    a = [100, 101, 102]
    vec = Rus3::Vector.vector(*a)
    b = vec.to_a
    refute b.nil?
    assert_instance_of Array, b
    a.each_with_index { |e, i|
      assert_equal e, b[i]
    }
  end

  def test_it_can_be_converted_to_an_string
    a = [110, 111, 112, 113, 114]
    vec = Rus3::Vector.vector(*a)
    str = vec.to_s

    assert_equal "#(", str[0..1]
    assert_equal ")", str[-1]

    elements = str[2..-2].split(" ")
    a.each_with_index { |e, i|
      assert_equal e.to_s, elements[i]
    }
  end

end
