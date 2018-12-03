module WileyFiles
  class JrScanner
    def initialize(filename, reporter)
      @filename = filename

      prefixed = Report::PrefixedReporter.new(reporter, File.basename(filename, ".*") + ": ")
      prefixed.set_template(:missing_values, "Missing value for %{missing} in %{row}")
      prefixed.limit(5) do |reporter|
        @reporter = reporter
        read
        compile
      end
    end

    def read
      @contents = Scan::Scanner.new.load_csv_file(@filename, skip_lines: "(,,,,,,,,,,)|(^Total for)")
      return self
    end

    def compile
      @compiled = []
      @contents.each do |row|
        # is the DOI a duplicate?
        target_row = @compiled.pick("doi", row["Journal DOI"])
        @reporter.report(:duplicate_doi, source: row, target: target_row.get) if (target_row.found?)

        # is the Proprietary Identifier a duplicate?
        target_row = @compiled.pick("propId", row["Proprietary Identifier"])
        @reporter.report(:duplicate_propId, source: row, target: target_row.get) if (target_row.found?)

        # is the Print ISSN a duplicate?
        target_row = @compiled.pick("propId", row["Print ISSN"])
        @reporter.report(:duplicate_printISSN, source: row, target: target_row.get) if (target_row.found?)

        # is the Online ISSN a duplicate?
        target_row = @compiled.pick("propId", row["Online ISSN"])
        @reporter.report(:duplicate_printISSN, source: row, target: target_row.get) if (target_row.found?)

        new_row = {}
        new_row = new_row.at("doi") << row.at("Journal DOI")
        new_row = new_row.at("journal") << row.at("Journal")
        new_row = new_row.at("proprietary_id") << row.at("Proprietary Identifier")
        new_row = new_row.at("print_issn") << row.at("Print ISSN")
        new_row = new_row.at("online_issn") << row.at("Online ISSN")

        expected_keys = ["doi", "journal", "proprietary_id", "print_issn", "online_issn"]
        missing_keys = expected_keys - new_row.keys
        @reporter.report(:missing_values, expected: expected_keys, missing: missing_keys, row: new_row) unless missing_keys.empty?

        @compiled << new_row
      end
      @reporter.report("Compile completed.")
      return self
    end

    def scan
      return @compiled
    end
  end
end