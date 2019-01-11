# How to set up Kibana and view the visualizations

## Install the Kibana/Elasticsearch stack

These instructions will install the entire **ELK Stack**, referring to the combination of 
_Elasticsearch_, _Logstash_, and _Kibana_. However, we aren't using _Logstash_ in this application.

I installed on a MacBook Pro, running macOS 10.13.3 High Sierra. 
Other platforms will need to adjust accordingly.

These instructions are based on a [Gist][Nicks_gist] created by Nick Cappadona. 
Kibana also provides instructions for running [Kibana on Docker][Kibana_docker], 
but I used [Nick's Gist][Nicks_gist].

The instructions in Nick's Gist are based on [CUL's ELK dashboard project][CUL_ELK].

### Install Homebrew

If you don't have the _Homebrew_ package manager, [install _Homebrew_][Homebrew_install]. 
This is simple and straightforward.

### Install and configure Docker

Install Docker, launch it, and increase the memory allocation, as described in [the CUL_ELK README.md][CUL_ELK].

### Install the dockerized ELK stack

Instead of cloning the [CUL ELK dashboard][CUL_ELK], clone the repo of [Nick's Gist][Nicks_gist]
to install the ELK stack.

Build the image. Run the container.

_Note: There is no need to specify CSV columns, or install **Filebeat**, as Nick describes._

## Modify the Kibana configuration
The scatter-plot on the summary dashboard will contain HTTP links to drill down to the detail dashboard. 
By default, the VEGA engine will not allow the browser to follow HTTP links from the visualizations.

There is probably a better way to accomplish this, but this is what I found to work. 
This won't survive a rebuild, and will need to be repeated in that case.

* Start the dockerized ELK stack

    If not already running,

	```
	docker-compose start
	```

* Find out the ID of the running Docker container

	```
	docker ps --quiet
	```

* Find out the ID of the running Docker container

	```
	docker exec -it 9999ffff9999 /bin/bash
	```
	where `9999ffff9999` will be replaced by the ID you found in the previous step.
	
* Edit the file

	```
	cd /opt/kibana/config
   vi kibana.yml
	```

   Add this line: `vega.enableExternalUrls: true`
   
* Reload and restart Kibana

	```
   service kibana force-reload
	```


[Nicks_gist]: https://gist.github.com/cappadona/2ef82f2698b130ef4a198dcbabac49c7
[Kibana_docker]: https://www.elastic.co/guide/en/kibana/current/docker.html
[Homebrew_install]: https://brew.sh/
[CUL_ELK]: https://github.com/cul-it/elk-docker#local-deploy