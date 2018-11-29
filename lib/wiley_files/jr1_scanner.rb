module WileyFiles
  class Jr1Scanner < JrScanner
    def initialize(filename, reporter)
      super
    end

    def compile
      super
      compile_requests_by_month
    end

    def compile_requests_by_month
      @contents.each do |row|
        compiled_row = @compiled.pick("doi", row.at("Journal DOI").get)
        add_monthly_values(row, compiled_row)
        add_totals(row, compiled_row)
      end
    end

    def add_monthly_values(row, compiled_row)
      row.each do |key, value|
        date = to_date(key)
        compiled_row.at("by_month", date) << value if date
      end
    end

    def to_date(key)
      begin
        return Date.strptime(key, "%b-%y")
      rescue
        return nil
      end
    end

    def add_totals(row, compiled_row)
      compiled_row.at("summary", "total") << row.at("Reporting Period Total")
      compiled_row.at("summary", "total_html") << row.at("Reporting Period HTML")
      compiled_row.at("summary", "total_pwd") << row.at("Reporting Period PDF")
    end

    def flatten
      @records = []
      @compiled.each do |journal|
        basic_keys = journal.keys - ["by_month", "summary"]
        basic_info = journal.clone.keep_if {|key| basic_keys.include?(key)}

        year = journal["by_month"].keys.first
        @records << journal["summary"].merge(basic_info).merge({"year" => year.strftime("%Y"), "stamp" => year.strftime("%Y-01 -0500")})

        journal["by_month"].each do |month, count|
          @records << {"month" => month.strftime("%Y-%m"), "stamp" => month.strftime("%Y-%m -0500"), "count" => count}.merge(basic_info)
        end
      end
      return @records
    end
  end
end
