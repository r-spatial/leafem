LeafletWidget.methods.addFlatGeoBuf = function (layerId,
                                                group,
                                                url,
                                                popup,
                                                label,
                                                style,
                                                options) {

  var map = this;
  var gl = false;

  var data_fl = document.getElementById(layerId + '-1-attachment');

  if (data_fl === null) {
    data_fl = url;
  } else {
    data_fl = data_fl.href;
  }

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
                  // var popUp = '<pre>'+JSON.stringify(feature.properties,null,1).replace(/[\{\}\,"]/g,'')+'&emsp;</pre>';
                  var popUp = json2table(feature.properties, "tab");
                  layer.bindPopup(popUp, { maxWidth: 2000 });
                };
              } else {
                pop = function(feature, layer) {
                  if (popup.length === 1) {
                    layer.bindPopup(feature.properties[popup].toString());
                  } else {
                    null;
                  }
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

// using fetch API to get readable stream
//fetch('https://raw.githubusercontent.com/bjornharrtell/flatgeobuf/2.0.1/test/data/UScounties.fgb')
//.then(handleResponse)

  fetch(data_fl) //, {mode: 'no-cors'})
  .then(handleResponse);

  //map.fitBounds(layer.getBounds());
  //map.layerManager.addLayer(layer, null, null, group);
};


function json2table(json, classes) {
  var cols = Object.keys(json);
  var vals = Object.values(json);

  var tab = "";

  for (i = 0; i < cols.length; i++) {
    tab += "<tr><th>" + cols[i] + "&emsp;</th>" +
    "<td align='right'>" + vals[i] + "&emsp;</td></tr>";
  }

  return "<table>" + tab + "</table>";

}
