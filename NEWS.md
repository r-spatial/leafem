## leafem 0.0.3

new features:

  * addHomeButton now infers bounding box without having to pass extent object. Also it now handles vectors of c(xmin, ymin, xmax, ymax) - e.g. via sf::st_bbox().
  * addLocalFile has gained argument `tms` to specify whether tiles are TMS tiles.
  * new function `updateLayersControl` to update (or add) layers control when adding new base or overlay layers to an existing map.

## leafem 0.0.1

initial commit
