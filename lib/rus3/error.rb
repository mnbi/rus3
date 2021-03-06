# frozen_string_literal: true

module Rus3
  class Error < StandardError
    include EmptyList

    def smart_error_value(obj)  # :nodoc:
      case obj
      when Array
        if obj.empty?           # an empty list
          "()"
        else                    # a normal proper list
          list_notation = obj.to_s().gsub(/[\[\],]/, A2L_MAP)
          "list( %s )" % list_notation
        end
      when Numeric
        "number(%d)" % obj
      when Rus3::Pair
        "pair(%s)" % obj
      when Rus3::Vector
        "vector(%s)" % obj
      else
        "%s(%s)" % [obj.class, obj]
      end
    end

    A2L_MAP = { "[" => "(", "," => "", "]" => ")"} # :nodoc:
  end

  # :stopdoc:

  EMSG = {
    :number_required => "number required: got=%s",
    :integer_required => "integer required: got=%s",
    :real_number_required => "real number required: got=%s",
    :char_required => "char required: got=%s",
    :string_required => "string required: got=%s",
    :vector_required => "vector required: got=%s",
    :pair_required => "pair required: got=%s",
    :list_required => "proper list required: got=%s",
    :pair_or_list_required => "pair or proper list required: got=%s",
    :out_of_range  => "argument out of range: got=%s",
    :exceed_upper_limit => "argument exceeds its upper limit (%d): got=%d",
    :wrong_type => "wrong type argument: got=%s, wants=%s",
    :scheme_syntax_error => "syntax error as Scheme: got=%s",
    :unsupported_method => "specified method does not work now.",
    :unsupported_feature => "specified feature (`%s`) does not support for %s",
    :cannot_find_file => "cannot find %s",
    :not_implemented_yet => "not implemented yet (%s)",
    :unknown_operator => "unknown operator: got=%s",
  }

  # :startdoc:

  class NumberRequiredError < Error
    def initialize(obj)
      super(EMSG[:number_required] % smart_error_value(obj))
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

  class CharRequiredError < Error
    def initialize(obj)
      super(EMSG[:char_required] % smart_error_value(obj))
    end
  end

  class StringRequiredError < Error
    def initialize(obj)
      super(EMSG[:string_required] % smart_error_value(obj))
    end
  end

  class VectorRequiredError < Error
    def initialize(obj)
      super(EMSG[:vector_required] % smart_error_value(obj))
    end
  end

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

  class PairOrListRequiredError < Error
    def initialize(obj)
      super(EMSG[:pair_or_list_required] % smart_error_value(obj))
    end
  end

  class OutOfRangeError < Error
    def initialize(obj)
      super(EMSG[:out_of_range] % smart_error_value(obj))
    end
  end

  class ExceedUpperLimitError < Error
    def initialize(value, limit)
      super(EMSG[:exceed_upper_limit] % [limit, value])
    end
  end

  class WrongTypeError < Error
    def initialize(obj, expected)
      emsg = EMSG[:wrong_type] % [obj, expected]
      super(emsg)
    end
  end

  class SchemeSyntaxError < Error
    def initialize(obj)
      super(EMSG[:scheme_syntax_error] % "#{obj[1]} as #{obj[0]}")
    end
  end

  class UnsupportedMethodError < Error
    def initialize
      super(EMSG[:unsupported_method])
    end
  end

  class UnsupportedFeatureError < Error
    def initialize(feature, obj)
      super(EMSG[:unsupported_feature] % [feature, obj])
    end
  end

  class CannotFindFileError < Error
    def initialize(obj)
      super(EMSG[:cannot_find_file] % smart_error_value(obj))
    end
  end

  class NotImplementedYetError < Error
    def initialize(feature)
      super(EMSG[:not_implemented_yet] % feature)
    end
  end

  class UknownOperatorError < Error
    def initialize(operator)
      super(EMSG[:unknown_operator] % operator)
    end
  end

end
