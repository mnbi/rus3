# frozen_string_literal: true

module DebugUtils

  # module hooks

  def included(mod)
    super
    puts "- INCLUDED: #{mod} < #{self}"
  end

  def extended(mod)
    super
    puts "- EXTENDED: #{mod} -> #{self}"
  end

end
