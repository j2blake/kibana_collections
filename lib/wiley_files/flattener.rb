=begin
------------------------------------------

Produce an array of data structures for Elasticsearch records from the curried data structure.

The Elasticsearch records should look like these:

record_type, doi, journal, proprietary_id, print_issn, online_issn, usage_month, usage_month_stamp, month_usage_count
  one for each doi / usage_month combination

record_type, doi, journal, proprietary_id, print_issn, online_issn, usage_year, usage_year_stamp, year_of_publication, year_of_publication_stamp, pubyear_usage_count
  one for each doi / usage_year / year_of_publication combination

record_type, doi, journal, proprietary_id, print_issn, online_issn, total_usage_by_month, total_usage_by_year_of_publication, price
  one for each doi

------------------------------------------
=end

module WileyFiles
  class Flattener
    def initialize(reporter)
      @reporter = reporter
      @reporter.set_template(:summary_record, "Summary record for %{doi}")
      @reporter.set_template(:by_month_record, "By-month record for %{doi}")
      @reporter.set_template(:by_year_of_publication_record, "By-year-of-publication record for %{doi}")
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
      @records
    end

    def create_summary_record(doi, data)
      @reporter.report(:summary_record, doi: doi)
      record = {}
      record.at("record_type") << "summary"
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("total_usage_by_month") << data.at("total_usage", "by_month")
      record.at("total_usage_by_year_of_publication") << data.at("total_usage", "by_year_of_publication")
      record.at("total_usage_estimate") << estimate_total_usage(data)
      record.at("price") << data.at("price")
      return record
    end
    
    # Usage by month different from usage by YOP? Take the average.
    def estimate_total_usage(data)
      by_month = data.at("total_usage", "by_month").get
      by_yop = data.at("total_usage", "by_year_of_publication").get
      if by_month.nil? 
        by_yop
      elsif by_yop.nil? 
        by_month
      else
        (by_month + by_yop) / 2
      end
    end

    def create_by_month_record(doi, data, month, count)
      @reporter.report(:by_month_record, doi: doi)
      record = {}
      record.at("record_type") << "by_month"
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("usage_month") << month
      record.at("usage_month_stamp") << to_stamp(month) 
      record.at("month_usage_count") << count
      return record
    end

    def create_by_year_of_publication_record(doi, data, request_year, publish_year, count)
      @reporter.report(:by_year_of_publication_record, doi: doi)
      record = {}
      record.at("record_type") << "by_yop"
      record.at("doi") << doi
      record.at("journal") << data.at("journal")
      record.at("proprietary_id") << data.at("proprietary_id")
      record.at("print_issn") << data.at("print_issn")
      record.at("online_issn") << data.at("online_issn")
      record.at("usage_year") << request_year
      record.at("usage_year_stamp") << to_stamp(request_year) 
      record.at("year_of_publication") << publish_year
      record.at("year_of_publication_stamp") << to_stamp(publish_year) 
      record.at("pubyear_usage_count") << count
      return record
    end
    
    def to_stamp(raw_date)
      raw_date ? raw_date + " -0500" : nil
    end
  end
end