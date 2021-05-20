# frozen_string_literal: true

require "test_helper"

class Rus3EvaluatorTranslatorfTest < Minitest::Test

  def setup
    @parser = Rubasteme.parser
    @translator = Rus3::Evaluator::Translator.new
  end

  def test_it_can_translate_boolean
    tcs = { "#f" => "false", "#false" => "false",
            "#t" => "true", "#true" => "true", }
    assert_translate(tcs)
  end

  def test_it_can_translate_identifier
    tcs = { "foo" => "foo", "define" => "define", }
    assert_translate(tcs)
  end

  def test_it_can_translate_character
    tcs = { "\#\\a" => "Char.new(\"a\")", }
    assert_translate(tcs)
  end

  def test_it_can_translate_string
    tcs = { "hoge" => "hoge", }
    assert_translate(tcs)
  end

  def test_it_can_translate_peculiar_identifier
    tcs = { "+" => "test_plus" }
    @translator.add_procedure_map({"+" => "test_plus",})
    assert_translate(tcs)
  end

  def test_it_can_translate_list
    tcs = { "'(1 2 3)" => '[Integer("1"), Integer("2"), Integer("3")]',
            "'(1 (2 3) (4 (5 6) 7))" =>
            '[Integer("1"), [Integer("2"), Integer("3")], [Integer("4"), [Integer("5"), Integer("6")], Integer("7")]]', }
    assert_translate(tcs)
  end

  def test_it_can_translate_vector
    tcs = { "#(foo bar baz)" => "vector(foo, bar, baz)",
            "#(foo #(bar baz))" => "vector(foo, vector(bar, baz))", }
    assert_translate(tcs)
  end

  def test_it_can_translate_lambda_expression
    tcs = {
      "(lambda (x y) (list x y))" => "lambda{|x, y| list(x, y)}",
    }
    assert_translate(tcs)
  end

  def test_it_can_translate_procedure_call
    tcs = {
      "(list \"foo\" \"bar\")" => "list(\"foo\", \"bar\")",
      "((lambda (x y) (add x y)) 1 2)" =>
      "lambda{|x, y| add(x, y)}.call(Integer(\"1\"), Integer(\"2\"))"
    }
    assert_translate(tcs)
  end

  def test_it_can_translate_conditional
    tcs = {
      "(if (eqv? n 0) \"zero\")" => "if eqv?(n, Integer(\"0\")); \"zero\"; end",
      "(if (eqv? n 0) (write n) (write (add n n)))" =>
      "if eqv?(n, Integer(\"0\")); write(n); else; write(add(n, n)); end",
    }
    assert_translate(tcs)
  end

  def test_it_can_translate_assignment
    tcs = {
      "(set! x 1)" => "x = Integer(\"1\")",
      "(set! x (concat \"foo\" \"bar\"))" => "x = concat(\"foo\", \"bar\")",
    }
    assert_translate(tcs)
  end

  def test_it_can_translate_identifier_definition
    tcs = {
      "(define foo 3)" => "foo = Integer(\"3\")",
      "(define (foo x) (write x))" => "def foo(x); write(x); end",
    }
    assert_translate(tcs)
  end

  def test_ic_can_translate_cond
    tcs = {
      "(cond ((eqv? n 0) (write \"zero\")))" =>
      "if eqv?(n, Integer(\"0\")); write(\"zero\"); end",
      "(cond ((lt? n 0) (write \"negative\")) ((eqv? n 0) (write \"zero\")))" =>
      "if lt?(n, Integer(\"0\")); write(\"negative\"); elsif eqv?(n, Integer(\"0\")); write(\"zero\"); end",
      "(cond ((lt? n 0) (write \"negative\")) ((eqv? n 0) (write \"zero\")) (else (write \"positive\")))" =>
      "if lt?(n, Integer(\"0\")); write(\"negative\"); elsif eqv?(n, Integer(\"0\")); write(\"zero\"); else; write(\"positive\"); end",
    }
    assert_translate(tcs)
  end

  def test_it_can_translate_let
    tcs = {
      "(let ((x 1) (y 2)) (add x y))" =>
      "lambda{|x, y| add(x, y)}.call(Integer(\"1\"), Integer(\"2\"))",
    }
    assert_translate(tcs)
  end

  private

  def assert_translate(tcs)
    tcs.each { |src, expected|
      rb_src = @translator.translate(ast_node(src))
      assert_equal expected, rb_src
    }
  end

  def ast_node(src)
    lexer = Rbscmlex::Lexer.new(src)
    @parser.parse(lexer)[0]
  end

end
