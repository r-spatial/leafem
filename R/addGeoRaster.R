addGeoRaster = function(map,
                        file = NULL,
                        url = NULL,
                        group = NULL,
                        layerId = NULL) {

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  if (is.null(file) & is.null(url))
    stop("need either file or url!\n", call. = FALSE)

  if (is.null(group))
    group = basename(tools::file_path_sans_ext(file))

  if (is.null(layerId)) layerId = group
  layerId = gsub("\\.", "_", layerId)

  if (!is.null(file)) {
    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", layerId, "_layer.tif")

    file.copy(file, path_layer, overwrite = TRUE)

    map$dependencies <- c(
      map$dependencies
      , fileAttachment(path_layer, layerId)
      , leafletGeoRasterDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeoRaster"
      , url
      , group
      , layerId
    )
  } else {
    map$dependencies <- c(
      map$dependencies
      , leafletGeoRasterDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeoRaster"
      , url
      , group
      , layerId
    )
  }

}

leafletGeoRasterDependencies = function() {
  list(
    htmltools::htmlDependency(
      "GeoRaster",
      '0.0.1',
      system.file("htmlwidgets/lib/georaster-for-leaflet", package = "leafem"),
      script = c(
        "georaster.min.js"
        , "georaster-layer-for-leaflet.browserify.min.js"
        , "georaster-binding.js"
      )
    )
  )
}