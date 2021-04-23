# frozen_string_literal: true

require "test_helper"

class Rus3ParserLexerTest < Minitest::Test

  # boolean

  def test_it_can_detect_f
    tcs = ["#f"]
    assert_token_type(tcs, :boolean)
  end

  def test_it_can_detect_t
    tcs = ["#t"]
    assert_token_type(tcs, :boolean)
  end

  # identifier

  def test_it_can_detect_identifier
    tcs = ["foo", "bar", "hoge"]
    assert_token_type(tcs, :ident)
  end

  def test_it_can_distinguish_keyword
    tcs = ["if", "define"]
    refute_token_type(tcs, :ident)
  end

  # char

  def test_it_can_detect_char
    tcs = ["#\\a", "#\\space", "#\\newline"]
    assert_token_type(tcs, :char)
  end

  # string

  def test_it_can_detect_a_string
    tcs = ["\"foo\"", "\"bar-hoge\""]
    assert_token_type(tcs, :string)
  end

  # numbers

  def test_it_can_detect_integer_as_number
    tcs = ["123456", "0", "123456789012345678901234567890"]
    assert_token_type(tcs, :number)
  end

  def test_it_can_detect_integer_ignoring_whitespaces
    tcs = ["  123456   "]
    assert_token_type(tcs, :number)
  end

  def test_it_can_detect_real_number_as_number
    tcs = ["123,456", "-3.14", "0.101", "+0.0001"]
    assert_token_type(tcs, :number)
  end

  def test_it_can_detect_rational_as_number
    tcs = ["1/2", "-2/3", "3.14/6.28", "0.9/0.001"]
    assert_token_type(tcs, :number)
  end

  def test_it_can_detect_complex_as_number
    tcs = ["1+2i", "-2+3i", "4-5i", "-6-7i", "+8.9i", "-10.11i", "2/3+4/5i"]
    assert_token_type(tcs, :number)
  end

  # keywords

  def test_it_can_detect_keyword_if
    tcs = ["if"]
    assert_token_type(tcs, :if)
  end

  def test_it_can_detect_keyword_define
    tcs = ["define"]
    assert_token_type(tcs, :define)
  end

  # parenthesis

  def test_it_can_detect_lparen
    l = Rus3::Parser::Lexer.new("(")
    token = l.next

    assert_equal :lparen, token.type
    assert_equal "[", token.literal
  end

  def test_it_can_detect_rparen
    l = Rus3::Parser::Lexer.new(")")
    token = l.next

    assert_equal :rparen, token.type
    assert_equal "]", token.literal
  end

  # vector litral

  def test_it_can_detect_vector_lpraen
    l = Rus3::Parser::Lexer.new("#(")
    token = l.next

    assert_equal :vec_lparen, token.type
    assert_equal "#[", token.literal
  end

  # compound test

  def test_it_can_detect_tokens_properly
    input = "(define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))"
    expected_tokens = [
      :lparen,
      :define,
      :lparen,
      :ident,   # fact
      :ident,   # n
      :rparen,
      :lparen,
      :if,
      :lparen,
      :op_proc, # =
      :ident,   # n
      :number,  # 0
      :rparen,
      :number,  # 1
      :lparen,
      :op_proc, # *
      :ident,   # n
      :lparen,
      :ident,   # fact
      :lparen,
      :op_proc, # -
      :ident,   # n
      :number,  # 1
      :rparen,
      :rparen,
      :rparen,
      :rparen,
      :rparen,
    ]
    l = Rus3::Parser::Lexer.new(input)
    expected_tokens.each { |expected|
      token = l.next
      assert_equal expected, token.type
    }
  end

  # replace extended characters

  def test_it_can_convert_comparison_chars
    test_cases = {
      "char=?" => "char_eq?",
      "char<?" => "char_lt?",
      "char>?" => "char_gt?",
      "char<=?" => "char_le?",
      "char>=?" => "char_ge?",
      "char-ci=?" => "char_ci_eq?",
      "char-ci<?" => "char_ci_lt?",
      "char-ci>?" => "char_ci_gt?",
      "char-ci<=?" => "char_ci_le?",
      "char-ci>=?" => "char_ci_ge?",
    }
    test_cases.each { |input, expected|
      l = Rus3::Parser::Lexer.new(input)
      token = l.next
      assert_equal :ident, token.type
      assert_equal expected, token.literal
    }
  end

  private

  def assert_token_type(test_cases, expected_type)
    test_cases.each { |input|
      l = Rus3::Parser::Lexer.new(input)
      token = l.next
      assert_equal expected_type, token.type
      assert_equal input.rstrip.lstrip, token.literal
    }
  end

  def refute_token_type(test_cases, expected_type)
    test_cases.each { |input|
      l = Rus3::Parser::Lexer.new(input)
      token = l.next
      refute_equal expected_type, token.type
      assert_equal input.rstrip.lstrip, token.literal
    }
  end

end
