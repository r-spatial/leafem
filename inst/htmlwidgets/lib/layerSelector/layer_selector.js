LeafletWidget.methods.addLayerSelector = function (layers) {

  var map = this;

  innerhtml = '<select id="layerSelector" onchange = "chosenLayer()" >';
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

};

chosenLayer = function() {
  var sel = document.getElementById("layerSelector");
  console.log(sel.options[sel.selectedIndex].text);
}


/*
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