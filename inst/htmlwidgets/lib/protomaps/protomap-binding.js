LeafletWidget.methods.addPMTiles = function(file,
                                         layerId,
                                         group
                                         ) {

  var map = this;
  // debugger;
  var data_fl = document.getElementById(layerId + '-1-attachment');
  data_fl = data_fl.href;

  var layer = protomaps.leafletLayer({url:data_fl})

  map.layerManager.addLayer(layer, null, layerId, group);
  return map;
};