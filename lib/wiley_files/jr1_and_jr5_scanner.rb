require 'pp'

require 'populate/hashPath'
require 'wiley_files/jr_scanner'

module WileyFiles
  class Jr1AndJr5Scanner
    attr_reader :dirname
    #
    def initialize(dirname)
      @dirname = dirname

      @reporter = Report::Reporter.new
      @reporter.set_template(:year_to_year_differences,
      "Compare %{key1} and %{key2}: start with %{key1_count} DOIs, remove %{key1_only_count}. add %{key2_only_count}, end with %{key2_count} DOIs")
      @reporter.set_template(:jr1_to_jr5_differences,
      "Differences between %{key1} to %{key2}: \n   %{key1_only_count} DOIs only in %{key1} (e.g. %{key1_only_examples}), \n   %{key2_only_count} DOIs only in %{key2} (e.g. %{key2_only_examples}),")
      @reporter.set_template(:different_values_for_doi, "Different '%{key}' values for %{doi}, \n%{values_map}")
    end

    def scan_and_merge(filename)
      filepath = File.expand_path(filename + ".csv", @dirname)
      scanned = JrScanner.new(filepath, @reporter).read.compile.scan
      scanned.each do |row|
        @merged_by_doi.at(row["doi"], filename) << row
      end
    end

    def check_for_differences(template, key1, key2)
      key1_values = []
      key2_values = []
      @merged_by_doi.each do |doi, value|
        key1_values << doi if value.at(key1).found?
        key2_values << doi if value.at(key2).found?
      end
      key1_only = key1_values - key2_values
      key2_only = key2_values - key1_values

      summary = {
        key1: key1,
        key2: key2,
        key1_count: key1_values.size,
        key2_count: key2_values.size,
        key1_only_count: key1_only.size,
        key1_only_examples: key1_only.take(5),
        key2_only_count: key2_only.size,
        key2_only_examples: key2_only.take(5)
      }
      @reporter.report(template, summary)
    end

    def compare_values_for_doi(key)
      @merged_by_doi.each do |doi, data|
        reduced_map = data.transform_values {|v| v[key]}
        if reduced_map.values.any? {|t| t != reduced_map.values[0]}
          @reporter.report(:different_values_for_doi, key: key, doi: doi, values_map: reduced_map.pretty_inspect)
        end
      end
    end

    def run
      @merged_by_doi = {}
      scan_and_merge("JR1_2016")
      scan_and_merge("JR1_2017")
      scan_and_merge("JR1_2018")
      scan_and_merge("JR5_2016")
      scan_and_merge("JR5_2017")
      scan_and_merge("JR5_2018")
      check_for_differences(:jr1_to_jr5_differences, "JR1_2016", "JR5_2016")
      check_for_differences(:jr1_to_jr5_differences, "JR1_2017", "JR5_2017")
      check_for_differences(:jr1_to_jr5_differences, "JR1_2018", "JR5_2018")
      check_for_differences(:year_to_year_differences, "JR1_2016", "JR1_2017")
      check_for_differences(:year_to_year_differences, "JR1_2017", "JR1_2018")
      compare_values_for_doi("journal")
      compare_values_for_doi("proprietary_id")
      compare_values_for_doi("print_issn")
      compare_values_for_doi("online_issn")
      #
      #      
      #
      #      puts "BOGUS combined"
      #      pp @merged_by_doi
    end
  end
end