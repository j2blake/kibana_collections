# How to install images into the Kibana server

Found [instructions][Instructions] but they didn't work as written. 
Couldn't make Kibana recognize and serve images in 
`/opt/kibana/src/ui/public/images/`.

I kluged it by storing the image in the `assets/favicons` folder, which is not where it belongs, but it works.

## What works:

### Copy the file into the container

_with Docker container running:_

```
cd [github-workspace]]/kibana_collections/images
docker cp thumbnail_Javed.jpg 2ef82f2698b130ef4a198dcbabac49c7_elk_1:/opt/kibana/src/ui/public/assets/favicons/
```

### Restart Kibana

```
docker exec -it 2ef82f2698b130ef4a198dcbabac49c7_elk_1 /bin/bash
service kibana stop
service kibana start
```

### Check the file

_the image should be available at:_

```
http://localhost:5601/ui/favicons/thumbnail_Javed.jpg
```

### Create the visualization
Create a `Visual Builder` visualization. Choose `Markdown` from the nav bar, 
and add Markdown that includes this reference to the image:

```
![Javed thumbnail](/ui/favicons/thumbnail_Javed.jpg)
```


## What was supposed to work

[instructions][Instructions] said to put the image in `/opt/kibana/src/ui/public/images/`, and access it as 
`http://localhost:5601/bundles/src/ui/public/images/thumbnail_Javed.jpg`
but Kibana responded with `404`.


## Alternate plans

### Serve the image from somewhere else

```
<img src="http://example.com/path/to/image.jpg" alt="alt text" width="61" height="19">
```


[Instructions]: https://discuss.elastic.co/t/showing-images-in-kibana-6-dashoboard/122563/3

