module Populate
  class NestedPopulator < Populator
    def populate_output_array
      @output_array = []
      @input_hash.each_pair do |doc_name, doc|
        @output_array << parse_document(doc_name, doc)
      end
    end

    def parse_document(doc_name, in_doc)
      out_doc = {}
      out_doc.at("name") << doc_name
      out_doc.at("bibId") << in_doc.at("bibId")
      out_doc.at("clickDataDatabase") << in_doc.at("clickData", "database")
      out_doc.at("clickDataIssn") << in_doc.at("clickData", "issn")
      out_doc.at("clickDataJournal") << in_doc.at("clickData", "journal")
      out_doc.at("cornellPubCounterTotal") << in_doc.at("cornellPubCounter", "count")
      out_doc.at("costperuse") << in_doc.at("costperuse")
      out_doc.at("databasePackageCode") << in_doc.at("database_package", "code")
      out_doc.at("databasePackageName") << in_doc.at("database_package", "name")
      out_doc.at("doi") << in_doc.at("doi")
      out_doc.at("eissnsType") << in_doc.at("eissns").values("type")
      out_doc.at("eissnsValue") << in_doc.at("eissns").values("value")
      out_doc.at("issnsType") << in_doc.at("issns").values("type")
      out_doc.at("issnsValue") << in_doc.at("issns").values("value")
      out_doc.at("overallUses") << in_doc.at("overallUses")
      out_doc.at("providerCode") << in_doc.at("provider", "code")
      out_doc.at("providerName") << in_doc.at("provider", "name")
      out_doc.at("publisher") << in_doc.at("publisher")
      out_doc.at("ssid") << in_doc.at("ssid")
      out_doc.at("subject") << in_doc.at("subjects")
      out_doc.at("title") << in_doc.at("title")
      out_doc.at("titleId") << in_doc.at("titleId")
      out_doc.at("type") << in_doc.at("type")

      thisYear = in_doc.at("citeScore", "year").get
      out_doc.pick("years", "year", thisYear).at("citeScore") << in_doc.at("citeScore", "citescore")

      thisYear = in_doc.at("citeScoreTracker", "year").get
      out_doc.pick("years", "year", thisYear).at("citeScoreTracker") << in_doc.at("citeScoreTracker", "citescoreTracker")

      in_doc.at("clickData", "clickCount").get.to_a.each do |h|
        thisYear = h.at("year").get
        out_doc.pick("years", "year", thisYear).at("clickCount") << h.at("count")
        out_doc.pick("years", "year", thisYear).at("clickCountNoOfRecords") << h.at("noOfRecords")
      end

      in_doc.at("cornellPubCounter", "map").get.to_h.each_pair do |thisYear, count|
        out_doc.pick("years", "year", thisYear).at("cornellPubCounterByYear") << count
      end

      return out_doc
    end

    def send_documents
      @output_array.each do |doc|
        send_document(Zlib.crc32(doc["name"]), "journal", doc)
      end
    end

    def run
      load_json_file
      populate_output_array
      send_documents
    end

  end
end