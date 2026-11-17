function mouseHandler(map, georaster, layerId, group, eventName, options) {
  return function(e) {

    let outputWidget = getInfoLegend(layerId);

    if (!(map.layerManager.getVisibleGroups().includes(group))) {
      $(outputWidget).hide();
      return;
    }

    let latLng = this.mouseEventToLatLng(e.originalEvent);

    let val = geoblaze.identify(georaster, [latLng.lng, latLng.lat]);

    let finaltype = "georaster_" + options.type;
    let query = options.imagequery && finaltype == eventName;

    if (val) {
      if (options.noData !== "NoData Value" & val[0] === georaster.noDataValue) {
        val[0] = options.noData
      }
      if (query) {
        outputWidget.innerHTML = renderInfo(val, layerId, options.digits, options.prefix, options.suffix);
      }
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
      if (query) {
        $(outputWidget).hide();
      }
      if (HTMLWidgets.shinyMode) {
        Shiny.onInputChange(map.id + "_" + eventName, null);
      }
    }
  };
}
function renderInfo(val, layerId, digits, prefix, suffix) {
  $(document.getElementById("rasterValues-" + layerId)).show();
  let text = "";
  if(digits === "null" || digits === null) {
    text = "<small>"+ prefix+ " <strong>"+ layerId + ": </strong>"+ val + (suffix.startsWith(" ") ? suffix : " " + suffix) + "</small>";
  } else {
    text = "<small>"+ prefix+ " <strong>"+ layerId + ": </strong>"+ val[0].toFixed(digits) + (suffix.startsWith(" ") ? suffix : " " + suffix) + "</small>";
  }
  return text;
}
function getInfoLegend(layerId) {
  let element = window.document.getElementById("rasterValues-" + layerId);
  if (element === null) {
    console.log("leafem: No control widget found in Leaflet setup. Can't show layer info.");
  }
  return element;
}
function makeControl(layerId, options, map) {
  info = L.control({
    position: options.position ? options.position : "topright"
  });
  let ctrl_nm = "rasterValues-" + layerId;
  info.onAdd = function(map) {
    this._div = L.DomUtil.create('div', options.className + ' rastervals');
    this._div.id = ctrl_nm;
    this._div.innerHTML = "";
    return this._div;
  };
  info.addTo(map);
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
                                             pixelValuesToColorFn,
                                             autozoom,
                                             imagequeryOptions) {

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

  // Create a container div for the control
  if (imagequeryOptions && imagequeryOptions.imagequery == true) {
    makeControl(layerId, imagequeryOptions, map)
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

        map.layerManager.addLayer(layer, "image", layerId, group);
        if (autozoom) {
          map.fitBounds(layer.getBounds());
        }

        map.on("click", mouseHandler(map, georaster, layerId,
          group, "georaster_click", imagequeryOptions), this);
        map.on("mousemove", mouseHandler(map, georaster, layerId,
          group, "georaster_mousemove", imagequeryOptions), this);

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
                                         rgb,
                                         imagequeryOptions) {

  var map = this;
  var pane;  // could also use let
  if (options.pane === undefined) {
    pane = 'tilePane';
  } else {
    pane = options.pane;
  }

  // Create a container div for the control
  if (imagequeryOptions && imagequeryOptions.imagequery == true) {
    makeControl(layerId, imagequeryOptions, map)
  }

  // Pass the url (not a downloaded buffer) so that georaster streams the COG:
  // only the tiles and overview level needed for the current view are read
  // with HTTP range requests.
  parseGeorasterCOG(url).then(georaster => {

    cogColorFn(georaster, colorOptions, pixelValuesToColorFn).then(colorFn => {

      var layer = new GeoRasterLayer({
        georaster: georaster,
        resolution: resolution,
        opacity: opacity,
        pixelValuesToColorFn: colorFn,
        pane: pane
      });
      map.layerManager.addLayer(layer, "image", layerId, group);
      if (autozoom) {
        map.fitBounds(layer.getBounds());
      }

      map.on("click", cogMouseHandler(map, georaster, layerId,
        group, "georaster_click", imagequeryOptions), this);
      map.on("mousemove", cogMouseHandler(map, georaster, layerId,
        group, "georaster_mousemove", imagequeryOptions), this);

    });
  });
};

// Pixel value -> colour function for a streamed (COG) georaster. A streamed
// georaster has no values in memory, so mins/maxs are unknown; when
// colorOptions gives no domain, it is taken from the smallest overview.
function cogColorFn(georaster, colorOptions, pixelValuesToColorFn) {
  if (pixelValuesToColorFn !== null) {
    return Promise.resolve(pixelValuesToColorFn);
  }
  if (colorOptions === null) {
    return Promise.resolve(undefined);  // georaster-layer-for-leaflet default
  }
  let scale = chroma.scale(colorOptions.palette);
  if (colorOptions.breaks !== null) {
    scale = scale.classes(colorOptions.breaks);
  }
  let nacol = colorOptions["na.color"];
  let domain = colorOptions.domain;
  let getDomain;
  if (domain !== null) {
    getDomain = Promise.resolve(domain);
  } else {
    getDomain = georaster.getValues({
      left: 0, top: 0, right: georaster.width, bottom: georaster.height,
      width: 256, height: 256, resampleMethod: "nearest"
    }).then(bands => {
      let min = Infinity, max = -Infinity;
      bands[0].forEach(row => row.forEach(v => {
        if (!isNaN(v) && v !== georaster.noDataValue) {
          if (v < min) min = v;
          if (v > max) max = v;
        }
      }));
      return [min, max];
    });
  }
  return getDomain.then(d => {
    let clr = scale.domain(d);
    return values => {
      let v = values[0];
      if (v === null || isNaN(v) || v === georaster.noDataValue) return nacol;
      return clr(v).hex();
    };
  });
}

// Like mouseHandler(), but for a streamed georaster: read just the one pixel
// under the mouse (geotiff.js caches the tile, so moving within it is cheap).
// Mouse position -> pixel needs the raster CRS; EPSG:4326 and EPSG:3857 are
// supported (the ones proj4 knows without a definition).
function cogMouseHandler(map, georaster, layerId, group, eventName, options) {
  return function(e) {

    let outputWidget = getInfoLegend(layerId);

    if (!(map.layerManager.getVisibleGroups().includes(group))) {
      $(outputWidget).hide();
      return;
    }

    let latLng = this.mouseEventToLatLng(e.originalEvent);
    let finaltype = "georaster_" + options.type;
    let query = options.imagequery && finaltype == eventName;

    let xy;
    if (georaster.projection === 4326) {
      xy = [latLng.lng, latLng.lat];
    } else if (georaster.projection === 3857) {
      xy = proj4("EPSG:4326", "EPSG:3857", [latLng.lng, latLng.lat]);
    } else {
      return;
    }
    let col = Math.floor((xy[0] - georaster.xmin) / georaster.pixelWidth);
    let row = Math.floor((georaster.ymax - xy[1]) / georaster.pixelHeight);

    let show = function(val) {
      if (val !== null) {
        if (options.noData !== "NoData Value" & val[0] === georaster.noDataValue) {
          val[0] = options.noData
        }
        if (query) {
          outputWidget.innerHTML = renderInfo(val, layerId, options.digits, options.prefix, options.suffix);
        }
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
        if (query) {
          $(outputWidget).hide();
        }
        if (HTMLWidgets.shinyMode) {
          Shiny.onInputChange(map.id + "_" + eventName, null);
        }
      }
    };

    if (col < 0 || row < 0 || col >= georaster.width || row >= georaster.height) {
      show(null);
      return;
    }
    georaster.getValues({
      left: col, top: row, right: col + 1, bottom: row + 1, width: 1, height: 1
    }).then(bands => show(bands.map(b => b[0][0])));
  };
}

/*
    if (colorOptions !== null) {
      // get color palette etc
      const cols = colorOptions.palette;
      let scale = chroma.scale(cols);
      let domain = colorOptions.domain;
      let nacol = colorOptions["na.color"];
      if (colorOptions.breaks !== null) {
        scale = scale.classes(colorOptions.breaks);
      }
    }
*/
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

/*
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
*/

    /*
        GeoRasterLayer is an extension of GridLayer,
        which means can use GridLayer options like opacity.
        Just make sure to include the georaster option!
        http://leafletjs.com/reference-1.2.0.html#gridlayer
    */

