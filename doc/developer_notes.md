# Developer notes

## Drill-down to another dashboard

* It appears that there is no sanctioned way to do this.
* Hacking around:
	* Here is the URL for a dashboard with a filter on it:

		```
http://localhost:5601/app/kibana#/dashboard/cc8aef50-e43f-11e8-b9e6-ab54006f449f?_a=(description:'',filters:!(('$state':(store:appState),meta:(alias:!n,disabled:!f,index:e13aa690-e2b7-11e8-98f2-dfa5943e64ba,key:_id,negate:!f,params:(query:'2158496682',type:phrase),type:phrase,value:'2158496682'),query:(match:(_id:(query:'2158496682',type:phrase))))),fullScreenMode:!f,options:(darkTheme:!f,hidePanelTitles:!f,useMargins:!t),panels:!((embeddableConfig:(),gridData:(h:15,i:'1',w:24,x:0,y:0),id:dce61650-e2b3-11e8-98f2-dfa5943e64ba,panelIndex:'1',type:visualization,version:'6.4.2'),(embeddableConfig:(),gridData:(h:15,i:'2',w:24,x:24,y:0),id:'7599b0b0-e2b3-11e8-98f2-dfa5943e64ba',panelIndex:'2',type:search,version:'6.4.2')),query:(language:kuery,query:''),timeRestore:!f,title:'costperuse%20one_journal%20dashboard',viewMode:view)&_g=()
		```
		
	* After hacking around, pared it down to this:

		```
http://localhost:5601/app/kibana#/dashboard/cc8aef50-e43f-11e8-b9e6-ab54006f449f?_a=(filters:!((meta:(index:e13aa690-e2b7-11e8-98f2-dfa5943e64ba,key:_id,params:(query:'2158496682'),value:'2158496682'),query:(match:(_id:(query:'2158496682'))))))
		```
		
	* Carving away the "index" parameter gives the same page, 
	with the same filtering, but the filter does not appear in the filter bar.