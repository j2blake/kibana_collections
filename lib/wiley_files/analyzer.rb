module WileyFiles
  class Analyzer
    def initialize(dirname)
      @dirname = dirname
      @records = []
      @reporter = Report::Reporter.new
      @reporter.set_template(:no_price, "Price not found for '%{doi}', ids=%{propIds}")
      @reporter.set_template(:good_price, "Good price for '%{doi}', ids=%{propIds}, prices=%{price_map}")
      @reporter.set_template(:multiple_prices, "Multiple prices for '%{doi}', ids=%{propIds}, prices=%{price_map}")
    end

    def create_scanners
      @reporter.mute do |reporter|
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

    def generate_records
      @scanners.each do |filename, scanner|
        @records += scanner.flatten
      end
    end

    def merge_prices_by_doi
      merged_by_doi = {}
      @jr5_scanners.each do |filename, scanner|
        #        puts "\nBOGUS row"
        #        pp scanner.scan.take(1)
        scanner.scan.each do |row|
          merged_by_doi.at(row["doi"], "proprietary_id", row.at("proprietary_id").get) << filename
          merged_by_doi.at(row["doi"], "total_usage", row.at("total_usage").get) << filename
        end
      end
      #      puts "\nBOGUS merged"
      #      pp merged_by_doi.first(1)

      price_list = @scanners["PriceListE"].scan
      #      puts "\nBOGUS price_list"
      #      pp price_list.first(5)

      @reporter.limit(10) do |reporter|
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

    def run
      create_scanners
      merge_prices_by_doi
      #      AnalyzeJr1AndJr5.new(@scanners, @reporter).new.run
      #      generate_records
    end
  end
end