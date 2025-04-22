#' Add an RGB image as a layer
#'
#' @description
#' Create a Red-Green-Blue image overlay from a \code{RasterStack} /
#' \code{RasterBrick} or \code{stars} object based on three layers.
#' Three layers (sometimes referred to as "bands" because they may represent
#' different bandwidths in the electromagnetic spectrum) are combined such
#' that they represent the red, green and blue channel. This function can
#' be used to make 'true (or false) color images' from Landsat and other
#' multi-band satellite images. Note, this text is plagiarized, i.e. copied
#' from \code{\link[raster]{plotRGB}}.
#' \code{addRasterRGB} and \code{addStarsRGB} are aliases.
#'
#' @param map a map widget object created from `leaflet()``
#' @param x a  `RasterBrick`, `RasterStack` or `stars`` raster object
#' @param r integer. Index of the Red channel/band, between 1 and nlayers(x)
#' @param g integer. Index of the Green channel/band, between 1 and nlayers(x)
#' @param b integer. Index of the Blue channel/band, between 1 and nlayers(x)
#' @param quantiles the upper and lower quantiles used for color stretching.
#'   If set to NULL, stretching is performed basing on `domain` argument.
#' @param domain the upper and lower values used for color stretching.
#'   This is used only if `quantiles` is NULL.
#'   If both `domain` and `quantiles` are set to NULL, stretching is applied
#'   based on min-max values.
#' @param na.color the color to be used for NA pixels
#' @inheritParams terra::project
#' @param ... additional arguments passed on to \code{\link[leaflet]{addRasterImage}}
#'
#' @author
#' Tim Appelhans, Luigi Ranghetti
#'
#' @details
#' Note, method `auto`, the default, will choose between `near` for factorial and
#' `bilinear` for numeric data. All other methods need to be set manually.
#'
#'
#' @examples
#' \donttest{
#'   require(raster)
#'   require(stars)
#'   require(plainview)
#'   require(leaflet)
#'
#'   leaflet() %>%
#'     addTiles(group = "OpenStreetMap") %>%
#'     addRasterRGB(plainview::poppendorf, 4,3,2, group = "True colours") %>%
#'     addStarsRGB(st_as_stars(plainview::poppendorf), 5,4,3, group = "False colours") %>%
#'     addLayersControl(
#'       baseGroups = c("Satellite"),
#'       overlayGroups = c("True colours", "False colours"),
#'     )
#' }
#'
#' @importFrom grDevices rgb
#' @importFrom leaflet addRasterImage
#' @importFrom raster extent as.factor is.factor ncell projectExtent
#'  projectRaster projection sampleRegular
#' @importFrom stats quantile
#' @export

addRasterRGB <- function(
  map,
  x,
  r = 3, g = 2, b = 1,
  quantiles = c(0, 1),
  domain = NULL,
  na.color = "#BEBEBE80",
  method = c("auto", "bilinear", "near", "average", "mode", "cubic", "cubicspline",
             "lanczos", "sum", "min", "q1", "median", "q3", "max", "rms"),
  ...
) {

  # this allows using `addRasterRGB` directly on a leaflet pipe, without
  # specifying `data` (e.g., leaflet(plainview::poppendorf) %>%
  #  addProviderTiles("OpenStreetMap") %>% addRasterRGB())
  #
  if (inherits(map, c("leaflet", "leaflet_proxy"))) {
    if (missing(x)) {
      x <- attributes(map[["x"]])[["leafletData"]]
    }
  }

  isRaster <- inherits(x, "Raster")
  isTerra <- inherits(x, "SpatRaster")

  if (isRaster || isTerra) {
    method <- match.arg(method)
    if (method == "auto") {
      if (isRaster) {
        raster_is_factor <- raster::is.factor(x[[r]])
        has_colors = FALSE
      }
      if (isTerra) {
        raster_is_factor <- terra::is.factor(x[[r]])
        # there 1.5-50 has terra::has.colors(x)
        ctab <- terra::coltab(x[[r]])[[1]]
        has_colors <- !is.null(ctab)
      }
      if (raster_is_factor || has_colors) {
        method <- "near"
      } else {
        method <- "bilinear"
      }
    }

    if (!terra::same.crs(x, "EPSG:3857")) {
      if (isRaster) {
        if (!method %in% c("bilinear", "near")) stop("invalid method for raster objects")
        if (method == "near") method <- "ngb"
        x = raster::projectRaster(x, raster::projectExtent(x, "EPSG:3857"), method = method)
      }
      if (isTerra) {
        x = terra::project(x, y = "EPSG:3857", method = method)
      }
    }

    mat <- cbind(x[[r]][],
                 x[[g]][],
                 x[[b]][])

  } else if (inherits(x, "stars")) {
    raster_is_factor <- is.factor(x[[1]])
    method <- match.arg(method)
    if (method == "auto") {
      if (raster_is_factor) {
        method <- "near"
      } else {
        method <- "bilinear"
      }
    }
    x = suppressWarnings(
      stars::st_warp(x, crs = "EPSG:3857", method = method, use_gdal = TRUE)
    )

    mat <- cbind(as.vector(x[[1]][, , r]),
                 as.vector(x[[1]][, , g]),
                 as.vector(x[[1]][, , b]))

  } else {

    stop("'x' must be a Raster*, stars or terra object.")

  }

  if (!is.null(quantiles)) {

    for(i in seq(ncol(mat))){
      z <- mat[, i]
      lwr <- stats::quantile(z, quantiles[1], na.rm = TRUE)
      upr <- stats::quantile(z, quantiles[2], na.rm = TRUE)
      z <- (z - lwr) / (upr - lwr)
      z[z < 0] <- 0
      z[z > 1] <- 1
      mat[, i] <- z
    }
  } else if (!is.null(domain)) {
    mat <- apply(mat, 2, rscl, from = domain)
    # Stretch values outside colour range to band limits
    mat[mat < 0] <- 0
    mat[mat > 1] <- 1
  } else {
    # If there is no stretch we just scale the data between 0 and 1
    mat <- apply(mat, 2, rscl)
  }

  na_indx <- rowSums(is.na(mat)) > 0
  cols <- mat[, 1]
  cols[na_indx] <- na.color
  cols[!na_indx] <- grDevices::rgb(mat[!na_indx, ], alpha = 1)
  p <- function(x) cols

  dotlst = list(...)
  dotlst = utils::modifyList(dotlst, list(map = map, colors = p, method = method))
  out <- if (isRaster) {
    dotlst = utils::modifyList(dotlst, list(x = x[[r]]))
    do.call(addRasterImage, dotlst)
  } else if (isTerra) {
    dotlst = utils::modifyList(dotlst, list(x = x[[r]], project = FALSE))
    do.call(addRasterImage, dotlst)
  } else {
    dotlst = utils::modifyList(dotlst, list(x = x))
    do.call(addStarsImage, dotlst)
  }

  return(out)

}

#' @name addRasterRGB
#' @rdname addRasterRGB
#' @export
addStarsRGB <- addRasterRGB


## Helper functions imported from mapview needed by addRGB() ===================

rscl = function(x,
                from = range(x, na.rm = TRUE, finite = TRUE),
                to = c(0, 1),
                ...) {
  (x - from[1]) / diff(from) * diff(to) + to[1]
}

# Scale extent -----------------------------------------------------------------
# scaleExtent <- function(x) {
#   ratio <- raster::nrow(x) / raster::ncol(x)
#   x_sc <- scales::rescale(c(x@extent@xmin, x@extent@xmax), c(0, 1))
#   y_sc <- scales::rescale(c(x@extent@ymin, x@extent@ymax), c(0, 1)) * ratio
#   return(raster::extent(c(x_sc, y_sc)))
# }

addRGB = function(
  map,
  x,
  r = 3, g = 2, b = 1,
  group = NULL,
  layerId = NULL,
  resolution = 96,
  opacity = 0.8,
  options = leaflet::tileOptions(),
  colorOptions = NULL,
  project = TRUE,
  pixelValuesToColorFn = NULL,
  ...
) {

  if (inherits(x, "Raster")) {
    x = stars::st_as_stars(x)
  }

  if (project & !sf::st_is_longlat(x)) {
    x = stars::st_warp(x, crs = 4326)
  }

  if (is.null(colorOptions)) {
    colorOptions = colorOptions()
  }

  fl = tempfile(fileext = ".tif")

  if (inherits(x, "stars_proxy")) {
    # file.copy(x[[1]], fl)
    fl = x[[1]]
  }

  if (!inherits(x, "stars_proxy")) {
    stars::write_stars(x, dsn = fl)
  }

  minband = min(r, g, b)

  rgbPixelfun = htmlwidgets::JS(
    sprintf(
      "
        pixelValuesToColorFn = values => {
        // debugger;
          if (isNaN(values[0])) return '%s';
          return rgbToHex(
            Math.ceil(values[%s])
            , Math.ceil(values[%s])
            , Math.ceil(values[%s])
          );
        };
      "
      , colorOptions[["naColor"]]
      , r - minband
      , g - minband
      , b - minband
    )
  )

  # todo: streching via quantiles and domain...

  addGeotiff(
    map
    , file = fl
    , url = NULL
    , group = group
    , layerId = layerId
    , resolution = resolution
    , bands = c(r, g, b)
    , arith = NULL
    , opacity = opacity
    , options = options
    , colorOptions = colorOptions
    , rgb = TRUE
    , pixelValuesToColorFn = rgbPixelfun
  )

}