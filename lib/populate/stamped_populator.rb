module Populate
  class StampedPopulator < Populator
    def process_documents
      @input_hash.each_pair do |doc_name, doc|
        process_document(doc_name, doc)
      end
    end

    def process_document(doc_name, in_doc)
      doc_info = parse_doc_info(doc_name, in_doc)
      years = parse_years_info(in_doc)
      years.each do |year_info|
        merge_and_send(doc_info, year_info)
      end
    end

    def parse_doc_info(doc_name, in_doc)
      doc = {}
      doc.at("name") << doc_name
      doc.at("bibId") << in_doc.at("bibId")
      doc.at("clickDataDatabase") << in_doc.at("clickData", "database")
      doc.at("clickDataIssn") << in_doc.at("clickData", "issn")
      doc.at("clickDataJournal") << in_doc.at("clickData", "journal")
      doc.at("cornellPubCounterTotal") << in_doc.at("cornellPubCounter", "count")
      doc.at("costperuse") << in_doc.at("costperuse")
      doc.at("databasePackageCode") << in_doc.at("database_package", "code")
      doc.at("databasePackageName") << in_doc.at("database_package", "name")
      doc.at("doi") << in_doc.at("doi")
      doc.at("eissnsType") << in_doc.at("eissns").values("type")
      doc.at("eissnsValue") << in_doc.at("eissns").values("value")
      doc.at("issnsType") << in_doc.at("issns").values("type")
      doc.at("issnsValue") << in_doc.at("issns").values("value")
      doc.at("overallUses") << in_doc.at("overallUses")
      doc.at("providerCode") << in_doc.at("provider", "code")
      doc.at("providerName") << in_doc.at("provider", "name")
      doc.at("publisher") << in_doc.at("publisher")
      doc.at("ssid") << in_doc.at("ssid")
      doc.at("subject") << in_doc.at("subjects")
      doc.at("title") << in_doc.at("title")
      doc.at("titleId") << in_doc.at("titleId")
      doc.at("type") << in_doc.at("type")
      return doc
    end

    # Create an Array of year info, with an entry for each year that we have info
    # NOTE: for the timestamped version, "year" must have a string value.
    def parse_years_info(in_doc)
      years = {}

      thisYear = in_doc.at("citeScore", "year").get.to_s
      years.pick("years", "year", thisYear).at("citeScore") << in_doc.at("citeScore", "citescore")

      thisYear = in_doc.at("citeScoreTracker", "year").get.to_s
      years.pick("years", "year", thisYear).at("citeScoreTracker") << in_doc.at("citeScoreTracker", "citescoreTracker")

      in_doc.at("clickData", "clickCount").get.to_a.each do |h|
        thisYear = h.at("year").get.to_s
        years.pick("years", "year", thisYear).at("clickCount") << h.at("count")
        years.pick("years", "year", thisYear).at("clickCountNoOfRecords") << h.at("noOfRecords")
      end

      in_doc.at("cornellPubCounter", "map").get.to_h.each_pair do |thisYear, count|
        years.pick("years", "year", thisYear.to_s).at("cornellPubCounterByYear") << count
      end

      in_doc.at("costUsageData").get.to_a.each do |map|
        years.pick("years", "year", map["year"]).at("costUsageCost") << map.at("cost");
        years.pick("years", "year", map["year"]).at("costUsageTurnaway") << map.at("turnaway");
        years.pick("years", "year", map["year"]).at("costUsageUse") << map.at("use");
      end

      puts "years: #{years["years"]}"
      return years["years"]
    end

    def merge_and_send(doc_info, year_info)
      out_doc = doc_info.merge(year_info)
      send_document(create_doc_id(out_doc), "journal", out_doc)
    end

    # Unique ID for each year of each journal
    def create_doc_id(doc)
      Zlib.crc32("#{doc["name"]}#{doc["year"]}")
    end

    def run
      load_data_file
      process_documents
    end

  end
end