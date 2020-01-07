LeafletWidget.methods.addFlatGeoBuf = function (group) {

  var map = this;
  var data_fl = document.getElementById(group + '-1-attachment' ).href;

  function handleResponse(response) {
    // use flatgeobuf JavaScript API to iterate stream into results (features as geojson)
    // NOTE: would be more efficient with a special purpose Leaflet deserializer
    let it = flatgeobuf.deserializeStream(response.body);
    // handle result
    function handleResult(result) {
        if (!result.done) {
            L.geoJSON(result.value).addTo(map);
            it.next().then(handleResult);
        }
    }
    it.next().then(handleResult);
}

// using fetch API to get readable stream
//fetch('https://raw.githubusercontent.com/bjornharrtell/flatgeobuf/2.0.1/test/data/UScounties.fgb')
//.then(handleResponse)

  fetch(data_fl)
  .then(handleResponse);
};
