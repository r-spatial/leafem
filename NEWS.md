## leafem 0.0.6

new features:

  * addHomeButton now infers bounding box without having to pass extent object. Also it now handles vectors of c(xmin, ymin, xmax, ymax) - e.g. via sf::st_bbox().
  * addLocalFile has gained argument `tms` to specify whether tiles are TMS tiles.
  * new function `updateLayersControl` to update (or add) layers control when adding new base or overlay layers to an existing map (https://twitter.com/mdsumner/status/1194596180061118465).
  * added support for 'mapdeck' maps in addFeatures.
  * added methods addStarsImage (moved from mapview) and addRasterRGB. Thanks to Luigi Ranghetti (https://github.com/r-spatial/leafem/pull/1).
  * addFeatures now also works with leaflet_proxy objects. Thanks Lorento Busetto (https://github.com/r-spatial/leafem/pull/2).
  
miscellaneous:

  * garnishMap now uses match.arg and try to be more robust.

## leafem 0.0.1

initial commit
