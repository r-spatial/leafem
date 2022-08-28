#' Add vector tiles stored as PMTiles in an AWS S3 bucket to a leaflet map.
#'
#' @details
#'   These functions can be used to add cloud optimized vector tiles data in
#'   the `.pmtiles` format stored in an Amazon Web Services (AWS) S3 bucket to a
#'   leaflet map. For instructions on how to create these files, see
#'   \url{https://github.com/protomaps/PMTiles}.
#'
#'   NOTE: You may not see the tiles rendered in the RStudio viewer pane. Make
#'   sure to open the map in a browser.
#'
#' @param map the map to add to.
#' @param url the url to the tiles to be served.
#' @param style styling for the layer. See \link{paintRules} for details.
#' @param layerId the layer id.
#' @param group group name.
#' @param pane the map pane to which the layer should be added. See
#'   [leaflet](addMapPane) for details.
#' @param attribution optional attribution character string.
#'
#' @examples
#' ## PMPolygons
#' library(leaflet)
#' library(leafem)
#'
#' url_nzb = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.pmtiles"
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addPMPolygons(
#'     url = url_nzb
#'     , layerId = "nzbuildings"
#'     , group = "nzbuildings"
#'     , style = paintRules(
#'       layer = "nz-building-outlines"
#'       , fillColor = "pink"
#'       , stroke = "green"
#'     )
#'   ) %>%
#'   setView(173.50, -40.80, 6)
#'
#' @name addPMPolygons
#' @export addPMPolygons
addPMPolygons = function(
    map
    , url
    , style
    , layerId = NULL
    , group = NULL
    , pane = "overlayPane"
    , attribution = NULL
) {

  if (length(style) == 0) {
    stop(
      "need at least one paint rule set to know which layer to visualise"
      , call. = FALSE
    )
  }

  map$dependencies <- c(
    map$dependencies
    , leafletPMTilesDependencies()
    , fgbDependencies()
    , chromaJsDependencies()
  )

  leaflet::invokeMethod(
    map
    , data = leaflet::getMapData(map)
    , method = "addPMPolygons"
    # , paste0(path_layer, "/", basename(file))
    , url
    , layerId
    , group
    , style
    , pane
    , attribution
  )
}

#' Add point data stored as PMTiles
#'
#' @examples
#' ## PMPoints
#' library(leaflet)
#' library(leafem)
#'
#' url_depoints = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/depoints.pmtiles"
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addPMPoints(
#'     url = url_depoints
#'     , layerId = "depoints"
#'     , group = "depoints"
#'     , style = paintRules(
#'       layer = "depoints"
#'       , fillColor = "black"
#'       , stroke = "white"
#'       , radius = 4
#'     )
#'   ) %>%
#'   setView(10, 51, 6)
#'
#' @describeIn addPMPolygons add points stored as PMTiles
#' @export
addPMPoints = function(
    map
    , url
    , style
    , layerId = NULL
    , group = NULL
    , pane = "overlayPane"
    , attribution = NULL
) {

  if (length(style) == 0) {
    stop(
      "need at least one paint rule set to know which layer to visualise"
      , call. = FALSE
    )
  }

  map$dependencies <- c(
    map$dependencies
    , leafletPMTilesDependencies()
    , fgbDependencies()
    , chromaJsDependencies()
  )

  leaflet::invokeMethod(
    map
    , data = leaflet::getMapData(map)
    , method = "addPMPoints"
    # , paste0(path_layer, "/", basename(file))
    , url
    , layerId
    , group
    , style
    , pane
    , attribution
  )
}

#' Add polylines stored as PMTiles
#'
#' @examples
#' ## PMPolylines
#' library(leaflet)
#' library(leafem)
#'
#' url_rivers = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/rivers_africa.pmtiles"
#'
#' ## NOTE: these will only render until a zoom level of 7!!
#' leaflet() %>%
#'   addTiles() %>%
#'   addPMPolylines(
#'     url = url_rivers
#'     , layerId = "rivers"
#'     , group = "rivers"
#'     , style = paintRules(
#'       layer = "rivers_africa"
#'       , color = "blue"
#'     )
#'   ) %>%
#'   setView(24, 2.5, 4)
#'
#' @describeIn addPMPolygons add ploylines stored as PMTiles
#' @export
addPMPolylines = function(
    map
    , url
    , style
    , layerId = NULL
    , group = NULL
    , pane = "overlayPane"
    , attribution = NULL
) {

  if (length(style) == 0) {
    stop(
      "need at least one paint rule set to know which layer to visualise"
      , call. = FALSE
    )
  }

  map$dependencies <- c(
    map$dependencies
    , leafletPMTilesDependencies()
    , fgbDependencies()
    , chromaJsDependencies()
  )

  leaflet::invokeMethod(
    map
    , data = leaflet::getMapData(map)
    , method = "addPMPolylines"
    # , paste0(path_layer, "/", basename(file))
    , url
    , layerId
    , group
    , style
    , pane
    , attribution
  )
}

#' Styling options for PMTiles
#'
#' @param layer the name of the layer in the PMTiles file to visualise.
#' @param fillColor fill color for polygons
#' @param color line color
#' @param do_stroke logical, whether polygon borders should be drawn
#' @param width line width
#' @param radius point radius
#' @param stroke color point border
#' @param opacity point opacity
#' @param dash either `NULL` (default) for a solid line or a numeric vector
#'   of length 2 denoting segment length and spce between segments (in pixels),
#'   e.g. `c(5, 3)`
#'
#' @export
paintRules = function(
    layer
    , fillColor = "#0033ff66"
    , color = "#0033ffcc"
    , do_stroke = TRUE
    , width = 0.5
    , radius = 3
    , stroke = "#000000"
    , opacity = 1
    , dash = NULL
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
    , radius = radius
    , stroke = stroke
    , opacity = opacity
    , dash = dash
  )

}


leafletPMTilesDependencies = function() {
  list(
    htmltools::htmlDependency(
      "PMTiles",
      '0.0.1',
      system.file("htmlwidgets/lib/protomaps", package = "leafem"),
      script = list(
        src = c(
          "protomap-binding.js"
        )
        , crossorigin = "anonymous"
      )
    )
    , htmltools::htmlDependency(
      "protomaps",
      '0.0.1',
      system.file("htmlwidgets/lib/protomaps", package = "leafem"),
      script = list(
        src = c(
          "protomaps.min.js"
        )
        , crossorigin = "anonymous"
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