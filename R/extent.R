#' Add extent/bbox of spatial objects to a leaflet map
#'
#' @description
#' This function adds the bounding box of a spatial object to a leaflet or mapview map.
#' @param map A \code{leaflet} or \code{mapview} map.
#' @param data A \code{sf} object to be added to the \code{map}.
#' @param ... additional arguments passed on to \code{\link{addFeatures}}
#' @export addExtent
#' @name addExtent
#'
#' @examples
#' library(sf)
#' library(leaflet)
#' indata <- sf::st_read(system.file("shape/nc.shp", package="sf"))
#'
#' # Usage in leaflet
#' leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addExtent(indata)
#'
#' leaflet(indata) %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addExtent()
#'
#' # Usage in mapview
#'
#' library(mapview)
#' mapview(indata) %>% addExtent(indata)
#' mapview(indata) + viewExtent(indata)

addExtent <- function(map,
                      data, ...) {

  stopifnot(inherits(map, c("leaflet", "leaflet_proxy", "mapview")))

  if (missing(data)) {
    if (inherits(map, "mapview")) {
       data = map@object[[1]]
    } else {
       data = attributes(map[["x"]])[["leafletData"]]
    }
  }

  data <- checkAdjustProjection(data)

  if (inherits(data, "Spatial")) data = sf::st_as_sfc(data)

  # if (!sf::st_crs(data)$epsg == 4326) {
  #     data = sf::st_transform(data, sp::CRS(llcrs))
  # }

  x <- sf::st_as_sfc(sf::st_bbox(data))
  m <- addFeatures(x, map = map, ...)
  return(m)
}