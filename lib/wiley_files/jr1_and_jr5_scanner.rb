require 'pp'
require 'populate/hashPath'
require 'wiley_files/report/limiting_reporter'
require 'wiley_files/jr_scanner'
require 'wiley_files/jr1_scanner'
require 'wiley_files/jr5_scanner'

module WileyFiles
  class Jr1AndJr5Scanner
    attr_reader :dirname

    YEAR_TO_YEAR = "Compare %{key1} and %{key2}: start with %{key1_count} DOIs, " \
      "remove %{key1_only_count}. add %{key2_only_count}, end with %{key2_count} DOIs"

    JR1_TO_JR5 = <<-XXX
Differences between %{key1} to %{key2}:
   %{key1_only_count} DOIs only in %{key1} (e.g. %{key1_only_examples}),
   %{key2_only_count} DOIs only in %{key2} (e.g. %{key2_only_examples}),
    XXX
    #
    def initialize(dirname)
      @dirname = dirname

      @records = []

      @reporter = Report::Reporter.new
      @reporter.set_template(:year_to_year_differences, YEAR_TO_YEAR)
      @reporter.set_template(:jr1_to_jr5_differences, JR1_TO_JR5)
      @reporter.set_template(:different_associations_by_file, "%{key1} '%{value1}' maps to more than one %{key2} \n%{values_map}")
    end

    def create_scanners
      @scanners = {}
      @scanners["JR1_2016"] = Jr1Scanner.new(filepath("JR1_2016"), @reporter)
      @scanners["JR1_2017"] = Jr1Scanner.new(filepath("JR1_2017"), @reporter)
      @scanners["JR1_2018"] = Jr1Scanner.new(filepath("JR1_2018"), @reporter)
      @scanners["JR5_2016"] = Jr5Scanner.new(filepath("JR5_2016"), @reporter)
      @scanners["JR5_2017"] = Jr5Scanner.new(filepath("JR5_2017"), @reporter)
      @scanners["JR5_2018"] = Jr5Scanner.new(filepath("JR5_2018"), @reporter)
    end

    def analyze_by_doi
      merge_by_doi
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2016", "JR5_2016")
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2017", "JR5_2017")
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2018", "JR5_2018")
      compare_doi_lists(:year_to_year_differences, "JR1_2016", "JR1_2017")
      compare_doi_lists(:year_to_year_differences, "JR1_2017", "JR1_2018")

      compare_associations_by_file("doi", "journal", 20)
      compare_associations_by_file("doi", "proprietary_id", 5)
      compare_associations_by_file("doi", "print_issn", 5)
      compare_associations_by_file("doi", "online_issn", 5)
    end

    def merge_by_doi
      @merged_by_doi = {}
      @scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          @merged_by_doi.at(row["doi"], filename) << row
        end
      end
    end

    def compare_doi_lists(template, key1, key2)
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
        key1_only_examples: key1_only.take(5).pretty_inspect,
        key2_only_count: key2_only.size,
        key2_only_examples: key2_only.take(5).pretty_inspect
      }
      @reporter.report(template, summary)
      @reporter.report(' ')
    end

    def compare_associations_by_file(key1, key2, report_limit)
      @reporter.limit(report_limit) do |reporter|
        values_by_file = {}
        @scanners.each do |filename, scanner|
          scanner.scan.each do |row|
            values_by_file.at(row[key1], row[key2]) << filename
          end
        end
        values_by_file.each do |value1, value_map|
          if value_map.size > 1
            reporter.report(:different_associations_by_file, key1: key1, key2: key2, value1: value1, values_map: value_map.pretty_inspect)
          end
        end
      end
    end

    def analyze_by_proprietary_id
      compare_associations_by_file("proprietary_id", "doi", 5)
    end

    def generate_records
      @scanners.each do |filename, scanner|
        @records += scanner.flatten
      end
    end

    def filepath(filename)
      File.expand_path(filename + ".csv", @dirname)
    end

    def run
      create_scanners
      analyze_by_doi
      analyze_by_proprietary_id
      generate_records

      #      puts "BOGUS combined"
      #      pp @merged_by_doi
    end
  end
end