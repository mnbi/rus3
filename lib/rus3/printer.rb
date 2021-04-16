# frozen_string_literal: true

module Rus3
  module Printer

    # Indicates the version of the printer module.
    VERSION = "0.1.0"

    class Printer
      include Rus3::Procedure::Write

      def print(obj)
        display(obj)
      end

      def version
        "Printer version #{VERSION}"
      end
    end

  end
end
