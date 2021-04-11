### addImageQuery ############################################################
##############################################################################
#' Add image query functionality to leaflet/mapview map.
#'
#' @details
#' This function enables Raster*/stars objects added to leaflet/mapview maps to
#' be queried. Standard query is on 'mousmove', but can be changed to 'click'.
#' Note that for this to work, the \code{layerId} needs to be the same as the
#' one that was set in \code{\link[leaflet]{addRasterImage}} or
#' \code{\link{addStarsImage}}. Currently only works for
#' numeric values (i.e. numeric/integer and factor values are supported).
#'
#' @param map the map with the RasterLayer to be queried.
#' @param x the RasterLayer that is to be queried.
#' @param band for stars layers, the band number to be queried.
#' @param group the group of the RasterLayer to be queried.
#' @param layerId the layerId of the RasterLayer to be queried. Needs to be the
#'   same as supplied in \code{\link[leaflet]{addRasterImage}} or
#'   \code{\link{addStarsImage}}.
#' @param project whether to project the RasterLayer to conform with leaflets
#'   expected crs. Defaults to \code{TRUE} and things are likely to go haywire
#'   if set to \code{FALSE}.
#' @param type whether query should occur on 'mousemove' or 'click'. Defaults
#'   to 'mousemove'.
#' @param digits the number of digits to be shown in the display field.
#' @param position where to place the display field. Default is 'topright'.
#' @param prefix a character string to be shown as prefix for the layerId.
#' @param className a character string to append to the control legend.
#' @param ... currently not used.
#'
#' @return
#' A leaflet map object.
#'
#' @examples
#' if (interactive()) {
#'   if (requireNamespace("plainview")) {
#'     library(leaflet)
#'     library(plainview)
#'
#'     leaflet() %>%
#'       addProviderTiles("OpenStreetMap") %>%
#'       addRasterImage(poppendorf[[1]], project = TRUE, group = "poppendorf",
#'                      layerId = "poppendorf") %>%
#'       addImageQuery(poppendorf[[1]], project = TRUE,
#'                     layerId = "poppendorf") %>%
#'       addLayersControl(overlayGroups = "poppendorf")
#'   }
#' }
#'
#' @importFrom raster projectExtent projectRaster as.matrix
#'
#' @export addImageQuery
#' @name addImageQuery
#' @rdname addImageQuery
addImageQuery = function(map,
                         x,
                         band = 1,
                         group = NULL,
                         layerId = NULL,
                         project = TRUE,
                         type = c("mousemove", "click"),
                         digits,
                         position = 'topright',
                         prefix = 'Layer',
                         className = "",
                         ...) {

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  type = match.arg(type)
  if (missing(digits)) digits = "null"
  if (is.null(group)) group = "stars"
  if (is.null(layerId)) layerId = group

  jsgroup <- gsub(".", "", make.names(group), fixed = TRUE)

  tmp <- makepathStars(as.character(jsgroup))
  pathDatFn <- tmp[[2]][1]
  # starspathDatFn <- tmp[[3]][1]
  # datFn <- tmp[[4]][1]

  if (project) {
    if (inherits(x, "stars")) {
      if (utils::packageVersion("stars") >= "0.4-1") {
        projected = stars::st_warp(x, crs = 4326)
      } else {
        projected <- sf::st_transform(x, crs = 4326)
      }
    }
    if (inherits(x, "Raster")) {
      projected = raster::projectRaster(
        x
        , raster::projectExtent(x, crs = sf::st_crs(4326)$proj4string)
        , method = "ngb"
      )
    }
  } else {
    projected <- x
  }

  pre <- paste0('var data = data || {}; data["', layerId, '"] = ')
  writeLines(pre, pathDatFn)
  cat('[', image2Array(projected, band = band), '];',
      file = pathDatFn, sep = "", append = TRUE)

  ## check for existing layerpicker control
  ctrlid = getCallEntryFromMap(map, "addControl")
  ctrl_nm = paste("imageValues", layerId, sep = "-")
  imctrl = unlist(sapply(ctrlid, function(i) {
    ctrl_nm %in% map$x$calls[[i]]$args
  }))
  ctrlid = ctrlid[imctrl]

  # map = leaflet::clearControls(map)

  if (length(ctrlid) == 0) {
    # must add empty character instead of NULL for html with addControl
    map = leaflet::addControl(
      map,
      html = "",
      layerId = ctrl_nm,
      position = position,
      className = paste("info legend", className)
    )
  }

  sm <- createFileId() #sample(1:1000, 1)
  map$dependencies <- c(map$dependencies,
                        starsDataDependency(jFn = pathDatFn,
                                            counter = 1,
                                            group = paste0(layerId,"_",sm)))
  map$dependencies = c(map$dependencies,
                       list(htmltools::htmlDependency(
                         version = "0.0.1",
                         name = "joda",
                         src = system.file("htmlwidgets/lib/joda",
                                           package = "leafem"),
                         script = c("joda.js",
                                    "addImageQuery-bindings.js"))
                       ))

  bounds <- as.numeric(sf::st_bbox(projected))

  leaflet::invokeMethod(
    map
    , NULL
    , "addImageQuery"
    , layerId
    , bounds
    , type
    , digits
    , prefix
  )
}

##############################################################################
