module WileyFiles
  module Scan
    class Jr5Scanner < JrScanner
      def initialize(filename, reporter)
        super
      end

      #
      # produce an array of hashes like this:
      # {
      #  "doi"=>"10.1002/(ISSN)1536-0709a",
      #  "journal"=>"AAHE-ERIC/Higher Education Research Report",
      #  "proprietary_id"=>"AEHE",
      #  "print_issn"=>"0737-1764",
      #  "online_issn"=>"1536-0709",
      #  "by_year_of_publication"=> {
      #    "2018"=>"0",
      #    "2017"=>"0",
      #    "2016"=>"0",
      #    "2015"=>"0",
      #    "2014"=>"0",
      #    "2013"=>"0",
      #    "2012"=>"0",
      #    "2011"=>"0",
      #    "2010"=>"0",
      #    "2009"=>"0",
      #    "2008"=>"0",
      #    "2007"=>"0",
      #    "2006"=>"0",
      #    "2005"=>"0",
      #    "2004"=>"0",
      #    "2003"=>"0",
      #    "2002"=>"0",
      #    "2001"=>"0",
      #    "2000"=>"0",
      #    "1999"=>"0",
      #    "1998"=>"0",
      #    "1997"=>"0",
      #    "1996"=>"0",
      #    "1995"=>"0",
      #    "1994"=>"0",
      #    "1993"=>"0",
      #    "1992"=>"0",
      #    "1991"=>"0",
      #    "1990"=>"0",
      #    "other"=>"2"
      #   },
      #   "total_usage"=>2
      # }
      #
      def compile
        super
        compile_requests_by_year_of_publication
      end

      def compile_requests_by_year_of_publication
        @contents.each do |row|
          compiled_row = @compiled.pick("doi", row.at("Journal DOI").get)
          add_year_of_publication_values(row, compiled_row)
        end
      end

      def add_year_of_publication_values(row, compiled_row)
        total = 0
        row.each do |key, value|
          year_of_publication = to_year_of_publication(key)
          if year_of_publication
            compiled_row.at("by_year_of_publication", year_of_publication) << value
            total += value.to_i
          end
        end
        compiled_row.at("total_usage") << total
      end

      def to_year_of_publication(key)
        return nil unless key.start_with?("YOP ")
        yop = key.slice(4..-1).strip
        return yop unless yop.start_with?("Pre")
        return "other"
      end

      def flatten
        @records = []
        @compiled.each do |journal|
          basic_keys = journal.keys - ["by_year_of_publication"]
          basic_info = journal.clone.keep_if {|key| basic_keys.include?(key)}

          journal["by_year_of_publication"].each do |yop, count|
            if yop == "other"
              @records << {"pubYear" => yop, "pubCount" => count}.merge(basic_info)
            else
              @records << {"pubYear" => yop, "stamp" => "#{yop} -0500", "pubCount" => count}.merge(basic_info)
            end
          end
        end
        return @records
      end
    end
  end
end
