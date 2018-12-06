=begin
------------------------------------------

produced a hash ot these merged structures, by DOI
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
    total_usage_by_year_of_publication => { "JR5_2016" => 50},
    total_usage_by_month => { "JR1_2016" => 30, "JR1_2017" => 104 },
    price => {
      145.5 => ["ABC", "ABC/A"],
      1550 => "XYZ"
    }
  }
}

------------------------------------------

Notes:

Notice the two-tier structure of "by_year_of_publication". Get the top tier from the filename.

Everything but price comes from JR1 and JR5. Prices are a lookup into PriceListE by propID

------------------------------------------
=end
module WileyFiles
  class Merger
    def initialize(reporter)
      @reporter = reporter
    end

    def merge(jr1_scanners, jr5_scanners, price_list_e_scanner)
      @merged = {}

      jr1_scanners.each do |filename, scanner|
        scanner.scan_hash.each do |doi, data|
          @merged.at(doi, "journal", data["journal"]) << filename
          @merged.at(doi, "proprietary_id", data["proprietary_id"]) << filename
          @merged.at(doi, "print_issn", data["print_issn"]) << filename
          @merged.at(doi, "online_issn", data["online_issn"]) << filename
          @merged.at(doi, "total_usage_by_month", filename) << data["summary"]["total"].to_i
          data["by_month"].each do |month, count|
            @merged.at(doi, "by_month", month) << count.to_i
          end
        end
      end

      jr5_scanners.each do |filename, scanner|
        year_of_report = filename.slice(-4..-1)
        scanner.scan_hash.each do |doi, data|
          @merged.at(doi, "journal", data["journal"]) << filename
          @merged.at(doi, "proprietary_id", data["proprietary_id"]) << filename
          @merged.at(doi, "print_issn", data["print_issn"]) << filename
          @merged.at(doi, "online_issn", data["online_issn"]) << filename
          @merged.at(doi, "total_usage_by_year_of_publication", filename) << data["total_usage"].to_i
          data["by_year_of_publication"].each do |yop, count|
            @merged.at(doi, "by_year_of_publication", year_of_report, yop) << count.to_i
          end
        end
      end

      price_list = price_list_e_scanner.scan
      @merged.each do |doi, data|
        propIds = data["proprietary_id"].keys
        propIds.each do |propId|
          price = price_list.at(propId, "price").get
          if price
            data.at("price", price) << propId
          end
        end
      end

      return @merged
    end
  end
end
