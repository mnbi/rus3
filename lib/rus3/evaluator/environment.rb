# frozen_string_literal: true

module Rus3::Evaluator

  class Environment
    include Rus3::Procedure::Control
    include Rus3::Procedure::Write
    include Rus3::Procedure::Vector
    include Rus3::Procedure::List
    include Rus3::Procedure::Char
    include Rus3::Procedure::Predicate
    include Rus3::EmptyList

    attr_reader :binding

    def initialize
      @binding = Kernel.binding
    end

  end

end
