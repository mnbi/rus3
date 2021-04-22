# frozen_string_literal: true

require "test_helper"

class Rus3ProcedureListTest < Minitest::Test
  include Rus3::Procedure::List

  # cons

  def test_cons_can_create_a_new_pair
    p = cons(1, 2)
    assert_instance_of Rus3::Pair, p
  end

  # car

  def test_car_can_access_a_car_part_of_a_pair
    p = cons(3, 4)
    assert_equal 3, car(p)
  end

  def test_car_raises_an_error_against_non_pair
    assert_raises(Rus3::PairOrListRequiredError) {
      car(5)
    }
  end

  # cdr

  def test_cdr_can_access_a_cdr_part_of_a_pair
    p = cons(3, 4)
    assert_equal 4, cdr(p)
  end

  def test_cdr_raises_an_error_against_non_pair
    assert_raises(Rus3::PairOrListRequiredError) {
      cdr(6)
    }
  end

  # set_car!

  def test_set_car_replaces_car_part_of_given_pair
    p = cons(7, 8)
    set_car!(p, 9)
    assert_equal 9, car(p)
  end

  def test_set_car_raises_an_error_against_non_pair
    assert_raises(Rus3::PairOrListRequiredError) {
      set_car!(13, 14)
    }
  end

  # set_cdr!

  def test_set_cdr_replaces_cdr_part_of_given_pair
    p = cons(10, 11)
    set_cdr!(p, 12)
    assert_equal 12, cdr(p)
  end

  def test_set_cdr_raises_an_error_against_non_pair
    assert_raises(Rus3::PairOrListRequiredError) {
      set_cdr!(15, 16)
    }
  end

  # cxxr

  def test_caar_works
    assert_equal 100, caar(prepare_pair_of_pairs(100, 101, 102, 103))
  end

  def test_cadr_works
    assert_equal 106, cadr(prepare_pair_of_pairs(104, 105, 106, 107))
  end

  def test_cdar_works
    assert_equal 109, cdar(prepare_pair_of_pairs(108, 109, 110, 111))
  end

  def test_cddr_works
    assert_equal 115, cddr(prepare_pair_of_pairs(112, 113, 114, 115))
  end

  # list

  def test_list_constructs_a_list
    ary = [200, 201, 202]
    lst = list(*ary)
    p = lst
    ary.each { |e|
      assert_equal e, car(p)
      p = cdr(p)
    }
  end

  # length

  def test_length_returns_the_number_of_elements_in_a_list
    lst = prepare_list(210, 5)
    assert_equal 5, length(lst)
  end

  def test_length_raises_an_error_against_non_list
    assert_raises(Rus3::ListRequiredError) {
      length(211)
    }
  end

  def test_length_raises_an_error_against_non_proper_list
    # proper list: (1 . (2 . (3 . ())))
    # non proper list: (1 . (2 . (3 . 4)))
    p = Rus3::Pair.new(212, Rus3::Pair.new(213, Rus3::Pair.new(214, 215)))
    assert_raises(Rus3::ListRequiredError) {
      length(p)
    }
  end

  # append

  def test_append_constructs_a_list_from_2_lists
    ary = (300...300+10).to_a
    l1 = list(*ary[0..4])
    l2 = list(*ary[5..-1])
    result = append(l1, l2)
    p = result
    ary.each { |e|
      assert_equal e, car(p)
      p = cdr(p)
    }
  end

  def test_append_constructs_a_list_from_3_lists
    ary = (310...310+15).to_a
    l1 = list(*ary[0..2])
    l2 = list(*ary[3..9])
    l3 = list(*ary[10..-1])
    result = append(l1, l2, l3)
    p = result
    ary.each { |e|
      assert_equal e, car(p)
      p = cdr(p)
    }
  end

  def test_append_returns_empty_list_when_an_empty_list_is_passed
    assert null?(append(EMPTY_LIST))
  end

  def test_append_raises_an_error_when_arguments_includes_non_list
    l1 = prepare_list(320, 5)
    assert_raises(Rus3::ListRequiredError) {
      append(l1, 330)
    }
  end

  # reverse

  def test_reverse_make_a_list_in_reverse_ordeer
    ary = (400...400+20).to_a
    lst = list(*ary)
    result = reverse(lst)
    refute lst.equal?(result)   # make sure 2 lists are different object

    p = result
    ary.reverse.each { |e|
      assert_equal e, car(p)
      p = cdr(p)
    }
  end

  def test_reverse_returns_empty_list_when_an_empty_list_is_passed
    assert null?(reverse(EMPTY_LIST))
  end

  # list_tail

  def test_list_tail_returns_a_list_itself_when_specified_0
    lst = prepare_list(500, 5)
    result = list_tail(lst, 0)
    p = lst
    q = result
    until null?(p)
      assert_equal car(p), car(q)
      p = cdr(p)
      q = cdr(q)
    end
  end

  def test_list_tail_returns_an_empty_list_when_specified_length
    lst = prepare_list(510, 6)
    result = list_tail(lst, 6)
    assert null?(result)
  end

  def test_list_tail_raises_an_error_when_2nd_argument_is_greather_than_length
    size = 7
    lst = prepare_list(520, size)
    assert_raises(Rus3::ExceedUpperLimitError) {
      list_tail(lst, size + 1)
    }
  end

  def test_list_tail_returns_a_sublist
    ary = (530...530 + 8).to_a
    lst = list(*ary)
    k = 4
    result = list_tail(lst, k)
    p = result

    until null?(p)
      assert ary[k], car(p)
      p = cdr(p)
    end
  end

  # list_ref

  def test_list_ref_returns_an_element_in_a_given_list
    size = 9
    lst = prepare_list(540, size)
    p = lst
    0.upto(size - 1) { |i|
      assert_equal car(p), list_ref(lst, i)
      p = cdr(p)
    }
  end

  def test_list_ref_raises_when_specified_larger_than_length_of_the_list
    size = 10
    lst = prepare_list(550, size)
    assert_raises(Rus3::ExceedUpperLimitError) {
      list_ref(lst, size + 1)
    }
  end

  private

  def prepare_pair_of_pairs(a, b, c, d)
    Rus3::Pair.new(Rus3::Pair.new(a, b), Rus3::Pair.new(c, d))
  end

  def prepare_list(initial, size)
    (initial...initial+size).to_a
  end

end
