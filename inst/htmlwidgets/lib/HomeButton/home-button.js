LeafletWidget.methods.addHomeButton = function (xmin, ymin, xmax, ymax, useext,
                                                group, label, icon, position,
                                                css, hover_css) {

  if (this.easyButton) {
		this.easyButton.removeFrom(this);
	}

  var bx = [];
  if (useext) {
    bx = [[ymin, xmin], [ymax, xmax]];
  } else {
    bx = this.layerManager._groupContainers[group].getBounds();
  }

  var easyButton = new L.easyButton({
    position: position,
    states: [{
            stateName: label,   // name the state
            icon:      icon,          // and define its properties
            title:     label, // like its title
            onClick: function(btn, map){
                map.fitBounds(bx, {maxZoom: 18});
                btn.state(label);
            }
    }]
  });

  let keys = Object.keys(css);
  let vals = Object.values(css);

  for (let i = 0; i < keys.length; i++) {
    easyButton.button.style.setProperty(keys[i].toString(), vals[i].toString());
  }

  // FIXME: need to figure out how to insert hover_css here!!!
  let hvr_css = '.leaflet-bar button:hover{ background-color: #00ff00 }';
  // let hvr_css = '.leaflet-bar button:hover' + JSON.stringify(hover_css);
  let style = document.createElement('style');
  style.appendChild(document.createTextNode(hvr_css));
  document.getElementsByTagName('head')[0].appendChild(style);

  easyButton.addTo(this);

  this.currentEasyButton = easyButton;

};


LeafletWidget.methods.removeHomeButton = function () {
  if (this.currentEasyButton) {
    this.currentEasyButton.removeFrom(this);
    this.currentEasyButton = null;
  }
};
