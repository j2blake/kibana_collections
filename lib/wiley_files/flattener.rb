=begin

------------------------------------------

Merged structure:
{
  "10.1002/(ISSN)1536-0709a" => {
    "journal" => {"This journal" => ["JR1_2016", "JR1_2017"], "That journal" => "JR1_2018"},
    "proprietary_id" => {"ABC" => ["JR1_2016", "JR1_2017"], "XYZ" => "JR1_2018"},
    # print_issn same
    # online_issn same
    "by_year_of_publication" => {
      "2016" => {
        "2016" => 0,
        "2015" => 2,
        "other" => 2
      }
    },
    by_month => {
      "2016-01" => 0,
      "2017-05" => 2
    },
    total_usage_by_year_of_publication => { "JR5_2016" => 50}
    total_usage_by_month => { "JR1_2016" => 30, "JR1_2017" => 104 }
    price => {
      145.5 => ["ABC", "ABC/A"],
      1550 => "XYZ"
  }
}

------------------------------------------

Notes:

Notice the two-tier structure of "byop". Get the top tier from the filename.

Everything but price comes from JR1 and JR5. Prices are a lookup into PriceListE by propID

------------------------------------------

Curried structure:
{
  "10.1002/(ISSN)1536-0709a" => {
    "journal" => "This journal",
    "proprietary_id" => "ABC",
    # print_issn same
    # online_issn same
    "by_year_of_publication" => {
      "2016" => {
        "2016" => 0,
        "2015" => 2,
        "other" => 2
      }
    },
    by_month => {
      "2016-01" => 0,
      "2017-05" => 2
    },
    total_usage => { 54 => "by_year_of_publication", 50 => "by_month" }
    price => 145.5
  }
}

------------------------------------------

Notes:

Journal title is the most used, or alphabetically first of the most used.
Same for proprietary ID, print ISSN, and online ISSN

Each usage total is the sum of the contributions from differing files.

Price is the smallest of the available prices (or remove multiple prices?)

------------------------------------------

Elasticsearch records should look like this:

doi, journal, proprietary_id, print_issn, online_issn, usage_month, usage_month_stamp, month_usage_count
  one for each doi / usage_month combination

doi, journal, proprietary_id, print_issn, online_issn, usage_year, usage_year_stamp, year_of_publication, year_of_publication_stamp, pubyear_usage_count
  one for each doi / usage_year / year_of_publication combination

doi, journal, proprietary_id, print_issn, online_issn, total_usage_by_month, total_usage_by_year_of_publication, price
  one for each doi

------------------------------------------
=end

module WileyFiles
  class Flattener
    def initialize(reporter)
      @reporter = reporter
    end

    def flatten(curried)
      @records = []
      curried.each do |doi, data|
        @records << create_summary_record(doi, data)
        data["by_month"].to_h.each do |month, count|
          @records << create_by_month_record(doi, data, month, count)
        end
        data["by_year_of_publication"].to_h.each do |request_year, requests|
          requests.to_h.each do |publish_year, count|
          @records << create_by_year_of_publication_record(doi, data, request_year, publish_year, count)
          end
        end
      end
    end

    def create_summary_record(doi, data)
      record = {}
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("total_usage_by_month") << data.at("total_usage", "by_month")
      record.at("total_usage_by_year_of_publication") << data.at("total_usage", "by_year_of_publication")
      record.at("price") << data.at("price")
      return record
    end

    def create_by_month_record(doi, data, month, count)
      record = {}
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("usage_month") << month
      record.at("usage_month_stamp") << month 
      record.at("month_usage_count") << count
      return record
    end

    def create_by_year_of_publication_record(doi, data, request_year, publish_year, count)
      record = {}
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("usage_year") << request_year
      record.at("usage_year_stamp") << request_year 
      record.at("year_of_publication") << publish_year
      record.at("year_of_publication_stamp") << publish_year 
      record.at("pubyear_usage_count") << count
      return record
    end
  end
end