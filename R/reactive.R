#' Add a reactive layer to map.
#'
#' @description
#'   This function adds a layer to a map that is dependent on another layer.
#'   The reactive layer will be shown/hidden when holding the Ctrl-button on your
#'   keyboard and performing the action defined by \code{on}. \code{on} can be
#'   either "click" (default) or "mouseover".
#'
#'   Note: \code{srcLayer} needs to be added to the map using \code{\link[leaflet]{addGeoJSON}}
#'   because we need to be able to link the two layers by a common attribute
#'   defined by argument \code{by}. Linking will be done via \code{group} name
#'   of \code{srcLayer}.
#'
#' @param map a mapview or leaflet object.
#' @param x the (sf) features to be added to the map.
#' @param srcLayer the group name of the source layer that \code{x} should be bound to.
#' @param by shared attribute between \code{x} and \code{srcLayer} by which the
#'   two layers should be bound together.
#' @param on the action to invoke the action. Can be one of "click" (default) and
#'   "mouseover". The action will be triggered by holding Ctrl-key and performing \code{on}.
#' @param group the group name for the object to be added to \code{map}.
#' @param layerId the layerId.
#' @param options options to be passed to the layer.
#'   See e.g. \code{\link[leaflet]{pathOptions}} for details.
#' @param style named list of styling instructions for the geometries in \code{x}.
#' @param updateStyle named list of how to update the styling of the \code{srcLayer}.
#' @param popup a character vector of the HTML content for the popups of layer \code{x}.
#'   See \code{\link[leaflet]{addControl}} for details.
#' @param ... currently not used.
#'
#' @examples
#' library(leaflet)
#' library(leafem)
#' library(sf)
#' library(geojsonsf)
#'
#' # create some random data
#' che = st_as_sf(gadmCHE)
#' pts = st_as_sf(st_sample(che, 200))
#' pts = st_join(pts, che[, "ID_1"])
#'
#' che = sf_geojson(che)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   addGeoJSON(che, group = "che") %>%
#'   addReactiveFeatures(
#'     pts
#'     , srcLayer = "che"
#'     , by = "ID_1"
#'     , on = "click"
#'     , group = "pts"
#'     , style = list(color = "black", fillOpacity = 0.3)
#'     , updateStyle = list(
#'       opacity = 0.3
#'       , fillOpacity = 0.3
#'       , color = "forestgreen"
#'       , fillColor = "forestgreen"
#'     )
#'   ) %>%
#'   addMouseCoordinates() %>%
#'   setView(lng = 8.31, lat = 46.75, zoom = 8)
#'
#' @export addReactiveFeatures
#' @name addReactiveFeatures
#' @rdname addReactiveFeatures
#' @aliases addReactiveFeatures
addReactiveFeatures = function(map,
                               x,
                               srcLayer,
                               by,
                               on,
                               group,
                               layerId = NULL,
                               options = NULL,
                               style = NULL,
                               updateStyle = NULL,
                               popup = NULL,
                               ...) {

  if (!inherits(x, "geojson")) {
    x = geojsonsf::sf_geojson(x)
  }

  map$dependencies = c(
    map$dependencies
    , reactiveDependencies()
  )

  leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , "addReactiveLayer"
    , x
    , srcLayer
    , by
    , on
    , group
    , layerId
    , options
    , style
    , updateStyle
    , popup
  )

}


reactiveDependencies = function() {
  list(
    htmltools::htmlDependency(
      "reactive"
      , '0.0.1'
      , system.file("htmlwidgets/lib/reactive", package = "leafem")
      , script = c(
        'reactive.js'
      )
    )
  )
}