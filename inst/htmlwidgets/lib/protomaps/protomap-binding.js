LeafletWidget.methods.addPMTiles = function(
  url
  , file
  , layerId
  , group
  , style
) {

  var map = this;
  // debugger;
  // var data_fl = document.getElementById(layerId + '-1-attachment');
  // data_fl = data_fl.href;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    url = url;
  } else {
    url = data_fl.href;
  }


  let paint_rules = [{
    dataLayer: style.layer,
    symbolizer: new protomaps.PolygonSymbolizer({
      fill: style.fillColor,
      do_stroke: style.do_stroke,
      width: style.width,
      color: style.color
    })
  }]

  var layer = protomaps.leafletLayer({
    url: url,
    // url: data_fl,
    paint_rules: paint_rules,
    label_rules: []
  })

  debugger;

  map.layerManager.addLayer(layer, null, layerId, group);
  if (map.hasLayer(layer)) {
    map.on("click", ev => {
      for (let result of layer.queryFeatures(ev.latlng.lng,ev.latlng.lat)) {
        console.log(result[1][0].feature.props);
        layer.bindPopup(json2table(result[1][0].feature.props)); //FIXME HERE!
      }
    });
  };
  return map;
};