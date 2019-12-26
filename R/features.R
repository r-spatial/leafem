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

  stopifnot(inherits(map, c("leaflet", "leaflet_proxy", "mapview", "mapdeck")))

  if (inherits(map, "mapview")) {
    if (missing(data)) {
      data = map@object[[1]]
    } else {
      if (!is.null(map@object[[1]])) {
        data = sf::st_transform(data, sf::st_crs(map@object[[1]]))
      }
    }
  }

  # this allows using `addFeatures` directly on a leaflet pipe, without
  # specifying `data` (e.g., leaflet(indata) %>% addFeatures())
  if (inherits(map, c("leaflet", "leaflet_proxy"))) {
    if (missing(data)) {
      data <- attributes(map[["x"]])[["leafletData"]]
    }
    # if (is.null(list(...)$native.crs) || !list(...)$native.crs) {
    #   data <- checkAdjustProjection(data)
    # }
  }

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
addPointFeatures = function(map, ...) UseMethod("addPointFeatures")


### Point Features leaflet
addPointFeatures.leaflet <- function(map,
                                     data,
                                     pane,
                                     ...) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  garnishMap(map, leaflet::addCircleMarkers,
             data = sf::st_zm(sf::st_cast(data, "POINT")),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### Point Features leaflet_proxy
addPointFeatures.leaflet_proxy <- addPointFeatures.leaflet

### Point Features mapview
addPointFeatures.mapview = addPointFeatures.leaflet

### Point Features mapdeck
addPointFeatures.mapdeck <- function(map,
                                     data,
                                     ...) {
  garnishMap(
    map
    , mapdeck::add_pointcloud
    , data = data #sf::st_zm(sf::st_cast(data, "POINT"))
    , ...
  )
}


### Line Features
addLineFeatures = function(map, ...) UseMethod("addLineFeatures")

### Line Features leaflet
addLineFeatures.leaflet <- function(map,
                                    data,
                                    pane,
                                    ...) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  garnishMap(map, leaflet::addPolylines,
             data = sf::st_zm(data),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### Line Features leaflet_proxy
addLineFeatures.leaflet_proxy <- addLineFeatures.leaflet

### Line Features mapview
addLineFeatures.mapview = addLineFeatures.leaflet

### Line Features mapdeck
addLineFeatures.mapdeck <- function(map,
                                    data,
                                    ...) {
  garnishMap(
    map
    , mapdeck::add_path
    , data = sf::st_zm(data)
    , ...
  )
}

### Polygon Features
addPolygonFeatures = function(map, ...) UseMethod("addPolygonFeatures")

### Polygon Features leaflet
addPolygonFeatures.leaflet <- function(map,
                                       data,
                                       pane,
                                       ...) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  garnishMap(map, leaflet::addPolygons,
             data = sf::st_zm(data),
             popupOptions = leaflet::popupOptions(maxWidth = mw,
                                                  closeOnClick = TRUE),
             options = leaflet::leafletOptions(pane = pane),
             ...)
}

### Polygon Features leaflet_proxy
addPolygonFeatures.leaflet_proxy <- addPolygonFeatures.leaflet

### Polygon Features mapview
addPolygonFeatures.mapview = addPolygonFeatures.leaflet

### Polygon Features mapdeck
addPolygonFeatures.mapdeck <- function(map,
                                       data,
                                       ...) {
  garnishMap(
    map
    , mapdeck::add_polygon
    , data = sf::st_zm(data)
    , ...
  )
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
