module Populate
  class CostperuseFirstPopulator < Populator
    def process_documents
      @input_array.each do |doc|
        process_document(doc)
      end
    end

    def process_document(in_doc)
      doc_info = parse_doc_info(in_doc)
      years = parse_years_info(in_doc)
      years.each do |year_info|
        merge_and_send(doc_info, year_info)
      end
    end

    def parse_doc_info(in_doc)
      doc = {}
      doc.at("name") << in_doc["Journal Name"]
      doc.at("doi") << in_doc["Doi"]
      doc.at("price") << in_doc["Price"].to_f
      return doc
    end

    def parse_years_info(in_doc)
      years = []
      years << {"year" => 2016, "time" => "2016 -0500", "usage" => in_doc["Usage1"].to_i}
      years << {"year" => 2017, "time" => "2017 -0500", "usage" => in_doc["Usage2"].to_i}
      years << parse_summary_info(in_doc).merge({"year" => 2018, "time" => "2018 -0500", "usage" => in_doc["Usage3"].to_i})
      return years
    end

    def parse_summary_info(in_doc)
      summary = {}
      summary["totalUsage"] = in_doc["Usage1"].to_i + in_doc["Usage2"].to_i + in_doc["Usage3"].to_i
      summary["averageUsage"] = summary["totalUsage"] / 3
      summary["usageTrend"] = (in_doc["Usage3"].to_i - in_doc["Usage1"].to_i) / [in_doc["Usage1"].to_f, 1].max
      summary["costPerUse"] = summary["totalUsage"] / in_doc["Price"].to_f
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
