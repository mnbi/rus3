# frozen_string_literal: true

module Rus3
  module Procedure
    module Write
      extend DebugUtils if Rus3.debug_mode?

      include Predicate
      include Control

     def null_to_string(obj)
       "()"
      end

      def boolean_to_string(obj)
        obj ? "#t" : "#f"
      end

      def pair_to_string(obj)
        if null?(obj)
          # ()
          null_to_string(obj)
        elsif list?(obj)
          # (1 (2 3) 4))
          prc_to_string = lambda { |e| any_to_string(e) }
          result = map1(prc_to_string, obj)
          prc_join = lambda { |r, e| r + " #{e}" }
          str = "#{car(result)}"
          str = fold(prc_join, str, cdr(result))
          "(#{str})"
        else
          # (1 2 3 . 4)))
          # TODO: ...
          obj.to_s
        end
      end

      def symbol_to_string(obj)
        ":#{obj}"
      end

      def number_to_string(obj)
        obj.to_s
      end

      def char_to_string(obj)
        # TODO:
      end

      def string_to_string(obj)
        "\"#{obj}\""
      end

      def vector_to_string(obj)
        # TODO: Can this implementation handle nested vectors?
        "\##{obj}".gsub(/\[/, "(").gsub(/\]/, ")")
      end

      def port_to_string(obj)
        # TODO:
      end

      def procedure_to_string(obj)
        # TODO:
      end

      TYPES = [
        :null,                  # empty list
        :boolean,               # #f or #t
        :pair,                  # (foo . bar)
        :symbol,
        :number,
        :char,
        :string,
        :vector,
        :port,
        :procedure,
      ]

      def type(obj)
        obj_type = nil
        TYPES.each { |type|
          predicate_name = "#{type}?".intern
          predicate_prc = Predicate.public_method(predicate_name)
          if predicate_prc.call(obj)
            obj_type = type
            break
          end
        }
        obj_type || :undef
      end

      def any_to_string(obj)
        prc_name = "#{type(obj)}_to_string".intern
        if public_methods.include?(prc_name)
          prc = public_method(prc_name)
          prc.call(obj)
        else
          obj.to_s
        end
      end

      def write(obj)
        print any_to_string(obj)
        UNDEF
      end
      module_function :write

      def display(obj)
        puts any_to_string(obj)
        UNDEF
      end
      module_function :display

    end
  end
end
