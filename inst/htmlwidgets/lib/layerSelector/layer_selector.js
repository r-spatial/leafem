LeafletWidget.methods.addGeoJSONLayerSelector = function(layers,
                                                         layerId,
                                                         position,
                                                         options) {

  var map = this;

  window.styleOpts = window.styleOpts || {};
  window.styleOpts[layerId] = options;

  updateLayerStyle = updateLayerStyler(map, layerId, styleOpts);

  let innerhtml = '<label><strong>' +
    layerId +
    ': </strong></label><br><select name="' +
    layerId +
    '" id="layerSelector-' +
    layerId +
    '" onchange = "updateLayerStyle(this.name)" >';
  let txt = '<option> ---choose layer--- </option>';
  innerhtml = innerhtml + txt;
  for(var i = 0; i < layers.length; i++) {
    txt = '<option>' + layers[i] + '</option>';
    innerhtml = innerhtml + txt;
  }
  innerhtml = innerhtml + '</select>'

  var selectr = L.control({position: position});
  selectr.onAdd = function (map) {
      var div = L.DomUtil.create('div', 'layerSelector');
      div.innerHTML = innerhtml;
      div.firstChild.onmousedown = div.firstChild.ondblclick = L.DomEvent.stopPropagation;
      return div;
  };
  selectr.addTo(map);

};

updateLayerStyler = function(map, layerId, options) {

  layerFunc = function(layerId) {

  var layer = map.layerManager.getLayer("geojson", layerId);

    var sel = document.getElementById("layerSelector-" + layerId);
    var colname = sel.options[sel.selectedIndex].text;
    console.log(layerId);

    var vals = [];
    layer_keys = Object.keys(layer._layers);
    for (var i = 0; i < layer_keys.length; i++) {
      vals[i] = layer._layers[layer_keys[i]].feature.properties[colname]
    }

    let colorFun = colFunc(vals, options[layerId][colname]);

    layer.eachLayer(function(layer) {
      console.log(layer.feature.properties[colname]);
      if (colname === "---choose layer---") {
        layer.setStyle(layer.defaultOptions.style(layer.feature));
      } else {
        layer.setStyle(
          {
            fillColor: colorFun(layer.feature.properties[colname]),
            fillOpacity: 0.9,
            color: colorFun(layer.feature.properties[colname]),
            opacity: 0.9
          }
        )
      }
    });
  };

  return layerFunc;

};

colFunc = function(values, options) {

  let col;

  if (options === undefined) {
    options = {};
    options.palette = null;
    options.breaks = null;
    options.domain = null;
    options.nacol = null;
  }

  if (typeof(values[0]) === 'number') {
    // domain
    if (options.domain === null) {
      mn = Math.min(...values);
      mx = Math.max(...values);
      col = chroma.scale("YlOrRd").domain([mn, mx]);
    } else {
      col = chroma.scale("YlOrRd").domain(options.domain);
    }
  } else if (typeof(values[0]) === 'string') {
    //var arr = ["c", "a", "b", "b"];
    let unique = [...new Set(values)];
    clrs = chroma.scale("Set1").colors(unique.length);
    var clrArr = Object.fromEntries(unique.map((key, index)=> [key, clrs[index]]));
    col = function(val) {
      return clrArr[val];
    }
  }
  return col;
}