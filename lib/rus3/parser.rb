# frozen_string_literal: true

module Rus3

  # A parser.

  class Parser
    require "readline"

    # Indicates the version of the parser class.
    VERSION = "0.1.0"

    include EmptyList

    attr_accessor :prompt

    def initialize
      @prompt = ""
    end

    def read(io = STDIN)
      Readline::readline(@prompt, true)
    end

    def version
      "Parser version #{VERSION}"
    end

  end
end
