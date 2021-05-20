# frozen_string_literal: true

module Rus3
  module Printer

    # Indicates the version of the printer module.
    VERSION = "0.2.1"

    class Printer
      attr_accessor :verbose

      def initialize
        @verbose = false
      end

      def self.version
        ""
      end
    end

    class RubyPrinter < Printer
      def print(obj)
        prefix = "==> "
        prefix += "[#{obj.class}]: " if @verbose
        Kernel.print prefix
        pp obj
      end

      def self.version
        "ruby-object-printer :version #{VERSION}"
      end
    end

    class SchemePrinter < Printer
      include Rus3::Procedure::Write

      def print(obj)
        display(obj)
      end

      def self.version
        "scheme-printer :version #{VERSION}"
      end
    end

    class ChainPrinter < Printer
      CHAIN = [RubyPrinter.new, SchemePrinter.new]

      def self.version
        chain_printers = CHAIN.map{|e| e.class}
        "chain-printer :version #{VERSION} :chain (#{chain_printers})"
      end

      def verbose=(flag)
        CHAIN.each{|printer| printer.verbose = flag}
      end

      def print(obj)
        CHAIN.each{|printer| printer.print(obj)}
      end
    end

  end
end
