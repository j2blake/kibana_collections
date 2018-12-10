module WileyFiles
  module Scan
    class PriceListEScanner
      def initialize(filename, reporter)
        @filename = filename
        prefix = File.basename(filename, ".*") + ": "

        reporter.with_prefix(prefix, limit: 5) do |r|
          @reporter = r
          @reporter.set_template(:price_missing, "No value for USA price in %{row}")
          @reporter.set_template(:duplicate_code, "code '%{code}' in \n%{existing} matches code in \n%{new}")
          read
          compile
        end
      end

      def read
        @contents = Scanner.new.load_csv_file(@filename, skip_lines: ",,,,,,")
      end

      #
      # produce a hash of hashes like this:
      # {
      #   "5000000075"=>{
      #     "price"=>751.0,
      #     "row"=>{
      #       "﻿Journal Code"=>"5000000075",
      #       "Journal Code with Format"=>"5000000075",
      #       "Media"=>"Online",
      #       "USA"=>"$ 751",
      #       "UK"=>"£594",
      #       "Europe"=>"€ 753",
      #       "Rest of World"=>"$ 1160"
      #     }
      #   }
      # }
      #
      def compile
        @compiled = {}
        @contents.each do |row|
          price = resolve(row["USA"])
          code = resolve(row["﻿Journal Code"])
          codeF = resolve(row["Journal Code with Format"])
          if !price
            @reporter.report(:price_missing, row: row)
          else
            price = price.tr('^0-9', '').to_f
            store_if_new(row, price, code)
            store_if_new(row, price, codeF) if code != codeF
          end
        end
        @reporter.report("Compile completed.")
      end

      def resolve(value)
        if value.nil? || value.strip.empty?
          nil
        else
          value.strip
        end
      end

      def store_if_new(row, price, code)
        if (@compiled[code])
          @reporter.report(:duplicate_code, code: code, existing: @compiled[code]["row"].pretty_inspect, new: row.pretty_inspect)
        else
          @compiled[code] = {"price" => price, "row" => row}
        end
      end

      def scan
        return @compiled
      end
    end
  end
end
