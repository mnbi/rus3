# frozen_string_literal: true

require "test_helper"

class Rus3Test < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Rus3::VERSION
  end

  def test_undef_is_defined
    assert Rus3.const_defined?(:UNDEF, false)
  end
end
