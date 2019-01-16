# kibana_collections

Some experiments using Kibana and Elasticsearch to visualize data relating to journal prices and usage statistics.

## The goal
Visualize the data in spreadsheets, to assist in decisions about journal subscriptions. The hope is that clear depiction of price and usage statistics will help in the decision process.

## The approach
* Clean and combine the data.
	* Save the data as CSV files.
	* Scan each file, looking for irregularites in the data and reporting them.
	* Combine data across files, again reporting the degree of success.
* Load the data into an Elasticsearch index.
* Display the data using Kibana visualizations.
	* Create a "summary dashboard" that shows information about all journals
	* Include links to allow the user to "drill down" to  a "detail dashboard" 
	  that shows information about a single journal.

## How to use it?
* [Set up the Kibana/Elasticsearch stack](./doc/set_up_kibana.md)
* [Load the data and the visualizations](.doc/loading_into_kibana.md)

## How does it work?
* Check out the [Developer's notes](./doc/developer_notes.md)

## How to run it?
* [Running the system](./doc/running_the_system.md)

## How to modify it?
* [Development process](./doc/development_process.md)

## Problems?
* [Troubleshooting](./doc/troubleshooting.md)
