# frozen_string_literal: true

module DebugUtils

  # module hooks

  def included(mod)
    puts "- INCLUDED: #{mod} < #{self}"
  end

  def extended(mod)
    puts "- EXTENDED: #{mod} -> #{self}"
  end

end
