LeafletWidget.methods.addLayerViewControl = function(viewSettings, homeSettings, setviewonselect) {
  const map = this;

  // Handle view settings for each layer on 'overlayadd' or 'baselayerchange'
  map.on('overlayadd baselayerchange', function(e) {
    let layerName = e.name;
    let setting = viewSettings[layerName];
    if (setting && setviewonselect) {
      handleView(map, setting);
    }
  });

  // Handle home buttons after the map has rendered
  if (homeSettings) {
    setTimeout(function() {
      for (let layer in homeSettings) {
        let homeButtonOptions = homeSettings[layer];
        let homeButton = document.createElement('span');
        homeButton.innerHTML = homeButtonOptions.text || '🏠';
        homeButton.style.cursor = homeButtonOptions.cursor || 'pointer';
        homeButton.style.cssText += homeButtonOptions.styles || 'float: inline-end;';
        homeButton.className = homeButtonOptions.class || 'leaflet-home-btn';
        homeButton.dataset.layer = layer;
        // Find the corresponding label for the layer
        let labels = document.querySelectorAll('.leaflet-control-layers label');
        labels.forEach(function(label) {
          if (label.textContent.trim() === layer) {
            label.querySelector('div').appendChild(homeButton);
          }
        });
        homeButton.addEventListener('click', function(event) {
          event.preventDefault();
          event.stopPropagation();
          let layerName = this.dataset.layer;
          let setting = viewSettings[layerName];
          if (setting) {
            handleView(map, setting)
          }
        });
      }
    }, 100);
  }

};

// Helper function to handle setting view or bounds
function handleView(map, setting) {
  if (setting.coords) {
    const method = setting.fly ? 'flyTo' : 'setView';
    map[method]([setting.coords[1], setting.coords[0]], setting.zoom, setting.options);
  } else if (setting.bounds) {
    const method = setting.fly ? 'flyToBounds' : 'fitBounds';
    const bounds = [[setting.bounds[1], setting.bounds[0]], [setting.bounds[3], setting.bounds[2]]];
    map[method](bounds, setting.options);
  }
}