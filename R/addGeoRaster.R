addGeoRaster = function(map,
                        x,
                        group = NULL,
                        layerId = NULL,
                        resolution = 96,
                        opacity = 0.8,
                        options = leaflet::tileOptions(),
                        colorOptions = colorOptions(),
                        pixelValuesToColorFn = NULL) {

  if (inherits(x, "Raster")) {
    x = stars::st_as_stars(x)
  }

  if (!sf::st_is_longlat(x)) {
    x = stars::st_warp(x, crs = 4326)
  }

  fl = tempfile(fileext = ".tif")

  if (inherits(x, "stars_proxy")) {
    file.copy(x[[1]], fl)
  }

  if (!inherits(x, "stars_proxy")) {
    stars::write_stars(x, dsn = fl)
  }

  addGeotiff(
    map
    , file = fl
    , url = NULL
    , group = group
    , layerId = layerId
    , resolution = resolution
    , opacity = opacity
    , options
    , colorOptions = colorOptions
    , pixelValuesToColorFn = pixelValuesToColorFn
  )

}



addGeotiff = function(map,
                      file = NULL,
                      url = NULL,
                      group = NULL,
                      layerId = NULL,
                      resolution = 96,
                      opacity = 0.8,
                      options = leaflet::tileOptions(),
                      colorOptions = colorOptions(),
                      pixelValuesToColorFn = NULL) {

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
      , chromaJsDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeotiff"
      , url
      , group
      , layerId
      , resolution
      , opacity
      , options
      , colorOptions
      , pixelValuesToColorFn
    )
  } else {
    map$dependencies <- c(
      map$dependencies
      , leafletGeoRasterDependencies()
      , chromaJsDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeotiff"
      , url
      , group
      , layerId
      , resolution
      , opacity
      , options
      , colorOptions
      , pixelValuesToColorFn
    )
  }

}

colorOptions = function(palette = NULL,
                        breaks = NULL,
                        na.color = "#bebebe22") {
  if (is.function(palette)) {
    palette = palette(256)
  }
  list(
    palette = palette
    , breaks = breaks
    , naColor = na.color
  )
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