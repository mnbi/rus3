# frozen_string_literal: true

require "test_helper"

class Rus3ProcedureVectorTest < Minitest::Test

  include Rus3::Procedure::Vector

  def test_new_vector_can_be_made_by_make_vecor_proc
    k = 3
    vec = make_vector(k)
    refute vec.nil?
    0.upto(k - 1) { |i|
      assert_equal UNDEF, vec.ref(i)
    }
  end

  def test_new_vector_can_be_made_by_vector_proc
    ary = [100, 101, 102, 103]
    vec = vector(*ary)
    ary.each_with_index { |e, i|
      assert_equal e, vec.ref(i)
    }
  end

  def test_vector_length_works_to_a_vector
    k = 5
    vec = Rus3::Vector.new(k)
    assert_equal k, vector_length(vec)
  end

  def test_each_element_can_be_referred_by_vector_ref
    k = 6
    fill = 200
    vec = Rus3::Vector.new(k, fill)
    1.upto(k).each {|i| vec.set!(i, fill + i)}

    0.upto(k - 1).each { |i|
      assert_equal (fill + i), vector_ref(vec, i)
    }
  end

  def test_each_element_can_be_set_by_vector_set
    k = 7
    fill = 300
    vec = Rus3::Vector.new(k, fill)

    0.upto(k - 1).each { |i|
      vector_set!(vec, i, fill + i)
      assert_equal (fill + i), vec.ref(i)
    }
  end

  def test_vector_to_list_can_convert_a_whole_vector
    k = 8
    fill = 400
    vec = Rus3::Vector.new(k, fill)
    0.upto(k - 1).each {|i| vec.set!(i, fill + i)}

    lst = vector_to_list(vec)
    0.upto(k - 1).each { |i|
      assert_equal (fill + i), car(lst)
      lst = cdr(lst)
    }
  end

  def test_vector_to_list_can_make_a_list_from_a_part_of_vector
    k = 9
    fill = 500
    vec = Rus3::Vector.new(k, fill)
    0.upto(k - 1).each {|i| vec.set!(i, fill + i)}

    lst = vector_to_list(vec, 1, k - 1)
    1.upto(k - 2).each { |i|
      assert_equal (fill + i), car(lst)
      lst = cdr(lst)
    }
  end

  def test_vector_to_list_raises_when_a_given_index_exceeds
    k = 10
    vec = Rus3::Vector.new(k)
    assert_raises(Rus3::ExceedUpperLimitError) {
      vector_to_list(vec, k, k)
    }
  end

  def test_list_to_vector_can_convert_a_list
    ary = [600, 601, 602, 603, 604]
    lst = list(*ary)
    vec = list_to_vector(lst)
    ary.each_with_index { |e, i|
      assert_equal e, vec.ref(i)
    }
  end

  def test_vector_fill_can_fill_a_whole_vector_elements
    k = 11
    fill = 700
    vec = Rus3::Vector.new(k)

    vector_fill!(vec, fill)

    0.upto(k - 1).each { |i|
      assert_equal fill, vec.ref(i)
    }
  end

  def test_vector_fill_can_fill_a_part_of_vector
    k = 12
    fill = 800
    vec = Rus3::Vector.new(k)

    s = 1
    e = k - 1

    vector_fill!(vec, fill, s, e)

    refute_equal fill, vec.ref(0)
    s.upto(e - 1).each { |i|
      assert_equal fill, vec.ref(i)
    }
    refute_equal fill, vec.ref(k - 1)
  end

  def test_vector_fill_raises_when_a_given_index_exceeds
    k = 13
    vec = Rus3::Vector.new(k)
    assert_raises(Rus3::ExceedUpperLimitError) {
      vector_fill!(vec, 0, k - 1, 0)
    }
  end

end
