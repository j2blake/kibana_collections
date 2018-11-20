
# ------------------
#
# Create the index and populate it
#
# Create one document for each year that we have data on a journal.
# Use time-stamps for the years, so we play more nicely with Kibana
#
# ------------------
#
# Notes:
#
# - Do we need to keep year as an integer also? Let's try doing it with a scripted field in Kibana.
#
# - Skip these fields; they are never populated:
#   access, accessData, collection, isbn13, licencse, oclcNumber
#
# - Skip "costUsagePrintLines": can't imagine a use for it in Kibana.
#
# ------------------
#

# Delete the old one
curl -s -X DELETE "localhost:9200/collection_analysis_stamped" > /dev/null

# Create the new index with appropriate mapping
curl -X PUT 'localhost:9200/collection_analysis_stamped?pretty' -H 'Content-Type: application/json' \
     -d '@../../mappings/tf_sk_output/stamped_mapping.json'

# Show that the index exists
curl -X GET "localhost:9200/_cat/indices?v"

# Show the mapping
#curl -X GET "localhost:9200/collection_analysis_stamped/_mapping/_doc?pretty" 

# Populate the index
../../bin/tf_sk_output/populate_stamped_index.rb ../../raw_data/TF-SK-Output.json collection_analysis_stamped SEND