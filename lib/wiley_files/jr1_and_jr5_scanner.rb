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
      @reporter.set_template(:different_values_for_doi, "Different '%{key}' values for %{doi}, \n%{values_map}")
      @reporter.set_template(:multiple_dois_for_proprietary_id, "Proprietary ID '%{id}' maps to more than one DOI: %{map}")
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

    def merge_by_doi
      @merged_by_doi = {}
      @scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          @merged_by_doi.at(row["doi"], filename) << row
        end
      end
    end

    def analyze_by_doi
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2016", "JR5_2016")
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2017", "JR5_2017")
      compare_doi_lists(:jr1_to_jr5_differences, "JR1_2018", "JR5_2018")
      compare_doi_lists(:year_to_year_differences, "JR1_2016", "JR1_2017")
      compare_doi_lists(:year_to_year_differences, "JR1_2017", "JR1_2018")
      compare_values_for_doi("journal")
      compare_values_for_doi("proprietary_id")
      compare_values_for_doi("print_issn")
      compare_values_for_doi("online_issn")
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

    def compare_values_for_doi(key)
      reporter = Report::LimitingReporter.new(@reporter, 5)
      @merged_by_doi.each do |doi, data|
        reduced_map = data.transform_values {|v| v[key]}
        if reduced_map.values.any? {|t| t != reduced_map.values[0]}
          reporter.report(:different_values_for_doi, key: key, doi: doi, values_map: reduced_map.pretty_inspect)
        end
      end
      reporter.close
    end

    def merge_by_proprietary_id
      @merged_by_proprietary_id = {}
      @scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          id = row["proprietary_id"] || "__NONE__"
          @merged_by_proprietary_id.at(id, filename) << row
        end
      end
    end

    def analyze_by_proprietary_id
      map_proprietary_ids_to_lists_of_dois
    end

    def map_proprietary_ids_to_lists_of_dois
      reporter = Report::LimitingReporter.new(@reporter, 5)
      @proprietary_ids_to_dois = {}
      @scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          @proprietary_ids_to_dois.at(row["proprietary_id"], row["doi"]) << filename
        end
      end

      @proprietary_ids_to_dois.each do |proprietary_id, doi_map|
        if doi_map.size > 1
          reporter.report(:multiple_dois_for_proprietary_id, id: proprietary_id, map: doi_map.pretty_inspect)
        end
      end
      reporter.close
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
      merge_by_doi
      analyze_by_doi
      merge_by_proprietary_id
      analyze_by_proprietary_id
      generate_records

      #      puts "BOGUS combined"
      #      pp @merged_by_doi
    end
  end
end