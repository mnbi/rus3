# frozen_string_literal: true

require "test_helper"

class Rus3UndefTest < Minitest::Test

  def test_it_has_an_instance
    undef_value = Rus3::Undef.instance
    refute undef_value.nil?
  end

  def test_it_can_convert_to_string
    undef_value = Rus3::Undef.instance
    assert_instance_of String, undef_value.to_s
  end

end
