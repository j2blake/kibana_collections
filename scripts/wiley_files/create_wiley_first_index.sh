
# ------------------
#
# Read the data files from raw_data/wiley_files, merge the data together, and
# put it into an index, flattened in a variety of ways:
#
# For each journal, create a summary record.
# For each journal, for every month that we have recorded usage, create a "by_month" record
# For each journal, for every year-of-publication usage count, create a "by-year-of-publication" record.
#
# ------------------
#
# Notes:
#
# Runs for about 25 minutes to create about 270,000 records
#
# ------------------
#

# Delete the old one
curl -s -X DELETE "localhost:9200/wiley_first" > /dev/null

# Create the new index with appropriate mapping
curl -X PUT 'localhost:9200/wiley_first?pretty' -H 'Content-Type: application/json' \
     -d '@../../mappings/wiley_files/wiley_first.json'

# Show that the index exists
curl -X GET "localhost:9200/_cat/indices?v"

# Show the mapping
#curl -X GET "localhost:9200/wiley_first/_mapping/_doc?pretty" 

# Populate the index
../../bin/wiley_files/analyze_wiley_files.rb ../../raw_data/wiley_files/ -o ELASTIC -i wiley_first
