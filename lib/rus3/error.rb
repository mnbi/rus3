# frozen_string_literal: true

module Rus3
  class Error < StandardError
    include EmptyList

    def smart_error_value(obj)  # :nodoc:
      case obj
      when NilClass
        "()"
      when Numeric
        "number(%d)" % obj
      when Rus3::Pair
        if Rus3::Pair.list?(obj)
          # TODO: a list should be displayed as list not dot pairs.
          # It is better "write(obj)", if "write" is tested well.
          "list(%s)" % obj
        else
          "pair(%s)" % obj
        end
      else
        "%s(%s)" % [obj.class, obj]
      end
    end

  end

  # :stopdoc:

  EMSG = {
    :pair_required => "pair required: got=%s",
    :list_required => "proper list required: got=%s",
    :out_of_range  => "argument out of range: got=%s",
    :unsupported_method => "specified method does not work now.",
    :wrong_type => "wrong type argument: got=%s, wants=%s",
    :integer_required => "integer required: got=%s",
    :real_number_required => "real number required: got=%s",
    :number_required => "number required: got=%s",
    :string_required => "string required: got=%s",
  }

  # :startdoc:

  class PairRequiredError < Error
    def initialize(obj)
      super(EMSG[:pair_required] % smart_error_value(obj))
    end
  end

  class ListRequiredError < Error
    def initialize(obj)
      super(EMSG[:list_required] % smart_error_value(obj))
    end
  end

  class OutOfRangeError < Error
    def initialize(obj)
      super(EMSG[:out_of_range] % smart_error_value(obj))
    end
  end

  class UnsupportedMethodError < Error
    def initialize
      super(EMSG[:unsupported_method])
    end
  end

  class WrongTypeError < Error
    def initialize(obj, expected)
      emsg = EMSG[:wrong_type] % [obj, expected]
      super(emsg)
    end
  end

  class IntegerRequiredError < Error
    def initialize(obj)
      super(EMSG[:integer_required] % smart_error_value(obj))
    end
  end

  class RealNumberRequiredError < Error
    def initialize(obj)
      super(EMSG[:real_number_required] % smart_error_value(obj))
    end
  end

  class NumberRequiredError < Error
    def initialize(obj)
      super(EMSG[:number_required] % smart_error_value(obj))
    end
  end

  class StringRequiredError < Error
    def initialize(obj)
      super(EMSG[:string_required] % smart_error_value(obj))
    end
  end

end
