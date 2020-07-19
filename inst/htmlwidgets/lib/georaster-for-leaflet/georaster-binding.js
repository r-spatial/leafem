LeafletWidget.methods.addGeotiff = function (url,
                                             group,
                                             layerId,
                                             resolution,
                                             opacity,
                                             options,
                                             colorOptions,
                                             pixelValuesToColorFn) {

  var map = this;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  var pane;  // could also use let
  if (options.pane === undefined) {
    pane = 'tilePane';
  } else {
    pane = options.pane;
  }

  if (pixelValuesToColorFn === null) {
    pixelValuesToColorFn = (raster, colorOptions) => {
      const cols = colorOptions.palette;
      var scale = chroma.scale(cols);

      if (colorOptions.breaks !== null) {
        scale = scale.classes(colorOptions.breaks);
      }
      var pixelFunc = values => {
        let clr = scale.domain([raster.mins, raster.maxs]);
        if (isNaN(values)) return colorOptions.naColor;
        return clr(values).hex();
      };
      return pixelFunc;
    };
  }

  /*
  var pixelValuesToColorFn = values => {
              let clr = scale.domain([georaster.mins, georaster.maxs]);
              if (isNaN(values)) return colorOptions.naColor;
              return clr(values).hex();
            };
  */

  fetch(data_fl)
    .then(response => response.arrayBuffer())
    .then(arrayBuffer => {
      parseGeoraster(arrayBuffer).then(georaster => {
        console.log("georaster:", georaster);
        var layer = new GeoRasterLayer({
          georaster: georaster,
          pixelValuesToColorFn: pixelValuesToColorFn(georaster, colorOptions),
          resolution: resolution,
          opacity: opacity,
          pane: pane
        });
        map.layerManager.addLayer(layer, null, layerId, group);
        map.fitBounds(layer.getBounds());
      });
    });

};
