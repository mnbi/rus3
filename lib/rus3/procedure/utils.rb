# frozen_string_literal: true

module Rus3::Procedure
  module Utils

    def check_pair(pair)        # :nodoc:
      if !pair.instance_of?(Rus3::Pair) and !pair.instance_of?(Array)
        raise Rus3::PairRequiredError, pair
      end
    end

    def check_list(lst)         # :nodoc:
      raise Rus3::ListRequiredError, lst unless list?(lst)
    end

    def check_vector(obj)       # :nodoc:
      raise Rus3::VectorRequiredError, obj unless vector?(obj)
    end

    # To make sure the number is less than its upper limit.  When k
    # greater than or equal to limit, raises ExceedUpperLimitError.

    def check_upper_limit(k, limit)
      raise Rus3::ExceedUpperLimitError.new(k, limit) if k >= limit
    end

  end
end
