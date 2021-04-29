# frozen_string_literal: true

module Rus3
  module Procedure

    module Write

      include Predicate
      include Rus3::EmptyList

      def write(obj)
        print any_to_string(obj)
        Rus3::UNDEF
      end

      def display(obj)
        puts any_to_string(obj)
        Rus3::UNDEF
      end

      # :stopdoc:

      private

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

      def private_method(name)
        m = nil
        if self.class.private_method_defined?(name)
          um = self.class.instance_method(name)
          m = um.bind(self)
        end
        m
      end

      def type(obj)
        obj_type = nil
        TYPES.each { |type|
          predicate_name = "#{type}?".intern
          next unless respond_to?(predicate_name)

          predicate_prc = method(predicate_name)
          if predicate_prc.call(obj)
            obj_type = type
            break
          end
        }
        obj_type || :undef
      end

      def any_to_string(obj)
        prc_name = "#{type(obj)}_to_string".intern
        prc = private_method(prc_name)
        prc ? prc.call(obj) : obj.to_s
      end

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
          # (1 2 3 4)
          result = obj.map {|e| any_to_string(e) }
          "(#{result.join(' ')})"
        else
          # (1 2 3 . 4)
          # ==> (1 . (2 . (3 . 4)))
          result = any_to_string(obj.car)
          cp = obj.cdr

          while pair?(cp)
            result += " "
            result += any_to_string(cp.car)
            cp = cp.cdr
          end

          result += " . "
          result += any_to_string(cp)
          "(#{result})"
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
        # TODO:
      end

      def port_to_string(obj)
        # TODO:
      end

      def procedure_to_string(obj)
        # TODO:
      end

      # :startdoc:
    end

  end
end
