LeafletWidget.methods.addLayerSelector = function (layers, layerId) {

  var map = this;

  window["lyr"] = map.layerManager.getLayer("geojson", layerId);

  let innerhtml = '<select id="layerSelector" onchange = "updateLayerStyle()" >';
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

getLayer = function() {
  var lyr = map.layerManager.getLayer("geojson", layerId);
  return(lyr);
}

updateLayerStyle = function(map) {
  var sel = document.getElementById("layerSelector");
  var colname = sel.options[sel.selectedIndex].text;
  console.log(colname);
  //console.log(colname);
  let fill = ''
  if (colname === "NUTS_ID") {
    fill = "pink"
  } else {
    fill = "black"
  };
  var layer = lyr;
  layer.eachLayer(function(layer) {
    console.log(layer.feature.properties[colname]);
    layer.setStyle({fillColor: chroma.random(), fillOpacity: 0.8})
  });
};

/*
chosenLayer = function() {
  var sel = document.getElementById("layerSelector");
  var layer = sel.options[sel.selectedIndex].text;
  //console.log(layer);
  return layer;
}
var geojsonLayer = L.geoJson(...); // a GeoJSON layer declared in the outer scope

function restyleLayer(propertyName) {

    geojsonLayer.eachLayer(function(featureInstanceLayer) {
        propertyValue = featureInstanceLayer.feature.properties[propertyName];

        // Your function that determines a fill color for a particular
        // property name and value.
        var myFillColor = getColor(propertyName, propertyValue);

        featureInstanceLayer.setStyle({
            fillColor: myFillColor,
            fillOpacity: 0.8,
            weight: 0.5
        });
    });
}

restyleLayer('myProperty');
*/