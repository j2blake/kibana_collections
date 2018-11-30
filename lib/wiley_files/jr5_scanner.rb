module WileyFiles
  class Jr5Scanner < JrScanner
    def initialize(filename, reporter)
      super
    end

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
      row.each do |key, value|
        year_of_publication = to_year_of_publication(key)
        compiled_row.at("by_year_of_publication", year_of_publication) << value if year_of_publication
      end
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
