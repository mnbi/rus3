# frozen_string_literal: true

module Rus3

  class Char
    include Comparable

    class << self

      def alphabetic?(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        /[A-Za-z]/ === char.to_s
      end

      def numeric?(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        /[0-9]/ === char.to_s
      end

      def whitespace?(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        /[\s]/ === char.to_s
      end

      def upper_case?(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        /[A-Z]/ === char.to_s
      end

      def lower_case?(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        /[a-z]/ === char.to_s
      end

      def char_to_integer(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        char.codepoint
      end

      def integer_to_char(n, encoding: Encoding::UTF_8)
        self.new(n.chr(encoding))
      end

      def upcase(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        self.new(char.to_s.upcase)
      end

      def downcase(char)
        raise CharRequiredError, char unless char.instance_of?(Char)
        self.new(char.to_s.downcase)
      end

      def compare_chars(char1, char2, comp_op, ignore_case: false)
        if !char1.instance_of?(self)
          raise CharRequiredError, char1
        elsif !char2.instance_of?(self)
          raise CharRequiredError, char2
        end

        if ignore_case
          char1 = downcase(char1)
          char2 = downcase(char2)
        end
        char1.send(comp_op, char2)
      end

    end

    LITERAL_PREFIX  = "#\\"
    LITERAL_SPACE   = "#\\space"
    LITERAL_NEWLINE = "#\\newline"

    attr_reader :codepoint
    attr_reader :encoding

    def initialize(str)
      @char = str[0].dup.freeze
      @encoding = str.encoding
      @codepoint = @char.ord
    end

    def ==(other)
      other.instance_of?(Char) and to_s == other.to_s
    end

    def <=>(other)
      raise CharRequiredError, other unless other.instance_of?(Char)
      @codepoint <=> other.codepoint
    end

    def to_literal
      LITERAL_PREFIX + @char
    end

    def to_s
      @char
    end

  end

end
