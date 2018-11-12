{
  "$schema": "https://vega.github.io/schema/vega/v3.json",
  "padding": 5,

  "data": [
  {
    "name": "valid",
    "url": {
      "%context%": true,
      "index": "costperuse_first",
      "body": {
        "size": 10000,
        "_source": ["price", "averageUsage", "name"]
      }
    },
    "format": {
      "property": "hits.hits"
    },
    "transform": [
      { 
        "type": "formula", 
        "expr": "datum._source.name", 
        "as": "link"      
      },
      {
        "type": "filter",
        "expr": "datum._source.price != null && datum._source.averageUsage != null"
      }
    ]
  }
  ],
  "scales": [
    {
      "name": "x",
      "type": "linear",
      "round": true,
      "nice": true,
      "zero": true,
      "domain": {"data": "valid", "field": "_source.price"},
      "range": "width"
    },
    {
      "name": "y",
      "type": "linear",
      "round": true,
      "nice": true,
      "zero": true,
      "domain": {"data": "valid", "field": "_source.averageUsage"},
      "range": "height"
    }
  ],

  "axes": [
    {
      "scale": "x",
      "grid": true,
      "domain": false,
      "orient": "bottom",
      "tickCount": 5,
      "title": "Price"
    },
    {
      "scale": "y",
      "grid": true,
      "domain": false,
      "orient": "left",
      "titlePadding": 5,
      "title": "Average Usage"
    }
  ],

  "marks": [
    {
      "name": "marks",
      "type": "symbol",
      "from": {"data": "valid"},
      "interactive": true,
      "encode": {
        "enter": {
          "x": {"scale": "x", "field": "_source.price"},
          "y": {"scale": "y", "field": "_source.averageUsage"},
          "shape": {"value": "circle"},
          "strokeWidth": {"value": 2},
          "opacity": {"value": 0.5},
          "stroke": {"value": "#4682b4"},
          "fill": {"value": "transparent"},
          "tooltip": {"field": "_source.name"},
          "href" : {"field": "link"}
        }
      }
    }
  ]
}
