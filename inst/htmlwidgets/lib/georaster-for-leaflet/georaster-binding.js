LeafletWidget.methods.addGeoRaster = function (url,
                                               group,
                                               layerId,
                                               resolution,
                                               opacity,
                                               colorOptions) {

  var map = this;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  const cols = colorOptions.palette;

  var scale = chroma.scale(cols);

  if (colorOptions.breaks !== null) {
    scale = scale.classes(colorOptions.breaks);
  }

  fetch(data_fl)
        .then(response => response.arrayBuffer())
        .then(arrayBuffer => {
          parseGeoraster(arrayBuffer).then(georaster => {
            var pixelValuesToColorFn = values => {
              let clr = scale.domain([georaster.mins, georaster.maxs]);
              return clr(values).hex();
            };
            console.log("georaster:", georaster);
            var layer = new GeoRasterLayer({
              georaster: georaster,
              pixelValuesToColorFn: pixelValuesToColorFn,
              resolution: resolution,
              opacity: opacity
            });
            layer.addTo(map);
            map.fitBounds(layer.getBounds());
        });
      });

};
