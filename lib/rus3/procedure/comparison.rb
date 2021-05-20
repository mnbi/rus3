# frozen_string_literal: true

module Rus3
  module Procedure

    # This module holds comparison operation procedures of Scheme.

    module Comparison

      def lt?(*args)
        c_calc(:<, *args)
      end

      def le?(*args)
        c_calc(:<=, *args)
      end

      def gt?(*args)
        c_calc(:>, *args)
      end

      def ge?(*args)
        c_calc(:>=, *args)
      end

      def same_value?(*args)
        c_calc(:==, *args)
      end

      private

      def c_calc(op, *args)
        case args.size
        when 0, 1
          raise ArgumentError, args.to_s
        when 2
          args[0].send(op, args[1]) ? true : false
        else
          args[0].send(op, args[1]) and c_calc(op, *args[1..-1]) ? true : false
        end
      end

    end
  end
end
