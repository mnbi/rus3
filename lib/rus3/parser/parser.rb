# frozen_string_literal: true

module Rus3::Parser

  # A parser.

  class Parser
    require "readline"

    include Rus3::EmptyList

    attr_accessor :prompt

    def initialize
      @prompt = ""
    end

    def read(io = STDIN)
      Readline::readline(@prompt, true)
    end

    def version
      "Parser version #{Rus3::Parser::VERSION}"
    end

  end

end
