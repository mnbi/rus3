# frozen_string_literal: true

module Rus3

  # An empty list is a special object in Scheme language.  The role
  # roughly corresponds to the one of 'nil' in Ruby.

  module EmptyList

    # Represents an empty list.
    EMPTY_LIST = []

    # Returns true if the argument is an empty list.  RuS^3 treats nil
    # (an instance of NilClass) as an empty list.

    def null?(obj)
      obj.instance_of?(Array) and obj.empty?
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

  require_relative "rus3/pair"
  require_relative "rus3/char"
  require_relative "rus3/port"
  require_relative "rus3/vector"

  require_relative "rus3/procedure/utils"
  require_relative "rus3/procedure/predicate"
  require_relative "rus3/procedure/char"
  require_relative "rus3/procedure/list"
  require_relative "rus3/procedure/vector"
  require_relative "rus3/procedure/control"
  require_relative "rus3/procedure/write"

  require_relative "rus3/ast"
  require_relative "rus3/token"
  require_relative "rus3/lexer"
  require_relative "rus3/parser"
  require_relative "rus3/evaluator"
  require_relative "rus3/printer"
  require_relative "rus3/repl"
end
