module WileyFiles
  module Scan
    class JrScanner
      MISSING_VALUE = "Missing value for '%{key}\n    %{new_row}'"
      DUPLICATE_VALUE = "Duplicate value for '%{key}\n    %{new_row}\n    %{old_row}'"
      #
      def initialize(filename, reporter)
        @filename = filename

        prefixed = Report::PrefixedReporter.new(reporter, File.basename(filename, ".*") + ": ")
        prefixed.set_template(:missing_doi, MISSING_VALUE)
        prefixed.set_template(:missing_propId, MISSING_VALUE)
        prefixed.set_template(:missing_printISSN, MISSING_VALUE)
        prefixed.set_template(:missing_onlineISSN, MISSING_VALUE)
        prefixed.set_template(:duplicate_doi, DUPLICATE_VALUE)
        prefixed.set_template(:duplicate_propId, DUPLICATE_VALUE)
        prefixed.set_template(:duplicate_printISSN, DUPLICATE_VALUE)
        prefixed.set_template(:duplicate_onlineISSN, DUPLICATE_VALUE)

        prefixed.limit(5) do |reporter|
          @reporter = reporter
          read
          compile
        end
      end

      def read
        @contents = Scanner.new.load_csv_file(@filename, skip_lines: "(,,,,,,,,,,)|(^Total for)")
        return self
      end

      #
      # produce a hash of hashes like this:
      # {
      #   "10.1002/(ISSN)1536-0709a"=>{
      #     "doi"=>"10.1002/(ISSN)1536-0709a",
      #     "journal"=>"AAHE-ERIC/Higher Education Research Report",
      #     "proprietary_id"=>"AEHE",
      #     "print_issn"=>"0737-1764",
      #     "online_issn"=>"1536-0709"
      #   }
      # }
      #
      def compile
        @by_doi = {}
        @by_proprietary_id = {}
        @by_print_issn = {}
        @by_online_issn = {}

        @contents.each do |raw_row|
          @new_row = convert_row(raw_row)
          next unless has_doi?
          add_without_duplicating(@by_doi, "doi", :duplicate_doi, :missing_doi)
          add_without_duplicating(@by_proprietary_id, "proprietary_id", :duplicate_propId, :missing_propId)
          add_without_duplicating(@by_print_issn, "print_issn", :duplicate_printISSN, :missing_printISSN)
          add_without_duplicating(@by_online_issn, "online_issn", :duplicate_onlineISSN, :missing_onlineISSN)

          add_more_values_by_doi(raw_row)
        end
      end

      def convert_row(raw_row)
        row = {}
        row.at("doi") << raw_row.at("Journal DOI")
        row.at("journal") << raw_row.at("Journal")
        row.at("proprietary_id") << raw_row.at("Proprietary Identifier")
        row.at("print_issn") << raw_row.at("Print ISSN")
        row.at("online_issn") << raw_row.at("Online ISSN")
      end

      def has_doi?
        @new_row["doi"]
      end

      def add_without_duplicating(hash, key, message_duplicate, message_missing)
        value = @new_row[key]
        if value
          old_row = hash[value]
          if old_row
            @reporter.report(message_duplicate, key: key, new_row: trim_for_display(@new_row, key), old_row: trim_for_display(old_row, key))
          else
            hash[value] = @new_row
          end
        else
          @reporter.report(message_missing, key: key, new_row: trim_for_display(@new_row, key))
        end
      end

      def trim_for_display(row, key)
        row.select do |k, v|
          ["doi", "journal", key].include?(k)
        end
      end

      def add_more_values_by_doi(raw_row)
        # subclasses should implement this
      end

      def scan
        @by_doi.values
      end

      def scan_hash
        @by_doi
      end
    end
  end
end
