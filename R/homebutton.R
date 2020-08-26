### addHomeButton ############################################################
##############################################################################
#' Add a home button / zoom-to-layer button to a map.
#'
#' @description
#' This function adds a button to the map that enables zooming to a
#' provided extent / bbox.
#'
#' @param map a mapview or leaflet object.
#' @param ext the extent / bbox to zoom to.
#' @param group the name of the group/layer to be zoomed to (or any character
#' string)
#' @param position the position of the button (one of 'topleft', 'topright',
#' 'bottomleft', 'bottomright'). Defaults to 'bottomright'.
#' @param add logical. Whether to add the button to the map (mainly for internal use).
#'
#' @examples
#' library(leaflet)
#' library(raster)
#'
#' ## pass a group name only
#' m <- leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addCircleMarkers(data = breweries91, group = "breweries91") %>%
#'   addHomeButton(group = "breweries91")
#' m
#'
#' ## pass a raster extent - group can now be an arbitrary label
#' m <- leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addCircleMarkers(data = breweries91, group = "breweries91") %>%
#'   addHomeButton(ext = extent(breweries91), group = "Brew")
#' m
#'
#' ## remove the button
#' removeHomeButton(m)
#'
#' @importFrom raster extent
#'
#' @export addHomeButton
#' @name addHomeButton
#' @rdname addHomeButton
#' @aliases addHomeButton
addHomeButton <- function(map, ext, group = "layer",
                          position = 'bottomright', add = TRUE) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))

  # drop names in case extent of sf object
  if (!missing(ext)) {
    if (inherits(ext, "Extent")) {
      ext = as.vector(ext)[c(1, 3, 2, 4)]
    } else {
      ext = as.vector(ext)
    }
  } else {
    ext = c(0, 0, 0, 0)
  }

  hb <- try(getCallEntryFromMap(map, "addHomeButton"), silent = TRUE)
  if (!inherits(hb, "try-error") & length(hb) == 1) {
    ext_coords <- unlist(map$x$calls[[hb]][["args"]][1:4])
    ext_map <- c(ext_coords[1], ext_coords[2], ext_coords[3], ext_coords[4])
    if (identical(ext, ext_map)) add = FALSE
  }

  if (add) {
    if (inherits(extent, "matrix")) ext = raster::extent(ext)
    label <- paste("Zoom to", group)

    txt <- paste('<strong>', group, '</strong>')

    map$dependencies <- c(map$dependencies, leafletHomeButtonDependencies())
    leaflet::invokeMethod(map, leaflet::getMapData(map), 'addHomeButton',
                          ext[1], ext[2], ext[3], ext[4],
                          group, label, txt, position)
  }

  else map

}


#' Use removeHomeButton to remove home button
#'
#' @describeIn addHomeButton remove a homeButton from a map
#' @aliases removeHomeButton
#' @export removeHomeButton
removeHomeButton <- function(map) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))
  leaflet::invokeMethod(map, NULL, 'removeHomeButton')
}


addZoomFullButton = function(map, lst, position = "bottomleft") {
  bb = combineExtent(lst, sf = FALSE, crs = getProjection(lst[[1]]))
  names(bb) = NULL
  label = "Zoom to full extent"
  txt = "<strong>Zoom full</strong>"

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addHomeButton',
                        bb[1], bb[2], bb[3], bb[4], NULL, label, txt,
                        position)

}


leafletHomeButtonDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "HomeButton",
      '0.0.1',
      system.file("htmlwidgets/lib/HomeButton", package = "leafem"),
      script = c("home-button.js", 'easy-button-src.min.js'),
      stylesheet = 'home-button.css'
    ))
}

##############################################################################
