#' Add stars layer to a leaflet map
#'
#' @param map a mapview or leaflet object.
#' @param x a stars layer.
#' @param band the band number to be plotted.
#' @param data the data object from which the argument values are derived; by
#'   default, it is the \code{data} object provided to \code{leaflet()}
#'   initially, but can be overridden.
#' @inheritParams addRasterRGB
#' @inheritParams leaflet::addRasterImage
#' @param ... currently not used.
#'
#' @details
#' This is an adaption of \code{\link[leaflet]{addRasterImage}}. See that documentation
#' for details.
#'
#' @examples
#' \donttest{
#' library(stars)
#' library(leaflet)
#'
#' tif = system.file("tif/L7_ETMs.tif", package = "stars")
#' x = read_stars(tif)
#' leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addStarsImage(x, project = TRUE)
#' }
#'
#' @importFrom grDevices col2rgb colors
#' @importFrom leaflet colorNumeric expandLimits getMapData invokeMethod gridOptions
#' @importFrom sf st_as_sfc st_bbox st_transform
#' @importFrom base64enc base64encode
#' @importFrom png writePNG
#' @export
addStarsImage <- function(
  map
  , x
  , band = 1
  , colors = "Spectral"
  , opacity = 1
  , attribution = NULL
  , layerId = NULL
  , group = NULL
  , project = FALSE
  , method = c("auto", "bilinear", "near")
  , maxBytes = 4 * 1024 * 1024
  , options = gridOptions()
  , data = getMapData(map)
  , ...
) {

  # this allows using `addStarsImage` directly on a leaflet pipe, without
  # specifying `x` (e.g., leaflet(read_stars(tif)) %>%
  # addProviderTiles("OpenStreetMap") %>% addStarsImage())
  #
  if (inherits(map, c("leaflet", "leaflet_proxy"))) {
    if (missing(x)) {
      x <- attributes(map[["x"]])[["leafletData"]]
    }
  }

  stopifnot(inherits(x, "stars"))

  if (any(attr(attr(x, "dimensions"), "raster")$affine != 0) |
      attr(attr(x, "dimensions"), "raster")$curvilinear)
    warning(
      "cannot handle curvilinear or sheared stars images. Rendering regular grid."
      , call. = FALSE
    )

  raster_is_factor <- is.factor(x[[1]])
  method <- match.arg(method)
  if (method == "auto") {
    if (raster_is_factor) {
      method <- "near"
    } else {
      method <- "bilinear"
    }
  }

  if (inherits(map, "mapview")) map = mapview2leaflet(map)
  if (is.null(group)) group = "stars"
  if (is.null(layerId)) layerId = group

  if (project) {
    # if we should project the data
    if (utils::packageVersion("stars") >= "0.4-1") {
      projected = stars::st_warp(x, crs = 3857, method = method, use_gdal = TRUE)
    } else {
      projected <- sf::st_transform(x, crs = 3857)
    }

    # if data is factor data, make the result factors as well.
    #if (raster_is_factor) {
    #  projected <- raster::as.factor(projected)
    #}
  } else {
    # do not project data
    projected <- x
  }

  bb <- sf::st_as_sfc(sf::st_bbox(projected))
  bounds <- as.numeric(sf::st_bbox(sf::st_transform(bb, 4326)))

  if(length(dim(projected)) == 2) {
    layer = projected[[1]]
  } else {
    layer = projected[[1]][, , band]
  }

  if (!is.function(colors)) {
    if (method == "near") {
      # 'factors'
      colors <- leaflet::colorFactor(
        colors, domain = NULL, na.color = "#00000000", alpha = TRUE
      )
    } else {
      # 'numeric'
      colors <- leaflet::colorNumeric(
        colors, domain = NULL, na.color = "#00000000", alpha = TRUE
      )
    }
  }

  if (is.null(attr(layer, "color"))) {
    clrs = colors(as.numeric(layer))
  } else {
    clrs = colors(layer)
  }
  clrs = grDevices::col2rgb(clrs, alpha = TRUE)
  tileData = as.raw(clrs)

  # tileData <- as.numeric(layer) %>%
  #   colors() %>% grDevices::col2rgb(alpha = TRUE) %>% as.raw()
  dim(tileData) <- c(4, nrow(projected), ncol(projected))
  pngData <- png::writePNG(tileData)
  if (length(pngData) > maxBytes) {
    stop(
      "Raster image too large; ", length(pngData),
      " bytes is greater than maximum ", maxBytes, " bytes"
    )
  }
  encoded <- base64enc::base64encode(pngData)
  uri <- paste0("data:image/png;base64,", encoded)

  latlng <- list(
    list(bounds[4], bounds[1]),
    list(bounds[2], bounds[3])
  )
  options$opacity <- opacity
  options$attribution <- attribution

  map = leaflet::invokeMethod(
    map, data, "addRasterImage", uri, latlng,
    layerId, group, options
  )

  leaflet::expandLimits(
    map,
    c(bounds[2], bounds[4]),
    c(bounds[1], bounds[3])
  )

}
