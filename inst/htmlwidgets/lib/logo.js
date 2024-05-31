/* global LeafletWidget, $, L */

LeafletWidget.methods.addLogo = function(img, options) {
  (function() {
    var map = this;

    console.log("ich bin hier drin")

    // Initialize logos array if not already present
    if (!map.logos) {
      map.logos = [];
    }

    // Create a new div for the logo
    var logoDiv = L.DomUtil.create('div', 'logo');
    logoDiv.style.position = 'absolute';
    logoDiv.style.width = options.width + 'px';
    logoDiv.style.height = options.height + 'px';
    logoDiv.style.opacity = options.alpha;
    logoDiv.style.background = 'transparent';

    switch (options.position) {
      case 'topleft':
        logoDiv.style.top = options.offsetY + 'px';
        logoDiv.style.left = options.offsetX + 'px';
        break;
        case 'topright':
          logoDiv.style.top = options.offsetY + 'px';
          logoDiv.style.right = options.offsetX + 'px';
          break;
          case 'bottomleft':
            logoDiv.style.bottom = options.offsetY + 'px';
            logoDiv.style.left = options.offsetX + 'px';
            break;
            case 'bottomright':
              logoDiv.style.bottom = options.offsetY + 'px';
              logoDiv.style.right = options.offsetX + 'px';
              break;
    }

    var imgElement = document.createElement('img');
    imgElement.src = img;
    imgElement.width = options.width;
    imgElement.height = options.height;
    if (options.url) {
      var linkElement = document.createElement('a');
      linkElement.href = options.url;
      linkElement.target = "_blank";
      linkElement.appendChild(imgElement);
      logoDiv.appendChild(linkElement);
    } else {
      logoDiv.appendChild(imgElement);
    }

    // Remove any existing logo at the same position
    if (map.logos[options.position]) {
      map.logos[options.position].remove();
    }

    map.getContainer().appendChild(logoDiv);
    map.logos[options.position] = logoDiv;
  }).call(this);
};