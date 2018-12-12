
# ------------------
#
# Read CostPerUseAll.csv and put it into an index, flattened by year of usage data
# (2016, 2017, 2018)
#
# Create one document for each year that we have data on a journal.
#
# ------------------
#
# Notes:
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
