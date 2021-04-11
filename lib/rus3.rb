# frozen_string_literal: true

module Rus3
  def self.debug_mode?
    const_defined?(:RUS3_DEBUG) and ::RUS3_DEBUG
  end

  if debug_mode?
    puts "DEBUG mode (enable)"
    require_relative "debug_utils"
    extend DebugUtils
  end

  # An empty list is a special object in Scheme language.  The role
  # roughly corresponds to the one of 'nil' in Ruby.

  module EmptyList
    extend DebugUtils if Rus3.debug_mode?

    # Represents an empty list.
    EMPTY_LIST = nil

    # Returns true if the argument is an empty list.  RuS^3 treats nil
    # (an instance of NilClass) as an empty list.

    def null?(obj)
      obj.nil?
    end

  end

  # Indicates the values is not specified in the Scheme specification.
  # This value is intended using to be returned from procedures those
  # does not have any specified value as its return value.

  require "singleton"
  class Undef
    include Singleton

    def to_s
      "\#<undef>"
    end
  end
  UNDEF = Undef.instance

  require_relative "rus3/version"
  require_relative "rus3/error"

  require_relative "rus3/procedure/predicate"
  require_relative "rus3/procedure/list"
  require_relative "rus3/procedure/control"
  require_relative "rus3/procedure/write"

  require_relative "rus3/pair"
  require_relative "rus3/char"
  require_relative "rus3/port"

  include Procedure::Write
  include Procedure::Control
  include Procedure::List
  include Procedure::Predicate
  include EmptyList

  require_relative "rus3/repl"
end
