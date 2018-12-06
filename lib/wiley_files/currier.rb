=begin

From the result of Merger.merge, produce this Curried structure:
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
    total_usage => { "by_year_of_publication" => 54, "by_month" => 50 }
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
=end

module WileyFiles
  class Currier
    def initialize(reporter)
      @reporter = reporter
    end

    def curry(merged)
      @curried = {}

      merged.each do |doi, data|
        @curried.at(doi, "journal") << favored_value(data["journal"])
        @curried.at(doi, "proprietary_id") << favored_value(data["proprietary_id"])
        @curried.at(doi, "print_issn") << favored_value(data["print_issn"])
        @curried.at(doi, "online_issn") << favored_value(data["online_issn"])
        @curried.at(doi, "by_year_of_publication") << data["by_year_of_publication"]
        @curried.at(doi, "by_month") << data["by_month"]
        @curried.at(doi, "total_usage", "by_year_of_publication") << sum_of_values(data["total_usage_by_year_of_publication"])
        @curried.at(doi, "total_usage", "by_month") << sum_of_values(data["total_usage_by_month"])
        @curried.at(doi, "price") << lowest_key(data["price"])
      end

      return @curried
    end

    def favored_value(values_map)
      return nil unless values_map
      clean_values_map = values_map.reject {|k, v| k.nil?}
      return nil if clean_values_map.empty?
      value_count_map = clean_values_map.transform_values {|v| v.is_a?(Array) ? v.size : 1}
        
      best_pair = value_count_map.to_a.reduce do |sofar, pair|
        if sofar[1] > pair[1]
          sofar
        elsif sofar[1] < pair[1]
          pair
        elsif sofar[0] <= pair[0]
          sofar
        else
          pair
        end
      end
      best_pair[0]
    end
    
    def sum_of_values(values_map)
      return nil unless values_map
      return values_map.values.inject(:+)
    end
    
    def lowest_key(price_map)
      return nil unless price_map
      price_map.keys.inject{|sofar, price| [sofar, price].min}
    end
  end
end