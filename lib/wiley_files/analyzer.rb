module WileyFiles
  class Analyzer
    def initialize(dirname)
      @dirname = dirname
      @records = []
      @options = CommandLine.new.parse
    end

    def with_reporter
      @reporter = Report::Reporter.new(with_totals: true, with_details: true)
      @reporter.set_template(:no_price, "Price not found for '%{doi}', ids=%{propIds}")
      @reporter.set_template(:good_price, "Good price for '%{doi}', ids=%{propIds}, prices=%{price_map}")
      @reporter.set_template(:multiple_prices, "Multiple prices for '%{doi}', ids=%{propIds}, prices=%{price_map}")
      yield
      @reporter.close
    end

    def create_scanners
      @reporter.reporter do |reporter|
        @scanners = {}
        @scanners["PriceListE"] = Scan::PriceListEScanner.new(filepath("PriceListE"), reporter)
        @scanners["SubscriptionJournals"] = Scan::SubscriptionJournalsScanner.new(filepath("SubscriptionJournals"), @reporter)

        @scanners["JR1_2016"] = Scan::Jr1Scanner.new(filepath("JR1_2016"), reporter)
        @scanners["JR1_2017"] = Scan::Jr1Scanner.new(filepath("JR1_2017"), reporter)
        @scanners["JR1_2018"] = Scan::Jr1Scanner.new(filepath("JR1_2018"), reporter)

        @scanners["JR5_2016"] = Scan::Jr5Scanner.new(filepath("JR5_2016"), reporter)
        @scanners["JR5_2017"] = Scan::Jr5Scanner.new(filepath("JR5_2017"), reporter)
        @scanners["JR5_2018"] = Scan::Jr5Scanner.new(filepath("JR5_2018"), reporter)

        @jr1_scanners = @scanners.select { |filename, scanner| filename.start_with?("JR1") }
        @jr5_scanners = @scanners.select { |filename, scanner| filename.start_with?("JR5") }
      end
    end

    def filepath(filename)
      File.expand_path(filename + ".csv", @dirname)
    end

    def analyze_jr1_and_jr5s
      AnalyzeJr1AndJr5.new(@jr1_scanners.merge(@jr5_scanners), @reporter).analyze
    end

    def merge_prices_by_doi
      merged_by_doi = {}
      @jr1_scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          merged_by_doi.at(row["doi"], "proprietary_id", row.at("proprietary_id").get) << filename
          merged_by_doi.at(row["doi"], "total_usage", row.at("total_usage").get) << filename
        end
      end
      @jr5_scanners.each do |filename, scanner|
        scanner.scan.each do |row|
          merged_by_doi.at(row["doi"], "proprietary_id", row.at("proprietary_id").get) << filename
          merged_by_doi.at(row["doi"], "total_usage", row.at("total_usage").get) << filename
        end
      end

      price_list = @scanners["PriceListE"].scan

      @reporter.with_prefix("merge_prices", limit: 10) do |reporter|
        merged_by_doi.each do |doi, values|
          propIds = values["proprietary_id"].keys
          propIds.each do |propId|
            price = price_list.at(propId, "price").get
            if price
              values.at("price", price) << propId
            end
          end

          price_map = values.at("price").get
          if price_map.nil?
            reporter.report(:no_price, doi: doi, propIds: propIds)
          elsif price_map.size == 1
            reporter.report(:good_price, doi: doi, propIds: propIds, price_map: price_map.pretty_inspect)
          else
            reporter.report(:multiple_prices, doi: doi, propIds: propIds, price_map: price_map.pretty_inspect)
          end
        end
      end
    end

    class Hash
      def first(how_many)
        self.select(keys.sort.take(how_many))
      end
    end

    def output_elasticsearch_records
      merged = Merger.new(@reporter).merge(@jr1_scanners, @jr5_scanners, @scanners["PriceListE"])
      curried = Currier.new(@reporter).curry(merged)
      flattened = @reporter.with_prefix("Flattener", with_details: true, limit: 5, with_totals: true) { |r| Flattener.new(r).flatten(curried) }
      Writer.new(@options, @reporter).write(flattened)
    end

    def run
      with_reporter do
        create_scanners
        analyze_jr1_and_jr5s
        merge_prices_by_doi
        output_elasticsearch_records
      end
      #      AnalyzeJr1AndJr5.new(@scanners, @reporter).new.run
      #      generate_records
    end
  end
end