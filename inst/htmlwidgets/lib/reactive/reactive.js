LeafletWidget.methods.addReactiveLayer = function(x,
                                                  bindTo,
                                                  by,
                                                  on,
                                                  group,
                                                  layerId,
                                                  options,
                                                  style,
                                                  updateStyle,
                                                  popup) {

    var map = this;
    let out;
    if (on === "click") {
      out = "contextmenu";
    }
    if (on === "mouseover") {
      out = "mouseout";
    }

    var pop = [];

    if (typeof(popup) === "string") {
      //pop = new Array(x.features.length);
      for (var i = 0; i <= x.features.length; i++) {
        pop.push(popup);
      }
    }

    if (typeof(popup) === "object") {
      if (popup === null) {
        pop = null;
      } else if (popup.length == x.features.length) {
        pop = popup;
      }
    }

    var bindto_layer = map.layerManager._byGroup[bindTo];
    var bindto_layer_key = Object.keys(bindto_layer);

    var bind_layer = L.geoJSON(x, {
      pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, options);
      },
      style: style
    });

    if (pop !== null) {
      bind_layer.bindPopup(pop);
    }

    var okeys = Object.keys(bind_layer._layers);
    var nkeys = [...okeys];
    nkeys.forEach( (key, i, self) => self[i] = bind_layer._layers[key].feature.properties[by] );

    bindto_layer[bindto_layer_key]
    .on(on, function(e) {
      console.log(e.layer.feature.properties[by]);
      var cur_by = e.layer.feature.properties[by];
      var ids = getAllIndexes(nkeys, cur_by);

      e.target.eachLayer(function (layer) {
        if(layer.feature.properties[[by]] == cur_by) {
          layer.setStyle(updateStyle);
        }
      });

      ids.forEach(function(i) {
        if (!map.hasLayer(bind_layer._layers[okeys[i]])) {
          if (bind_layer._popup === undefined) {
            map.addLayer(bind_layer._layers[okeys[i]]);
          } else {
          map.addLayer(bind_layer._layers[okeys[i]].bindPopup(bind_layer._popup._content[[i]]));
          }
        }
      });
    })
    .on(out, function (e) {
      console.log(e.layer.feature.properties[by]);
      var cur_by = e.layer.feature.properties[by];
      var ids = getAllIndexes(nkeys, cur_by);

      e.target.eachLayer(function (layer) {
        if(layer.feature.properties[[by]] == cur_by) {
          layer.setStyle(layer.defaultOptions.style(layer.feature));
        }
      });

      ids.forEach(function(i) {
        if (map.hasLayer(bind_layer._layers[okeys[i]])) {
          map.removeLayer(bind_layer._layers[okeys[i]]);
        }
      });
    });
};


function getAllIndexes(arr, val) {
    var indexes = [], i;
    for(i = 0; i < arr.length; i++)
        if (arr[i] === val)
            indexes.push(i);
    return indexes;
}
