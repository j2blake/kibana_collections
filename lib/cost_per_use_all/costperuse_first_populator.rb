module CostPerUse
  class CostperuseFirstJournalDocument
    attr_reader :name
    attr_reader :doi
    attr_reader :price
    attr_reader :usage_2016
    attr_reader :usage_2017
    attr_reader :usage_2018
    attr_reader :usage_total
    attr_reader :usage_average
    attr_reader :usage_trend
    attr_reader :cost_per_use
    def initialize(in_doc)
      @in_doc = in_doc
      @name = in_doc["Journal Name"]
      @doi = in_doc["Doi"]
      @price = in_doc["Price"].to_f
      @usage_2016 = in_doc["Usage1"].to_i
      @usage_2017 = in_doc["Usage2"].to_i
      @usage_2018 = in_doc["Usage3"].to_i
      @usage_total = @usage_2016 + @usage_2017 + @usage_2018
      @usage_average = @usage_total / 3.0
      @usage_trend = divide(@usage_2018 - @usage_2016, @usage_average, 1.0)
      @cost_per_use = divide(@price, @usage_total, nil)
    end

    def divide(numerator, denominator, if_zero)
      return numerator / denominator unless denominator == 0
      return if_zero
    end
  end

  class CostperuseFirstPopulator < Populate::Populator
    def process_documents
      @input_array.each do |doc|
        process_document(CostperuseFirstJournalDocument.new(doc))
      end
    end

    def process_document(jdoc)
      doc_info = parse_doc_info(jdoc)
      years = parse_years_info(jdoc)
      years.each do |year_info|
        merge_and_send(doc_info, year_info)
      end
    end

    def parse_doc_info(jdoc)
      doc = {}
      doc.at("name") << jdoc.name
      doc.at("doi") << jdoc.doi
      doc.at("price") << jdoc.price
      return doc
    end

    def parse_years_info(jdoc)
      years = []
      years << {"year" => 2016, "time" => "2016 -0500", "usage" => jdoc.usage_2016}
      years << {"year" => 2017, "time" => "2017 -0500", "usage" => jdoc.usage_2017}
      years << parse_summary_info(jdoc).merge({"year" => 2018, "time" => "2018 -0500", "usage" => jdoc.usage_2018})
      return years
    end

    def parse_summary_info(jdoc)
      summary = {}
      summary.at("totalUsage") << jdoc.usage_total
      summary.at("averageUsage") << jdoc.usage_average
      summary.at("usageTrend") << jdoc.usage_trend
      summary.at("costPerUse") << jdoc.cost_per_use
      return summary
    end

    def merge_and_send(doc_info, year_info)
      out_doc = doc_info.merge(year_info)
      send_document(create_doc_id(out_doc), "_doc", out_doc)
    end

    # Unique ID for each year of each journal
    def create_doc_id(doc)
      Zlib.crc32("#{doc["name"]}#{doc["year"]}")
    end

    def run
      load_csv_file
      process_documents
    end
  end
end

=begin
{
  "Doi"=>"10.1002/(ISSN)1934-1563",
  "Usage1"=>"0", "Usage2"=>"0", "Usage3"=>"0", "AVG Usage"=>"0.00",
  "Price"=>"828.0", "Cost/Use"=>"2000000000.00", "Journal Name"=>"PM&R"}
=end
