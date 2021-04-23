# coding: utf-8
# frozen_string_literal: true

require "test_helper"

class Rus3CharTest < Minitest::Test

  def test_it_can_be_instantiated
    ascii_ch = "a"
    ja_ch = "あ"

    ch0 = Rus3::Char.new(ascii_ch)
    refute ch0.nil?

    ch1 = Rus3::Char.new(ja_ch)
    refute ch1.nil?
  end

  def test_it_can_be_accessed_to_codepoint
    input = "b"
    ch = Rus3::Char.new(input)
    assert_equal input[0].ord, ch.codepoint
  end

  def test_it_can_be_accessed_to_encoding
    enc = Encoding::UTF_8
    input = "c".encode(enc)
    ch = Rus3::Char.new(input)
    assert_equal enc, ch.encoding
  end

  def test_it_can_be_compared_to_other_char
    ch0 = Rus3::Char.new("d")
    ch1 = Rus3::Char.new("e")
    assert (ch0 <= ch1)
  end

  def test_it_raises_when_comparing_to_other_class_instance
    ch = Rus3::Char.new("f")
    assert_raises(Rus3::CharRequiredError) {
      ch < "g"
    }
  end

  def test_it_can_be_converted_into_scheme_literal
    ch = Rus3::Char.new("h")
    assert_equal "#\\h", ch.to_literal
  end

  def test_it_can_be_converted_into_ruby_string
    ch = Rus3::Char.new("i")
    assert_equal "i", ch.to_s
  end

  # class methods

  def test_alphabetic_can_detect_alphabet
    alphabets = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    alphabets.each_char { |c|
      assert Rus3::Char.alphabetic?(Rus3::Char.new(c))
    }
  end

  def test_alphabetic_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.alphabetic?("A")
    }
  end

  def test_numeric_can_detect_digit
    digits = "0123456789"
    digits.each_char { |c|
      assert Rus3::Char.numeric?(Rus3::Char.new(c))
    }
  end

  def test_numeric_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.numeric?("0")
    }
  end

  def test_whitespace_can_detect_space_char
    spaces = " \t\r\n\f\v"
    spaces.each_char { |c|
      assert Rus3::Char.whitespace?(Rus3::Char.new(c))
    }
  end

  def test_whitespace_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.whitespace?(" ")
    }
  end

  def test_uppser_case_can_detect_upper_case_char
    uppers = "ABCDEFGHKJKLMNOPQRSTUVWXYZ"
    lowers = "abcdefghkjklmnopqrstuvwxyz"

    uppers.each_char { |c|
      assert Rus3::Char.upper_case?(Rus3::Char.new(c))
    }

    lowers.each_char { |c|
      refute Rus3::Char.upper_case?(Rus3::Char.new(c))
    }
  end

  def test_upper_case_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.upper_case?("A")
    }
  end

  def test_lower_case_can_detect_upper_case_char
    uppers = "ABCDEFGHKJKLMNOPQRSTUVWXYZ"
    lowers = "abcdefghkjklmnopqrstuvwxyz"

    uppers.each_char { |c|
      refute Rus3::Char.lower_case?(Rus3::Char.new(c))
    }

    lowers.each_char { |c|
      assert Rus3::Char.lower_case?(Rus3::Char.new(c))
    }
  end

  def test_lower_case_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.upper_case?("z")
    }
  end

  def test_char_to_integer_can_convert
    input = "a"
    ch = Rus3::Char.new(input)

    assert_equal input.ord, Rus3::Char.char_to_integer(ch)
  end

  def test_char_to_integer_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.char_to_integer("D")
    }
  end

  def test_integer_to_char_can_convert
    input = "Z"
    ch0 = Rus3::Char.new(input)

    assert_equal ch0, Rus3::Char.integer_to_char(input.ord)
  end

  def test_upcase_can_convert
    uppers = "ABCDEFGHKJKLMNOPQRSTUVWXYZ".chars
    lowers = "abcdefghkjklmnopqrstuvwxyz".chars

    lowers.each_with_index { |e, i|
      chu = Rus3::Char.new(uppers[i])
      chl = Rus3::Char.new(e)
      assert_equal chu, Rus3::Char.upcase(chl)
    }
  end

  def test_upcase_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.upcase("f")
    }
  end

  def test_downcase_can_convert
    uppers = "ABCDEFGHKJKLMNOPQRSTUVWXYZ".chars
    lowers = "abcdefghkjklmnopqrstuvwxyz".chars

    uppers.each_with_index { |e, i|
      chu = Rus3::Char.new(e)
      chl = Rus3::Char.new(lowers[i])
      assert_equal chl, Rus3::Char.downcase(chu)
    }
  end

  def test_downcase_raises_if_specified_other_than_char
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.downcase("G")
    }
  end

  def test_compare_chars_can_compare
    ops = [:==, :<, :>, :<=, :>=]
    char1 = Rus3::Char.new("H")
    char2 = Rus3::Char.new("i")
    expected = [false, true, false, true, false]

    ops.each_with_index { |op, i|
      result = Rus3::Char.compare_chars(char1, char2, op)
      assert_equal expected[i], result
    }
  end

  def test_compare_chars_raises_if_specified_other_than_char_as_1st_arg
    ch = Rus3::Char.new("j")
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.compare_chars("j", ch, :==)
    }
  end

  def test_compare_chars_raises_if_specified_other_than_char_as_2nd_arg
    ch = Rus3::Char.new("j")
    assert_raises(Rus3::CharRequiredError) {
      Rus3::Char.compare_chars(ch, "j", :==)
    }
  end

end
