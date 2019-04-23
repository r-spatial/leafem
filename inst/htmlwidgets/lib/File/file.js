LeafletWidget.methods.addFile = function(layerId,
                                         group,
                                         popup,
                                         label,
                                         options,
                                         style) {

  var map = this;

  var pop;
  if (popup) {
    pop = function(feature, layer) {
      var popUp = '<pre>'+JSON.stringify(feature.properties,null,' ').replace(/[\{\}"]/g,'')+'</pre>';
      layer.bindPopup(popUp, { maxWidth: 2000 });
    };
  } else {
    pop = null;
  }

  var layer = L.geoJSON(data[group], {
    pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, options);
    },
    style: style,
    onEachFeature: pop
  });

  var lab;
  if (label) {
    lab = function(layer) {
      return String(layer.feature.properties[label]);
    };
    layer = layer.bindTooltip(lab, {sticky: true});
  } else {
    lab = null;
  }

  this.layerManager.addLayer(layer, null, null, group);
};
