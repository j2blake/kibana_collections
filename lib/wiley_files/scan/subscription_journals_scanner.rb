module WileyFiles
  module Scan
    class SubscriptionJournalsScanner
      def initialize(filename, reporter)
        @filename = filename

        prefixed = Report::PrefixedReporter.new(reporter, File.basename(filename, ".*") + ": ")
        prefixed.set_template(:price_missing, "No price for %{propId} '%{title}'")
        prefixed.set_template(:price_found, "Price for %{propId} '%{title}' is %{price}")
        prefixed.limit(5) do |reporter|
          @reporter = reporter
          read
          compile
        end
      end

      def read
        @contents = Scanner.new.load_csv_file(@filename, skip_lines: ",,,,,,,,,,,,,,,,$")
      end

      # BOGUS for now, produce an empty hash
      #      #
      #      #       produce a hash of hashes like this:
      #      #       {
      #      #         "5000000075"=>{
      #      #           "price"=>751.0,
      #      #           "row"=>{
      #      #             "﻿Journal Code"=>"5000000075",
      #      #             "Journal Code with Format"=>"5000000075",
      #      #             "Media"=>"Online",
      #      #             "USA"=>"$ 751",
      #      #             "UK"=>"£594",
      #      #             "Europe"=>"€ 753",
      #      #             "Rest of World"=>"$ 1160"
      #      #           }
      #      #         }
      #      #       }
      #      #
      def compile
        @compiled = {}
        @contents.each do |row|
          propId = resolve(row[""])
          title = resolve(row["Title"])
          price = resolve(row["Price"])
          if price
            @reporter.report(:price_found, propId: propId, title: title, price: price)
          else
            @reporter.report(:price_missing, propId: propId, title: title)
          end
        end
        @reporter.report("Compile completed.")
      end

      def resolve(value)
        return nil if value.nil?
        value = value.strip

        return nil if value.empty? || value == "#N/A"
        return value
      end

      def scan
        return @compiled
      end
    end
  end
end
