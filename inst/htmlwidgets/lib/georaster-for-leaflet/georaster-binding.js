LeafletWidget.methods.addGeoRaster = function (url,
                                               group,
                                               layerId) {

  var map = this;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  fetch(data_fl)
        .then(response => response.arrayBuffer())
        .then(arrayBuffer => {
          parseGeoraster(arrayBuffer).then(georaster => {
            console.log("georaster:", georaster);
            var layer = new GeoRasterLayer({
              georaster: georaster,
              resolution: 96
            });
            layer.addTo(map);
            map.fitBounds(layer.getBounds());
        });
      });

};
