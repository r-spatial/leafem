addPMTiles = function(
    map
    , url
    , layerName
    , style = paintRules(layer = layerName)
    , layerId = NULL
    , group = NULL
) {

  # if (!is.null(file)) {
  #   if (!file.exists(file)) {
  #     stop(
  #       sprintf(
  #         "file %s does not seem to exist"
  #         , file
  #       )
  #       , call. = FALSE
  #     )
  #   }
  #   path_layer = tempfile()
  #   dir.create(path_layer)
  #   path_layer = paste0(path_layer, "/", layerId, "_layer.pmtiles")
  #   # path_layer = paste0(path_layer, "/", layerId)
  #   # dir.create(path_layer)
  #
  #   file.copy(file, path_layer, overwrite = TRUE)
  #   # file.copy(file, path_layer, overwrite = TRUE, recursive = TRUE)
  # }

  if (length(paintRules) == 0) {
    stop(
      "need at least one paint rule set to know which layer to visualise"
      , call. = FALSE
    )
  }

  map$dependencies <- c(
    map$dependencies
    , leafletPMTilesDependencies()
    # , fileAttachment(path_layer, layerId)
  )

  leaflet::invokeMethod(
    map
    , data = leaflet::getMapData(map)
    , method = "addPMTiles"
    # , paste0(path_layer, "/", basename(file))
    , url
    , layerId
    , group
    , style
  )
}

#' Styling options for PMTiles
#'
#' @param fillColor fill color for polygons
#' @param color line color
#' @param do_stroke logical, whether polygon borders should be drawn
#' @param width line width
#'
#' @export
paintRules = function(
  layer
  , fillColor = "#0033ff66"
  , color = "#0033ffcc"
  , do_stroke = TRUE
  , width = 0.5
) {

  if (missing(layer)) {
    stop(
      "need a layer specification to know what to draw"
      , call. = FALSE
    )
  }

  list(
    layer = layer
    , fillColor = fillColor
    , color = color
    , do_stroke = do_stroke
    , width = width
  )

}


leafletPMTilesDependencies = function() {
  list(
    htmltools::htmlDependency(
      "PMTiles",
      '0.0.1',
      system.file("htmlwidgets/lib/protomaps", package = "leafem"),
      script = c(
        "protomap-binding.js"
        , "protomaps.min.js"
      )
    )
  )
}



addMBTiles = function(map, file, layerId = NULL, group = NULL) {

  if (!is.null(file)) {
    if (!file.exists(file)) {
      stop(
        sprintf(
          "file %s does not seem to exist"
          , file
        )
        , call. = FALSE
      )
    }
    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", layerId, "_layer.mbtiles")
    # path_layer = paste0(path_layer, "/", layerId)
    # dir.create(path_layer)

    file.copy(file, path_layer, overwrite = TRUE)
    # file.copy(file, path_layer, overwrite = TRUE, recursive = TRUE)
  }


  map$dependencies <- c(
    map$dependencies
    , leafletMBTilesDependencies()
    , fileAttachment(path_layer, layerId)
  )

  leaflet::invokeMethod(
    map
    , data = leaflet::getMapData(map)
    , method = "addMBTiles"
    # , paste0(path_layer, "/", basename(file))
    , path_layer
    , layerId
    , group
  )
}


leafletMBTilesDependencies = function() {
  list(
    htmltools::htmlDependency(
      "MBTiles",
      '0.0.1',
      system.file("htmlwidgets/lib/protomaps", package = "leafem"),
      script = c(
        "mbtiles-binding.js"
        , "Leaflet.TileLayer.MBTiles.js"
        , "https://unpkg.com/sql.js@0.3.2/js/sql.js"
      )
    )
  )
}