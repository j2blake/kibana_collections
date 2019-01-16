# Loading the data and dashboards into Kibana

* This discussion is about data that relates to Journals published in the **Wiley Online Library**. 
  The data is in two files that I received from Javed, and stored in [this directory][wiley_raw_data]. 

	* The files are `Wiley JR1 & JR5, 2016-2018.xls` and `WileyJournalsDatawithUsage (from Jeremy, Jesse).xlsx`.
      Some sheets from these files have been extracted into `.csv` files in [the same directory][wiley_raw_data].

* I also experimented with other files from Javed, `sample_data.csv` and `TF-SK-Output.json`. 
  The project contains Elasticsearch mappings for these files and scripts for loading them. 
  The project also contains some rudimentary visualizations for these data sets.
  
   * This discussion is not about those data sets.

## Load the data into Elasticsearch

* Open a terminal window
* `cd` to `scripts\wiley_files` within this project repository.
* Run the ruby application:

	```
	./create_wiley_first_index.sh
	```
	This takes about 25 minutes to run, and is silent for most of the time.

## Modify the exported object specifications

__*TBD*__

## Import the objects

__*TBD*__

## Bring up the summary dashboard in your browser

__*TBD*__


[wiley_raw_data]: ../raw_data/wiley_files