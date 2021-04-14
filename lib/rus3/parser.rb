# frozen_string_literal: true

module Rus3

  module Parser
    # Indicates the version of the parser module.
    VERSION = "0.1.0"

    require_relative "parser/lexer"
    require_relative "parser/parser"
  end

end
