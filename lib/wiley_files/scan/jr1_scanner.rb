module WileyFiles
  module Scan
    class Jr1Scanner < JrScanner
      def initialize(filename, reporter)
        super
      end

      #
      # produce a hash of hashes like this:
      # { "10.1002/(ISSN)1536-0709a"=>{
      #     "doi"=>"10.1002/(ISSN)1536-0709a",
      #     "journal"=>"AAHE-ERIC/Higher Education Research Report",
      #     "proprietary_id"=>"AEHE",
      #     "print_issn"=>"0737-1764",
      #     "online_issn"=>"1536-0709",
      #     "by_month"=>{
      #       "2016-01"=>"0",
      #       "2016-02"=>"0",
      #       "2016-03"=>"0",
      #       "2016-04"=>"0",
      #       "2016-05"=>"0",
      #       "2016-06"=>"0",
      #       "2016-07"=>"0",
      #       "2016-08"=>"0",
      #       "2016-09"=>"1",
      #       "2016-10"=>"0",
      #       "2016-11"=>"0",
      #       "2016-12"=>"0"
      #     },
      #     "summary"=>{
      #       "total"=>"1",
      #       "total_html"=>"0",
      #       "total_pwd"=>"1"
      #     }
      #   }
      # }
      #
      def add_more_values_by_doi(raw_row)
        compile_requests_by_month(raw_row)
      end

      def compile_requests_by_month(row)
        doi = row["Journal DOI"]
        return unless doi

        compiled_row = @by_doi[doi]
        return unless compiled_row

        add_monthly_values(row, compiled_row)
        add_totals(row, compiled_row)
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
    end
  end
end
