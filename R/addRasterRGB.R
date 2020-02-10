#' Add an RGB image as a layer
#'
#' @description
#' Create a Red-Green-Blue image overlay from a \code{RasterStack} /
#' \code{RasterBrick} or \code{stars} object based on three layers.
#' Three layers (sometimes referred to as "bands" because they may represent
#' different bandwidths in the electromagnetic spectrum) are combined such
#' that they represent the red, green and blue channel. This function can
#' be used to make 'true (or false) color images' from Landsat and other
#' multi-band satellite images. Note, this text is plagirized, i.e. copied
#' from \code{\link{plotRGB}}.
#' \code{AddRasterRGB} and \code{addStarsRGB} are aliases.
#'
#' @param map a map widget object created from `leaflet()``
#' @param x a  `RasterBrick`, `RasterStack` or `stars`` raster object
#' @param r integer. Index of the Red channel/band, between 1 and nlayers(x)
#' @param g integer. Index of the Green channel/band, between 1 and nlayers(x)
#' @param b integer. Index of the Blue channel/band, between 1 and nlayers(x)
#' @param quantiles the upper and lower quantiles used for color stretching.
#' If set to NULL, stretching is performed basing on `domain` argument.
#' @param domain the upper and lower values used for color stretching.
#' This is used only if `quantiles` is NULL.
#' If bot `domain` and `quantiles` are set to NULL, stretching is applied
#' basing on min-max values.
#' @param na.color the color to be used for NA pixels
#' @param ... additional arguments passed on to \code{\link{addRasterImage}}
#'
#' @author
#' Tim Appelhans, Luigi Ranghetti
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
#' @importFrom sp CRS
#' @importFrom scales rescale
#' @export

addRasterRGB <- function(
  map,
  x,
  r = 3, g = 2, b = 1,
  quantiles = c(0.02, 0.98),
  domain = NULL,
  na.color = "#BEBEBE80",
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

  if (inherits(x, "Raster")) {

    mat <- cbind(x[[r]][],
                 x[[g]][],
                 x[[b]][])

  } else if (inherits(x, "stars")) {

    mat <- cbind(as.vector(x[[1]][, , r]),
                 as.vector(x[[1]][, , g]),
                 as.vector(x[[1]][, , b]))

  } else {

    stop("'x' must be a Raster* or stars object.")

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
    mat <- apply(mat, 2, scales::rescale, from = domain)
    # Stretch values outside colour range to band limits
    mat[mat < 0] <- 0
    mat[mat > 1] <- 1
  } else {
    # If there is no stretch we just scale the data between 0 and 1
    mat <- apply(mat, 2, scales::rescale)
  }

  na_indx <- apply(mat, 1, anyNA)
  cols <- mat[, 1]
  cols[na_indx] <- na.color
  cols[!na_indx] <- grDevices::rgb(mat[!na_indx, ], alpha = 1)
  p <- function(x) cols

  lyrs <- paste(r, g, b, sep = ".")

  dotlst = list(...)
  dotlst = utils::modifyList(dotlst, list(map = map, colors = p))
  out <- if (inherits(x, "Raster")) {
    dotlst = utils::modifyList(dotlst, list(x = x[[r]]))
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

# Scale extent -----------------------------------------------------------------
scaleExtent <- function(x) {
  ratio <- raster::nrow(x) / raster::ncol(x)
  x_sc <- scales::rescale(c(x@extent@xmin, x@extent@xmax), c(0, 1))
  y_sc <- scales::rescale(c(x@extent@ymin, x@extent@ymax), c(0, 1)) * ratio
  return(raster::extent(c(x_sc, y_sc)))
}

