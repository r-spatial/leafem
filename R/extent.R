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
#' library(leaflet)
#'
#' # Usage in leaflet
#' leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addExtent(gadmCHE)
#'
#' leaflet(gadmCHE) %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addExtent()

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

  # data <- checkAdjustProjection(data)

  if (inherits(data, "Spatial")) data = sf::st_as_sfc(data)

  # if (!sf::st_crs(data)$epsg == 4326) {
  #     data = sf::st_transform(data, sp::CRS(llcrs))
  # }

  x <- sf::st_as_sfc(sf::st_bbox(data))
  m <- addFeatures(x, map = map, ...)
  return(m)
}