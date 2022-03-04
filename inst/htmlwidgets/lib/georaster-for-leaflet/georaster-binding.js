LeafletWidget.methods.addGeotiff = function (url,
                                             group,
                                             layerId,
                                             resolution,
                                             bands,
                                             arith,
                                             opacity,
                                             options,
                                             colorOptions,
                                             rgb,
                                             pixelValuesToColorFn,
                                             autozoom) {

  var map = this;

  // check if file attachment or url
  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  // define pane
  var pane;  // could also use let
  if (options.pane === undefined) {
    pane = 'tilePane';
  } else {
    pane = options.pane;
  }

  // fetch data and add to map
  fetch(data_fl)
    .then(response => response.arrayBuffer())
    .then(arrayBuffer => {
      parseGeoraster(arrayBuffer).then(georaster => {
        // get color palette etc
        const cols = colorOptions.palette;
        let scale = chroma.scale(cols);
        let domain = colorOptions.domain;
        let nacol = colorOptions["na.color"];
        if (colorOptions.breaks !== null) {
          scale = scale.classes(colorOptions.breaks);
        }

        let mins = georaster.mins;
        let maxs = georaster.maxs;
        if (arith === null & bands.length > 1) {
          mins = mins[bands[0]];
          maxs = maxs[bands[0]];
        }

        // get raster min/max values
        let min;
        if (typeof(mins) === "object") {
          min = Math.min.apply(null, mins.filter(naExclude));
        }
        if (typeof(mins) === "number") {
          min = mins;
        }

        let max;
        if (typeof(maxs) === "object") {
          max = Math.max.apply(null, maxs.filter(naExclude));
        }
        if (typeof(maxs) === "number") {
          max = maxs;
        }

        // define domain using min max
        if (domain === null) {
          if (arith === null) {
            domain = [min, max];
          }
          if (arith !== null) {
            var a = prepareArray(mins, maxs);
            var arr = wrapArrays(a, a.length);
            domain = evalDomain(arr, arith);
            console.log("domain:" + domain);
          }
        }

        // if rgb, scale values to 0 - 255
        if (rgb) {
          if (max !== 255) {
            georaster.values = deepMap(
              georaster.values
              , x => scaleValue(x, [min,max], [0, 255])
            );
          }
        }

        // define pixel value -> colorm mapping (if not provided)
        if (pixelValuesToColorFn === null) {
          pixelValuesToColorFn = values => {
            let vals;
            if (arith === null) {
              if (bands.length > 1) {
                bands = bands[0];
              }
              vals = values[bands];
            }
            if (arith !== null) {
              vals = evalMath(arith, values);
            }
            let clr = scale.domain(domain);
            if (isNaN(vals) || vals === georaster.noDataValue) return nacol;
            return clr(vals).hex();
          };
        } else {
          pixelValuesToColorFn = pixelValuesToColorFn;
        }

        // define layer and add to map
        //console.log("georaster:", georaster);
        var layer = new GeoRasterLayer({
          georaster: georaster,
          debugLevel: 0,
          pixelValuesToColorFn: pixelValuesToColorFn,
          resolution: resolution,
          opacity: opacity,
          pane: pane
        });
        map.layerManager.addLayer(layer, null, layerId, group);

        if (autozoom) {
          map.fitBounds(layer.getBounds());
        }
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
                                         pixelValuesToColorFn,
                                         autozoom,
                                         rgb) {

  var map = this;

  var pane;  // could also use let
  if (options.pane === undefined) {
    pane = 'tilePane';
  } else {
    pane = options.pane;
  }

  parseGeoraster(url).then(georaster => {
    console.log("georaster:", georaster);

    if (colorOptions !== null) {
      // get color palette etc
      const cols = colorOptions.palette;
      let scale = chroma.scale(cols);
      let domain = colorOptions.domain;
      let nacol = colorOptions["na.color"];
      if (colorOptions.breaks !== null) {
        scale = scale.classes(colorOptions.breaks);
      }
/*
    let mins = georaster.mins;
    let maxs = georaster.maxs;

    // get raster min/max values
    let min;
    if (typeof(mins) === "object") {
      min = Math.min.apply(null, mins.filter(naExclude));
    }
    if (typeof(mins) === "number") {
      min = mins;
    }

    let max;
    if (typeof(maxs) === "object") {
      max = Math.max.apply(null, maxs.filter(naExclude));
    }
    if (typeof(maxs) === "number") {
      max = maxs;
    }

    // define domain using min max
    if (domain === null) {
      domain = [min, max];
    }

    // if rgb, scale values to 0 - 255
    if (rgb) {
      if (max !== 255) {
        georaster.values = deepMap(
          georaster.values
          , x => scaleValue(x, [min,max], [0, 255])
        );
      }
    }
*/
      // define pixel value -> colorm mapping (if not provided)
      if (pixelValuesToColorFn === null) {
        pixelValuesToColorFn = values => {
          //let vals;
          let clr = scale.domain(domain);
          if (isNaN(values) || values === georaster.noDataValue) return nacol;
          //console.log(values);
          return clr(values).hex();
        };
      } else {
        pixelValuesToColorFn = pixelValuesToColorFn;
      }
    }


    /*
        GeoRasterLayer is an extension of GridLayer,
        which means can use GridLayer options like opacity.
        Just make sure to include the georaster option!
        http://leafletjs.com/reference-1.2.0.html#gridlayer
    */
    var layer = new GeoRasterLayer({
        georaster,
        resolution: resolution,
        opacity: opacity,
        pixelValuesToColorFn: pixelValuesToColorFn,
        pane: pane
    });
    map.layerManager.addLayer(layer, null, layerId, group);

    if (autozoom) {
      map.fitBounds(layer.getBounds());
    }
  });
};
