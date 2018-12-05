module WileyFiles
  module Scan
    class Jr1Scanner < JrScanner
      def initialize(filename, reporter)
        super
      end

      #
      # produce an array of hashes like this:
      # {
      #   "doi"=>"10.1002/(ISSN)1536-0709a", 
      #   "journal"=>"AAHE-ERIC/Higher Education Research Report", 
      #   "proprietary_id"=>"AEHE", 
      #   "print_issn"=>"0737-1764", 
      #   "online_issn"=>"1536-0709", 
      #   "by_month"=>{
      #     "2016-01"=>"0", 
      #     "2016-02"=>"0", 
      #     "2016-03"=>"0", 
      #     "2016-04"=>"0", 
      #     "2016-05"=>"0", 
      #     "2016-06"=>"0", 
      #     "2016-07"=>"0", 
      #     "2016-08"=>"0", 
      #     "2016-09"=>"1", 
      #     "2016-10"=>"0", 
      #     "2016-11"=>"0", 
      #     "2016-12"=>"0"
      #   }, 
      #   "summary"=>{
      #     "total"=>"1", 
      #     "total_html"=>"0", 
      #     "total_pwd"=>"1"
      #   }
      # }
      #
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
          return Date.strptime(key, "%b-%y").strftime("%Y-%m")
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

          year = journal["by_month"].keys.first.slice(0..3)
          @records << journal["summary"].merge(basic_info).merge({"year" => year, "stamp" => "#{year}-01 -0500"})

          journal["by_month"].each do |month, count|
            @records << {"month" => month, "stamp" => "#{month} -0500", "count" => count}.merge(basic_info)
          end
        end
        return @records
      end
    end
  end
end
