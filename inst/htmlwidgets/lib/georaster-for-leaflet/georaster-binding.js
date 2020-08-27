function mouseHandler(mapId, georaster, layerId, group, eventName) {
  return function(e) {
    if (!HTMLWidgets.shinyMode) return;
    let latLng = this.mouseEventToLatLng(e.originalEvent);
    var val = geoblaze.identify(georaster, [latLng.lng, latLng.lat]);
    if (val) {
      let eventInfo = $.extend({
        id: layerId,
        ".nonce": Math.random(),  // force reactivity
        group: group ? group : null,
        value: val[0]
        },
        e.latlng
      );
      Shiny.onInputChange(mapId + "_" + eventName, eventInfo);
    } else {
      Shiny.onInputChange(mapId + "_" + eventName, null);
    }
  };
}


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
        map.layerManager.addLayer(layer, "image", layerId, group);
        map.fitBounds(layer.getBounds());

        map.on("click", mouseHandler(map.id, georaster, layerId, group, "georaster_click"), this);
        map.on("mousemove", mouseHandler(map.id, georaster, layerId, group, "georaster_mousemove"), this);
      });
    });

};


LeafletWidget.methods.addCOG = function (url,
                                         group,
                                         layerId,
                                         resolution,
                                         opacity,
                                         options,
                                         colorOptions,
                                         pixelValuesToColorFn) {

  var map = this;

  var pane;  // could also use let
  if (options.pane === undefined) {
    pane = 'tilePane';
  } else {
    pane = options.pane;
  }

  parseGeoraster(url).then(georaster => {
    console.log("georaster:", georaster);

    /*
        GeoRasterLayer is an extension of GridLayer,
        which means can use GridLayer options like opacity.
        Just make sure to include the georaster option!
        http://leafletjs.com/reference-1.2.0.html#gridlayer
    */
    var layer = new GeoRasterLayer({
        georaster: georaster,
        resolution: resolution,
        opacity: opacity,
        pane: pane
    });
    map.layerManager.addLayer(layer, null, layerId, group);
    map.fitBounds(layer.getBounds());
  });
};
