function mouseHandler(map, georaster, layerId, group, eventName) {
  return function(e) {
    let outputWidget = getInfoLegend(layerId);
    if (!(map.layerManager.getVisibleGroups().includes(group))) {
      $(outputWidget).hide();
      return;
    }

    let latLng = this.mouseEventToLatLng(e.originalEvent);
    let val = geoblaze.identify(georaster, [latLng.lng, latLng.lat]);

    if (val) {
      outputWidget.innerHTML = renderInfo(val, layerId, 1, "");
      let eventInfo = $.extend({
        id: layerId,
        ".nonce": Math.random(),  // force reactivity
        group: group ? group : null,
        value: val[0]
        },
        e.latlng
      );
      if (HTMLWidgets.shinyMode) {
        Shiny.onInputChange(map.id + "_" + eventName, eventInfo);
      }
    } else {
      $(outputWidget).hide();
      if (HTMLWidgets.shinyMode) {
        Shiny.onInputChange(map.id + "_" + eventName, null);
      }
    }
  };
}
function renderInfo(val, layerId, digits, prefix) {
  $(document.getElementById("rasterValues-" + layerId)).show();
  let text = "<small>"+ "Layer"+ " <strong> "+ layerId + ": </strong>"+ val + "</small>";
  return text;
}
function getInfoLegend(layerId) {
  let element = window.document.getElementById("rasterValues-" + layerId);
  if (element === null) {
    console.log("leafem: No control widget found in Leaflet setup. Can't show layer info.");
  }
  return element;
}


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
                                             pixelValuesToColorFn) {

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
        let nacol = colorOptions.naColor;
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
              vals = eval(arith);
            }
            let clr = scale.domain(domain);
            if (isNaN(vals)) return nacol;
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
        map.layerManager.addLayer(layer, "image", layerId, group);
        map.fitBounds(layer.getBounds());

        map.on("click", mouseHandler(map, georaster, layerId, group, "georaster_click"), this);
        map.on("mousemove", mouseHandler(map, georaster, layerId, group, "georaster_mousemove"), this);
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
