# frozen_string_literal: true

module Rus3
  module Procedure
    module Write
      extend DebugUtils if Rus3.debug_mode?

      include Predicate

      def write_null(obj)
        print "()"
      end

      def write_boolean(obj)
        print obj ? "#t" : "#f"
      end

      def write_pair(obj)
        # TODO:
      end

      def write_symbol(obj)
        print ":#{obj}"
      end

      def write_number(obj)
        print obj.to_s
      end

      def write_char(obj)
        # TODO:
      end

      def write_string(obj)
        print obj
      end

      def write_vector(obj)
        print obj.to_s
      end

      def write_port(obj)
        # TODO:
      end

      def write_procedure(obj)
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
          predicate_proc = Predicate.public_method(predicate_name)
          if predicate_proc.call(obj)
            obj_type = type
            break
          end
        }
        obj_type
      end

      def write(obj)
        write_proc_name = "write_#{type(obj)}".intern
        write_proc = public_method(write_proc_name)
        write_proc.call(obj)
        UNDEF
      end
      module_function :write

    end
  end
end
