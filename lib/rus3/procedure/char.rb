# frozen_string_literal: true

module Rus3
  module Procedure

    module Char

      #   - procedure (R5RS): (char->integer char)

      def char_to_integer(char)
        Rus3::Char.char_to_integer(char)
      end

      #   - procedure (R5RS): (integer->char n)

      def integer_to_char(n)
        Rus3::Char.integer_to_char(n)
      end

      #   - library procedure (R5RS): (char-upcase char)

      def char_upcase(char)
        Rus3::Char.upcase(char)
      end

      #   - library procedure (R5RS): (char-downcase char)

      def char_downcase(char)
        Rus3::Char.downcase(char)
      end

    end

  end
end
