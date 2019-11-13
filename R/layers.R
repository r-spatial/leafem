#' Update the layer controls when adding layers to an existing map.
#'
#' @description
#' When adding additional base layers or overlay layers to an existing map,
#' \code{updateLayersControl} will either update the existing layers control or
#' add a new one if map has none.
#'
#' @param map A \code{leaflet} or \code{mapview} map.
#' @param addBaseGroups group names of base layers to be added to layers control.
#' @param addOverlayGroups group names of overlay layers to be added to layers control.
#' @param position position of control: "topleft", "topright", "bottomleft", or "bottomright".
#' @param ... Further arguments passed to \code{\link[leaflet]{addLayersControl}}.
#'
#' @return
#' A leaflet \code{map} object.
#'
#' @examples
#' library(leaflet)
#'
#' map = leaflet() %>%
#'         addProviderTiles("OpenStreetMap", group = "OSM") %>%
#'         addProviderTiles("CartoDB.DarkMatter", group = "dark") %>%
#'         addCircleMarkers(data = breweries91, group = "brew")
#'
#' map # no layers control
#'
#' map %>%
#'   updateLayersControl(addBaseGroups = c("OSM", "dark"),
#'                       addOverlayGroups = "brew")
#'
#' @export updateLayersControl
#' @name updateLayersControl
#' @rdname updateLayersControl
updateLayersControl = function(map,
                               addBaseGroups = character(0),
                               addOverlayGroups = character(0),
                               position = "topleft",
                               ...) {

  if (inherits(map, "mapview")) map = map@map

  # does the map have a layers control?
  ind = getCallEntryFromMap(map, call = "addLayersControl")

  # if not, check for supplied layers. If all empty, stop, else usem
  if (!length(ind)) {
    if (missing(addBaseGroups) & missing(addOverlayGroups)) {
      stop("map has no layers and no additional layers were provided",
           call. = FALSE)
    } else {
      bgm = addBaseGroups
      olg = addOverlayGroups
    }
  # if layers controls exists, add new ones to existing
  } else {
    bgm = c(map$x$calls[[ind[1]]]$args[[1]], addBaseGroups)
    olg = c(map$x$calls[[ind[1]]]$args[[2]], addOverlayGroups)
  }

  # delete previous layers control if it exists
  if (!!length(ind)) map = leaflet::removeLayersControl(map)

  # add updated layers control
  map = leaflet::addLayersControl(map = map,
                                  position = position,
                                  baseGroups = bgm,
                                  overlayGroups = olg,
                                  ...)

  return(map)

}


# Convenience functions for working with spatial objects and leaflet maps
getCallMethods = function(map) {
  sapply(map$x$calls, "[[", "method")
}

getCallEntryFromMap <- function(map, call) {
  grep(call, getCallMethods(map), fixed = TRUE, useBytes = TRUE)
}
