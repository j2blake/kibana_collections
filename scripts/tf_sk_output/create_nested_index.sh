
# ------------------
#
# Create the index and populate it
#
# Create one document per journal, with year-based data in a nested structure.
#
# ------------------
#
# Notes:
#
# - Do we need the name as both a text field and a keyword (name.raw)?
#
# - Skip these fields; they are never populated:
#   access, accessData, collection, isbn13, licencse, oclcNumber
#
# - Skip "costUsagePrintLines": can't imagine a use for it in Kibana.
#
# ------------------
#

# Delete the old one
curl -s -X DELETE "localhost:9200/collection_analysis_nested?pretty" > /dev/null

# Create the new index with appropriate mapping
curl -X PUT 'localhost:9200/collection_analysis_nested?pretty' -H 'Content-Type: application/json' \
     -d '@../../mappings/tf_sk_output/nested_mapping.json'

# Show that the index exists
curl -X GET "localhost:9200/_cat/indices?v"

# Show the mapping
#curl -X GET "localhost:9200/collection_analysis_nested/_mapping/journal?pretty" 

# Populate the index
../../bin/tf_sk_output/populate_nested_index.rb ../../raw_data/TF-SK-Output.json collection_analysis_nested SEND