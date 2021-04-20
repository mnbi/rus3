# frozen_string_literal: true

module Rus3::Procedure
  module Control

    include Predicate
    include Rus3::EmptyList

    def map(prc, *lists)
      case lists.size
      when 0
        EMPTY_LIST
      when 1
        raise Rus3::ListRequiredError, lists[0] unless list?(lists[0])
        lists[0].map(&prc)
      else
        zip(*lists).map {|args|
          prc.call(*args)
        }
      end
    end

    def zip(*lists)
      case lists.size
      when 0
        EMPTY_LIST
      when 1
        lists[0]
      else
        lists[0].zip(*lists[1..-1])
      end
    end

  end
end
