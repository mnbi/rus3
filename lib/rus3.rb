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

  require_relative "rus3/version"
  require_relative "rus3/error"

  require_relative "rus3/procedure/predicate"
  require_relative "rus3/procedure/list"
  require_relative "rus3/procedure/control"
  require_relative "rus3/procedure/write"

  require_relative "rus3/pair"
  require_relative "rus3/char"
  require_relative "rus3/port"

  EMPTY_LIST = nil

  # Indicates the values is not specified in the Scheme specification.
  require "singleton"
  class Undef
    include Singleton

    def to_s
      "\#<undef>"
    end
  end
  UNDEF = Undef.instance


  include Procedure::Predicate
  include Procedure::List
  include Procedure::Control
  include Procedure::Write
end
