## leafem 0.1.3

new features:

  * addFgb has gained argument className to allow css specification.
  * new functions addGeotiff and addGeoRaster to render large raster data using https://github.com/GeoTIFF/georaster-layer-for-leaflet

bugfixes:
  
  * don't use st_zm for addFeatures.mapdeck
  * remove mousecoords strip only if it exists. #23
  * addFgb now respects pane passed via options.
  * addFgb used to fail LayerId contained . (dot).
  * addFgb uses layerId instead of group to attach to html.

## leafem 0.1.0

new features:

  * addHomeButton now infers bounding box from group argument without having to pass extent object. Also it now handles vectors of c(xmin, ymin, xmax, ymax) - e.g. via sf::st_bbox(). This is a backward-breaking change!
  * addLocalFile has gained argument `tms` to specify whether tiles are TMS tiles.
  * new function `updateLayersControl` to update (or add) layers control when adding new base or overlay layers to an existing map (https://twitter.com/mdsumner/status/1194596180061118465).
  * added support for 'mapdeck' maps in addFeatures.
  * added methods addStarsImage (moved from mapview) and addRasterRGB. Thanks to Luigi Ranghetti #1.
  * addFeatures now also works with leaflet_proxy objects. Thanks Lorento Busetto #2.
  * new function `addFgb` to add flatgeobuf files from file or url.
  * addImageQuery now much more robust. Also works with leaflet_proxy objects now. Thanks to Sebastian Gatscha #9, #12, #13
  
miscellaneous:

  * garnishMap now uses match.arg and tries to be more robust.

## leafem 0.0.1

initial commit
