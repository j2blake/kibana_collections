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

doi, journal, proprietary_id, print_issn, online_issn, usage_month, usage_month_stamp, usage_count
  one for each doi / usage_month combination

doi, journal, proprietary_id, print_issn, online_issn, usage_year, usage_year_stamp, year_of_publication, year_of_publication_stamp
  one for each doi / usage_year / year_of_publication combination

doi, journal, proprietary_id, print_issn, online_issn, total_usage_by_month, total_usage_by_year_of_publication, price
  one for each doi

------------------------------------------
=end

#
# {
#  "doi"=>"10.1002/(ISSN)1536-0709a",
#  "journal"=>"AAHE-ERIC/Higher Education Research Report",
#  "proprietary_id"=>"AEHE",
#  "print_issn"=>"0737-1764",
#  "online_issn"=>"1536-0709",
#  "by_year_of_publication"=> {
#    "2018"=>"0",
#    "2017"=>"0",
#    "2016"=>"0",
#    "2015"=>"0",
#    "2014"=>"0",
#    "2013"=>"0",
#    "2012"=>"0",
#    "2011"=>"0",
#    "2010"=>"0",
#    "2009"=>"0",
#    "2008"=>"0",
#    "2007"=>"0",
#    "2006"=>"0",
#    "2005"=>"0",
#    "2004"=>"0",
#    "2003"=>"0",
#    "2002"=>"0",
#    "2001"=>"0",
#    "2000"=>"0",
#    "1999"=>"0",
#    "1998"=>"0",
#    "1997"=>"0",
#    "1996"=>"0",
#    "1995"=>"0",
#    "1994"=>"0",
#    "1993"=>"0",
#    "1992"=>"0",
#    "1991"=>"0",
#    "1990"=>"0",
#    "other"=>"2"
#   },
#   "total_usage"=>2
# }

# {
#   "doi"=>"10.1002/(ISSN)1536-0709a",
#   "journal"=>"AAHE-ERIC/Higher Education Research Report",
#   "proprietary_id"=>"AEHE",
#   "print_issn"=>"0737-1764",
#   "online_issn"=>"1536-0709",
#   "by_month"=>{
#     "2016-01"=>"0",
#     "2016-02"=>"0",
#     "2016-03"=>"0",
#     "2016-04"=>"0",
#     "2016-05"=>"0",
#     "2016-06"=>"0",
#     "2016-07"=>"0",
#     "2016-08"=>"0",
#     "2016-09"=>"1",
#     "2016-10"=>"0",
#     "2016-11"=>"0",
#     "2016-12"=>"0"
#   },
#   "summary"=>{
#     "total"=>"1",
#     "total_html"=>"0",
#     "total_pwd"=>"1"
#   }
# }

module WileyFiles
  class Flattener
  end
end