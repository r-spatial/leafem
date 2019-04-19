LeafletWidget.methods.addFile = function(group) {

  var map = this;

  L.geoJSON(data[group]).addTo(map);
};
