LeafletWidget.methods.addPMTiles = function(url,
                                         layerId,
                                         group
                                         ) {

  var map = this;
  // debugger;
  // var data_fl = document.getElementById(layerId + '-1-attachment');
  // data_fl = data_fl.href;

  let paint_rules = [{
    dataLayer: "zcta",
    symbolizer: new protomaps.PolygonSymbolizer({
      fill:"#ff0000",
      do_stroke: true,
      width: 0.5,
      color: "#000000"
    })
  }]

  var layer = protomaps.leafletLayer({
    url: url,
    // url: data_fl,
    paint_rules: paint_rules,
    label_rules: []
  })

  map.layerManager.addLayer(layer, null, layerId, group);
  return map;
};