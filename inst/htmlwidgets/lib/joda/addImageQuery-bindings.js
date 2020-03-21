/* global LeafletWidget, $, L */
LeafletWidget.methods.addImageQuery = function(layerId, bounds, type, digits, prefix) {
  (function(){
    var map = this;

    // Create correct bounding box.
    var boundsarr = [
      [bounds[3],bounds[0]],
      [bounds[1],bounds[2]]
      ];

    map.on(type, function(e) {
      rasterPicker.pick(e, layerId, boundsarr, digits, prefix, map);
    });
  }).call(this);
};

