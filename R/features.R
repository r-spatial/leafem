### addFeatures ##############################################################
##############################################################################
#' Type agnositc version of \code{leaflet::add*} functions.
#'
#' @description
#' Add simple features geometries from \code{\link[sf]{sf}}
#'
#' @param map A \code{leaflet} or \code{mapview} map.
#' @param data A \code{sf} object to be added to the \code{map}.
#' @param pane The name of the map pane for the features to be rendered in.
#' @param ... Further arguments passed to the respective \code{leaflet::add*}
#' functions. See \code{\link{addCircleMarkers}}, \code{\link{addPolylines}}
#' and \code{\link{addPolygons}}.
#'
#' @return
#' A leaflet \code{map} object.
#'
#' @examples
#' library(leaflet)
#'
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addCircleMarkers(data = breweries91)
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addFeatures(data = breweries91)
#'
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addPolylines(data = atlStorms2005)
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addFeatures(atlStorms2005)
#'
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addPolygons(data = gadmCHE)
#' leaflet() %>% addProviderTiles("OpenStreetMap") %>% addFeatures(gadmCHE)
#'
#' @export addFeatures
#' @name addFeatures
#' @rdname addFeatures
addFeatures <- function(map,
                        data,
                        pane = "overlayPane",
                        ...) {

  if (inherits(data, "Spatial")) data = sf::st_as_sf(data)

  switch(getSFClass(sf::st_geometry(data)),
         sfc_POINT           = addPointFeatures(map, data, pane, ...),
         sfc_MULTIPOINT      = addPointFeatures(map, data, pane, ...),
         sfc_LINESTRING      = addLineFeatures(map, data, pane, ...),
         sfc_MULTILINESTRING = addLineFeatures(map, data, pane, ...),
         sfc_POLYGON         = addPolygonFeatures(map, data, pane, ...),
         sfc_MULTIPOLYGON    = addPolygonFeatures(map, data, pane, ...),
         sfc_GEOMETRY        = addGeometry(map, data, pane, ...),
         POINT               = addPointFeatures(map, data, pane, ...),
         MULTIPOINT          = addPointFeatures(map, data, pane, ...),
         LINESTRING          = addLineFeatures(map, data, pane, ...),
         MULTILINESTRING     = addLineFeatures(map, data, pane, ...),
         POLYGON             = addPolygonFeatures(map, data, pane, ...),
         MULTIPOLYGON        = addPolygonFeatures(map, data, pane, ...),
         GEOMETRY            = addGeometry(map, data, pane, ...))

}




### these functions call the appropriate leaflet::add* functions
### depending on geometry type. Additional parameters can be passed via ...

mw = 800

### Point Features
addPointFeatures <- function(map,
                             data,
                             pane,
                             ...) {
  garnishMap(map, leaflet::addCircleMarkers,
             data = sf::st_zm(sf::st_cast(data, "POINT")),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### Line Features
addLineFeatures <- function(map,
                            data,
                            pane,
                            ...) {
  garnishMap(map, leaflet::addPolylines,
             data = sf::st_zm(data),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### PolygonFeatures
addPolygonFeatures <- function(map,
                               data,
                               pane,
                               ...) {
  garnishMap(map, leaflet::addPolygons,
             data = sf::st_zm(data),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### GeometryCollections
addGeometry = function(map,
                       data,
                       pane,
                       ...) {
  ls = append(list(pane), list(...))
  if (!is.null(ls$label))
    label = split(ls$label, f = as.character(sf::st_dimension(data)))
  if (!is.null(ls$popup))
    popup = split(ls$popup, f = as.character(sf::st_dimension(data)))
  lst = split(data, f = as.character(sf::st_dimension(data)))
  for (i in 1:length(lst)) {
    ls$map = map
    ls$data = sf::st_cast(lst[[i]])
    if (!is.null(ls$label)) ls$label = label[[i]]
    if (!is.null(ls$popup)) ls$popup = popup[[i]]
    map = do.call(addFeatures, ls)
    # addFeatures(map,
    #                 data = sf::st_cast(lst[[i]]),
    #                 group = ls$group,
    #                 radius = ls$radius,
    #                 weight = ls$weight,
    #                 opacity = ls$opacity,
    #                 fillOpacity = ls$fillOpacity,
    #                 color = ls$color,
    #                 fillColor = ls$fillColor,
    #                 popup = ls$popup[[i]],
    #                 label = ls$label[[i]])
  }
  return(map)
}

##############################################################################
