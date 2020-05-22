LeafletWidget.methods.addFlatGeoBuf = function (layerId,
                                                group,
                                                url,
                                                popup,
                                                label,
                                                style,
                                                options,
                                                className) {

  var map = this;
  var gl = false;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

  var popUp;

  function handleResponse(response) {
    // use fgb JavaScript API to iterate stream into results (features as geojson)
    // NOTE: would be more efficient with a special purpose Leaflet deserializer
    let it = flatgeobuf.deserializeStream(response.body);
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
              if (popup === true) {
                pop = function(feature, layer) {
                  popUp = json2table(feature.properties, className);
                  layer.bindPopup(popUp, { maxWidth: 2000 });
                };
              } else if (typeof(popup) === "string") {
                pop = function(feature, layer) {
                  if (popup in feature.properties) {
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
              } else {
                pop = function(feature, layer) {
                  popUp = json2table(
                    pick(feature.properties, popup),
                    className
                  );
                  layer.bindPopup(popUp, { maxWidth: 2000 });
                };
              }
            } else {
              pop = null;
            }

            lyr = L.geoJSON(result.value, {
              pointToLayer: function (feature, latlng) {
                  return L.circleMarker(latlng, options);
              },
              style: style,
              onEachFeature: pop
            });

            if (label) {
              lyr.bindTooltip(function (layer) {
                 return layer.feature.properties[label].toString();
              }, {sticky: true});
            }

            map.layerManager.addLayer(lyr, null, null, group);
            it.next().then(handleResult);
          }
        }
    }
    it.next().then(handleResult);
  }

  fetch(data_fl) //, {mode: 'no-cors'})
  .then(handleResponse);

  //map.fitBounds(layer.getBounds());
  //map.layerManager.addLayer(layer, null, null, group);
};


function json2table(json, cls) {
  var cols = Object.keys(json);
  var vals = Object.values(json);

  var tab = "";

  for (i = 0; i < cols.length; i++) {
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
var pick = function (obj, props) {

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

};
