LeafletWidget.methods.addFlatGeoBuf = function (layerId,
                                                group,
                                                url,
                                                popup,
                                                label,
                                                style,
                                                options,
                                                className,
                                                scale,
                                                scaleFields) {

  var map = this;
  var gl = false;
  var pane;

  if (options === null || options.pane === undefined) {
    pane = 'overlayPane';
  } else {
    pane = options.pane;
  }

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  var popUp;
  var colnames = [];

  function handleHeaderMeta(headerMeta) {
    headerMeta.columns.forEach(function(col) {
      colnames.push(col.name);
    });
  }

  function handleResponse(response) {
    // use fgb JavaScript API to iterate stream into results (features as geojson)
    // NOTE: would be more efficient with a special purpose Leaflet deserializer
    let it = flatgeobuf.deserialize(response.body, undefined, handleHeaderMeta);
    var cntr = 0;
    // handle result
    function handleResult(result) {
        if (!result.done) {
          if (gl) {
            map.layerManager.addLayer(
              L.glify.shapes({
                map: map,
                data: result.value,
                className: group
              }).glLayer, null, null, group);
            it.next().then(handleResult);
          } else {

            if (popup) {
              pop = makePopup(popup, className);
            } else {
              pop = null;
            }

            if (scaleFields === null &
                result.value.properties !== undefined) {
              var vls = Object.values(style);
              scaleFields = [];
              vls.forEach(function(name) {
                //if (name in colnames) {
                if (colnames.includes(name)) {
                  scaleFields.push(true);
                } else {
                  scaleFields.push(false);
                }
              });
            }

            lyr = L.geoJSON(result.value, {
              pointToLayer: function (feature, latlng) {
                  return L.circleMarker(latlng, options);
              },
              style: function(feature) {
                return updateStyle(style, feature, scale, scaleFields);
              },
              onEachFeature: pop,
              pane: pane
            });

            if (label) {
              if (Object.keys(result.value.properties).includes(label)) {
                lyr.bindTooltip(function (layer) {
                  return layer.feature.properties[label].toString();
                }, {sticky: true});
              } else if (typeof(label) === Object || (typeof(label) === 'object' && label.length > 1)) {
                var lb = label[cntr];
                lyr.bindTooltip(function (layer) {
                  return(lb);
                }, {sticky: true});
              } else {
                lyr.bindTooltip(function (layer) {
                  return(label);
                }, {sticky: true});
              }
            }

            map.layerManager.addLayer(lyr, null, null, group);
            it.next().then(handleResult);
          }
        }
        cntr += 1;
    }
    it.next().then(handleResult);
  }

  fetch(data_fl) //, {mode: 'no-cors'})
  .then(handleResponse);

  //map.fitBounds(lyr.getBounds());
  //map.layerManager.addLayer(layer, null, null, group);
};

function makePopup(popup, className) {
  if (popup === true) {
    pop = function(feature, layer) {
      popUp = json2table(feature.properties, className);
      layer.bindPopup(popUp, { maxWidth: 2000 });
    };
  } else if (typeof(popup) === "string") {
    pop = function(feature, layer) {
      if (feature.properties !== undefined && popup in feature.properties) {
        popup = popup.split();
        popUp = json2table(
          pick(feature.properties, popup),
          className
        );
      } else {
        popUp = popup;
      }
      layer.bindPopup(popUp, { maxWidth: 2000 });
    };
  } else if (typeof(popup) === "object") {
    pop = function(feature, layer) {
      if (feature.properties.mvFeatureId !== undefined) {
        var idx = feature.properties.mvFeatureId;
        layer.bindPopup(popup[idx - 1], { maxWidth: 2000 });
      }
      if (feature.properties.mvFeatureId === undefined) {
        console.log("cannot bind popup to layer without id! Please file an issue at https://github.com/r-spatial/leafem/issues");
        layer.bindPopup("");
      }
    };
  } else {
    pop = function(feature, layer) {
      popUp = json2table(
        pick(feature.properties, popup),
        className
      );
      layer.bindPopup(popUp, { maxWidth: 2000 });
    };
  }
  return pop;
}


function json2table(json, cls) {
  var cols = Object.keys(json);
  var vals = Object.values(json);

  var tab = "";

  for (let i = 0; i < cols.length; i++) {
    tab += "<tr><th>" + cols[i] + "&emsp;</th>" +
    "<td align='right'>" + vals[i] + "&emsp;</td></tr>";
  }

  return "<table class=" + cls + ">" + tab + "</table>";

}


/**
 * from https://gomakethings.com/how-to-create-a-new-object-with-only-a-subject-of-properties-using-vanilla-js/
 *
 *
 * Create a new object composed of properties picked from another object
 * (c) 2018 Chris Ferdinandi, MIT License, https://gomakethings.com
 * @param  {Object} obj   The object to pick properties from
 * @param  {Array}  props An array of properties to use
 * @return {Object}       The new object
 */
function pick(obj, props) {

	'use strict';

	// Make sure object and properties are provided
	if (!obj || !props) return;

	// Create new object
	var picked = {};

	// Loop through props and push to new object
	props.forEach(function(prop) {
		picked[prop] = obj[prop];
	});

	// Return new object
	return picked;

}


function updateStyle(style_obj, feature, scale, scaleValues) {
  var cols = Object.keys(style_obj);
  var vals = Object.values(style_obj);

  var out = {};

  for (let i = 0; i < cols.length; i++) {
    if (vals[i] === null) {
      out[cols[i]] = feature.properties[cols[i]];
    } else {
      if (scaleValues !== undefined) {
        //if (Object.keys(feature.properties).includes(vals[i])) {
        if (scaleValues[i] === true) {
          vals[i] = rescale(
            feature.properties[vals[i]]
            , scale[cols[i]].to[0]
            , scale[cols[i]].to[1]
            , scale[cols[i]].from[0]
            , scale[cols[i]].from[1]
          );
        }
      }
      out[cols[i]] = vals[i];
    }
  }

  return out;
}


function rescale(value, to_min, to_max, from_min, from_max) {
  if (value === undefined) {
    value = from_min;
  }
  return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min;
}



LeafletWidget.methods.addFlatGeoBufFiltered = function (layerId,
                                                 group,
                                                 url,
                                                 popup,
                                                 label,
                                                 style,
                                                 options,
                                                 className,
                                                 scale,
                                                 scaleFields,
                                                 minZoom,
                                                 maxZoom) {

  var map = this;
  var gl = false;
  var pane;

  if (options === null || options.pane === undefined) {
    pane = 'overlayPane';
  } else {
    pane = options.pane;
  }

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  var popUp;
  var colnames = [];

  function handleHeaderMeta(headerMeta) {
    headerMeta.columns.forEach(function(col) {
      colnames.push(col.name);
    });
  }

  // convert the rect into the format flatgeobuf expects
  function fgBoundingBox() {
      const bounds = map.getBounds();
      return {
          minX: bounds.getWest(),
          maxX: bounds.getEast(),
          minY: bounds.getSouth(),
          maxY: bounds.getNorth(),
      };
  }

  // track the previous results so we can remove them when adding new results
  let previousResults = L.layerGroup();
  map.layerManager.addLayer(previousResults, null, layerId, group);
  async function updateResults() {
      // remove the old results
      map.layerManager.removeLayer(previousResults, layerId);
      previousResults.remove();
      const nextResults = L.layerGroup();
      map.layerManager.addLayer(nextResults, null, layerId, group);
      previousResults = nextResults;

      // Use flatgeobuf JavaScript API to iterate features as geojson.
      // Because we specify a bounding box, flatgeobuf will only fetch the resubset of data,
      // rather than the entire file.
      const iter = flatgeobuf.deserialize(data_fl, fgBoundingBox(), handleHeaderMeta);

      const colorScale = ((d) => {
                    return d > 750 ? '#800026' :
                        d > 500 ? '#BD0026' :
                        d > 250  ? '#E31A1C' :
                        d > 100 ? '#FC4E2A' :
                        d > 50   ? '#FD8D3C' :
                        d > 25  ? '#FEB24C' :
                        d > 10   ? '#FED976' :
                        '#FFEDA0'
      });
if (map.getZoom() >= minZoom & map.hasLayer(previousResults)) {
      for await (const feature of iter) {
            if (popup) {
              pop = makePopup(popup, className);
            } else {
              pop = null;
            }

          if (scaleFields === null &
                feature.properties !== undefined) {
              var vls = Object.values(style);
              scaleFields = [];
              vls.forEach(function(name) {
                //if (name in colnames) {
                if (colnames.includes(name)) {
                  scaleFields.push(true);
                } else {
                  scaleFields.push(false);
                }
              });
            }

          lyr = L.geoJSON(feature, {
              pointToLayer: function (feature, latlng) {
                  return L.circleMarker(latlng, options);
              },
              style: function(feature) {
                return updateStyle(style, feature, scale, scaleFields);
              },
              onEachFeature: pop,
              pane: pane
            });

            if (label) {
              if (Object.keys(feature.properties).includes(label)) {
                lyr.bindTooltip(function (layer) {
                  return layer.feature.properties[label].toString();
                }, {sticky: true});
              } else if (typeof(label) === Object || (typeof(label) === 'object' && label.length > 1)) {
                var lb = label[cntr];
                lyr.bindTooltip(function (layer) {
                  return(lb);
                }, {sticky: true});
              } else {
                lyr.bindTooltip(function (layer) {
                  return(label);
                }, {sticky: true});
              }
            }
         lyr.addTo(nextResults);
      }
  }
  }
  // if the user is panning around alot, only update once per second max
  //updateResults = _.throttle(updateResults, 1000);

  // show results based on the initial map
  updateResults();
  // ...and update the results whenever the map moves
  map.on("moveend", function(s){
      //rectangle.setBounds(getBoundForRect());
      updateResults();
  });
  map.on('layeradd', function(event) {
     if(event.layer == previousResults) {
         updateResults();
     }
});
};
