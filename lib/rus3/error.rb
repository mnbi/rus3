# frozen_string_literal: true

module Rus3
  class Error < StandardError
    def actual(obj)
      Rus3::Procedure::Predicate.null?(obj) ? "()" : obj
    end
  end

  # :stopdoc:

  EMSG = {
    :pair_required => "pair required: got=%s",
    :list_required => "proper list required: got=%s",
    :out_of_range  => "argument out of range: got=%s",
  }

  # :startdoc:

  class PairRequiredError < Error
    def initialize(obj)
      super(EMSG[:pair_required] % actual(obj))
    end
  end

  class ListRequiredError < Error
    def initialize(obj)
      super(EMSG[:list_required] % actual(obj))
    end
  end

  class OutOfRangeError < Error
    def initialize(obj)
      super(EMSG[:out_of_range] % actual(obj))
    end
  end

end
