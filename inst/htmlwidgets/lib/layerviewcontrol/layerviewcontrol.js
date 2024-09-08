LeafletWidget.methods.addLayerViewControl = function(viewSettings, homeSettings, fixLegends) {
  const map = this;

  // Handle view settings for each layer on 'overlayadd' or 'baselayerchange'
  map.on('overlayadd baselayerchange', function(e) {
    let layerName = e.name;
    let setting = viewSettings[layerName];

    if (setting) {
      if (setting.coords) {
        if (setting.fly) {
          map.flyTo([setting.coords[1], setting.coords[0]], setting.zoom, setting.options);
        } else {
          map.setView([setting.coords[1], setting.coords[0]], setting.zoom, setting.options);
        }
      } else if (setting.bounds) {
        let bounds = [[setting.bounds[1], setting.bounds[0]], [setting.bounds[3], setting.bounds[2]]];
        if (setting.fly) {
          map.flyToBounds(bounds, setting.options);
        } else {
          map.fitBounds(bounds, setting.options);
        }
      }
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
        homeButton.className = homeButtonOptions.class || 'leaflet-home-btn';
        homeButton.dataset.layer = layer;
        console.log("homeButtonOptions.styles"); console.log(homeButtonOptions.styles)
        homeButton.style.cssText += homeButtonOptions.styles || 'float: inline-end;';

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
          if (setting && setting.coords) {
            if (setting.fly) {
              map.flyTo([setting.coords[1], setting.coords[0]], setting.zoom, setting.options);
            } else {
              map.setView([setting.coords[1], setting.coords[0]], setting.zoom, setting.options);
            }
          } else if (setting && setting.bounds) {
            let bounds = [[setting.bounds[1], setting.bounds[0]], [setting.bounds[3], setting.bounds[2]]];
            if (setting.fly) {
              map.flyToBounds(bounds, setting.options);
            } else {
              map.fitBounds(bounds, setting.options);
            }
          }
        });
      }
    }, 100);
  }

};