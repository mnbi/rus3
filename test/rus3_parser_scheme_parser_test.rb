# coding: utf-8
# frozen_string_literal: true

require "test_helper"

class Rus3ParserSchemeParserTest < Minitest::Test
  def setup
    @parser = Rus3::Parser::SchemeParser.new
  end

  def test_it_can_translate_an_empty_list
    expected = { "()" => "[]", }
    assert_expected(expected)
  end

  def test_it_can_translate_a_variable_reference
    expected = { "foo" => "foo", }
    assert_expected(expected)
  end

  def test_it_can_translate_literal_boolean
    expected = {
      "#f" => "false",
      "#t" => "true",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_literal_string
    expected = { '"hoge"' => '"hoge"', '"りすぷ"' => '"りすぷ"', }
    assert_expected(expected)
  end

  def test_it_can_translate_litral_number
    expected = {
      "123"         => "123",            # integer
      Math::PI.to_s => Math::PI.to_s,    # real
      "4/5"         => "Rational(4, 5)", # rational
      "6+7i"        => "6+7i",           # complex
    }
    assert_expected(expected)
  end

  def test_it_can_translate_op_proc_call
    expected = {
      "(+ 1 2)"    => "add(1, 2)",
      "(- 3 4)"    => "subtract(3, 4)",
      "(* 5 6)"    => "mul(5, 6)",
      "(/ 7 8)"    => "div(7, 8)",
      "(% 9 2)"    => "mod(9, 2)",
      "(< 10 11)"  => "lt?(10, 11)",
      "(<= 12 13)" => "le?(12, 13)",
      "(> 14 15)"  => "gt?(14, 15)",
      "(>= 16 17)" => "ge?(16, 17)",
      "(= 18 19)"  => "eqv?(18, 19)",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_proc_call
    expected = { "(fact-iter 5 1 1)" => "fact_iter(5, 1, 1)", }
    assert_expected(expected)
  end

  def test_it_can_translate_apply_lambda_exp
    expected = {
      "((lambda (x) (+ x 2)) 4)" => "lambda {|x| add(x, 2)}.call(4)",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_lambda_exp
    expected = {
      "(lambda (x) (* x 2))" => "lambda {|x| mul(x, 2)}",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_if_exp
    expected = {
      "(if (= n 0) 1 (* n (- n 1)))" =>
      "if eqv?(n, 0); 1; else; mul(n, subtract(n, 1)); end",
      "(if (< 2 3) \"less\")" => "if lt?(2, 3); \"less\"; end",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_assignment_exp
    expected = { "(set! x 2)" => "x = 2", }
    assert_expected(expected)
  end

  def test_it_can_translate_define_proc
    expected = {
      "(define (fact n) (if (= n 0) 1 (* n (fact (- n 1)))))" =>
      "def fact(n); if eqv?(n, 0); 1; else; mul(n, fact(subtract(n, 1))); end; end",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_cond_exp
    expected = {
      "(cond ((> 3 2) \"greater\") ((< 3 2) \"less\") (else \"equal\"))" =>
      "if gt?(3, 2); \"greater\"; elsif lt?(3, 2); \"less\"; else; \"equal\"; end",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_let_exp
    expected = {
      "(let ((x 2) (y 3)) (* x y))" =>
      "lambda {|x, y| mul(x, y)}.call(2, 3)",
    }
    assert_expected(expected)
  end

  def test_it_can_translate_multiple_expressions
    expected = {
      "(+ 1 2) (* 3 4)" => "add(1, 2)\nmul(3, 4)",
    }
    assert_expected(expected)
  end

  private

  def assert_expected(expected)
    expected.each { |k, v|
      r_exp = @parser.parse(k)
      assert_equal v, r_exp
    }
  end

end
