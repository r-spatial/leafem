LeafletWidget.methods.addPMTilesPolygons = function(
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

  var layers = layers || {};

  layers[layerId] = protomaps.leafletLayer({
    url: url,
    // url: data_fl,
    paint_rules: paint_rules,
    label_rules: []
  })

  // debugger;

  map.layerManager.addLayer(layers[layerId], null, layerId, group);
  if (map.hasLayer(layers[layerId])) {
    map.on("click", ev => {
      for (let result of layers[layerId].queryFeatures(ev.latlng.lng,ev.latlng.lat)) {
        if (result[1][0] !== undefined) {
          var popup = L.popup()
          .setLatLng(ev.latlng)
          .setContent(json2table(result[1][0].feature.props))
          .openOn(map);
        }
      }
    });
  };
  return map;
};


LeafletWidget.methods.addPMTilesPoints = function(
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
    symbolizer: new protomaps.CircleSymbolizer({
      fill: style.fillColor,
      stroke: style.stroke,
      width: style.width,
      radius: style.radius
    })
  }]

  var layers = layers || {};

  layers[layerId] = protomaps.leafletLayer({
    url: url,
    // url: data_fl,
    paint_rules: paint_rules,
    label_rules: []
  })

  // debugger;

  map.layerManager.addLayer(layers[layerId], null, layerId, group);
  if (map.hasLayer(layers[layerId])) {
    map.on("click", ev => {
      for (let result of layers[layerId].queryFeatures(ev.latlng.lng,ev.latlng.lat)) {
        if (result[1][0] !== undefined) {
          var popup = L.popup()
          .setLatLng(ev.latlng)
          .setContent(json2table(result[1][0].feature.props))
          .openOn(map);
        }
      }
    });
  };
  return map;
};