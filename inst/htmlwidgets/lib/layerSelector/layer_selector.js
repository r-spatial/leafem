LeafletWidget.methods.addLayerSelector = function (layers, layerId) {

  var map = this;

  var featurecollections = featurecollections || {};
  featurecollections[layerId]  = map.layerManager.getLayer("geojson", layerId);
  window.featurecollections = featurecollections;

  let innerhtml = '<select name="' + layerId + '" id="layerSelector" onchange = "updateLayerStyle(this.name)" >';
  let txt = '<option> ---choose layer--- </option>';
  innerhtml = innerhtml + txt;
  for(var i = 0; i < layers.length; i++) {
    txt = '<option>' + layers[i] + '</option>';
    innerhtml = innerhtml + txt;
  }
  innerhtml = innerhtml + '</select>'

  var selectr = L.control({position: 'topright'});
  selectr.onAdd = function (map) {
      var div = L.DomUtil.create('div', 'layerSelector');
      div.innerHTML = innerhtml;
      div.firstChild.onmousedown = div.firstChild.ondblclick = L.DomEvent.stopPropagation;
      return div;
  };
  selectr.addTo(map);

  //updateLayerStyle(lyr);
  //console.log(chosenLayer());
  return this;

};

getLayer = function(layerId) {
  var lyr = map.layerManager.getLayer("geojson", layerId);
  return(lyr);
}

updateLayerStyle = function(layerId) {
  var sel = document.getElementById("layerSelector");
  var colname = sel.options[sel.selectedIndex].text;
  console.log(layerId);

  var layer = featurecollections[layerId];

  var vals = [];
  layer_keys = Object.keys(layer._layers);
  for (var i = 0; i < layer_keys.length; i++) {
    vals[i] = layer._layers[layer_keys[i]].feature.properties[colname]
  }

  let colorFun = colFunc(vals);

  layer.eachLayer(function(layer) {
    console.log(layer.feature.properties[colname]);
    if (colname === "---choose layer---") {
      layer.setStyle(layer.defaultOptions.style(layer.feature));
    } else {
      layer.setStyle({fillColor: colorFun(layer.feature.properties[colname]), fillOpacity: 0.9})
    }
  });
};

colFunc = function(values) {

  let col;

  if (typeof(values[0]) === 'number') {
    mn = Math.min(...values);
    mx = Math.max(...values);
    col = chroma.scale("YlOrRd").domain([mn, mx]);
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