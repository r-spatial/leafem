logodeps <- function() {
  list(
    htmltools::htmlDependency(
      "logodeps",
      version = "1.0.0",
      system.file("htmlwidgets/lib/", package = "leafem"),
      script = "logo.js",
    )
  )
}


### addLogo ##################################################################
##############################################################################
#' add a local or remote image (png, jpg, gif, bmp, ...) to a leaflet map
#'
#' @description
#' This function adds an image to a map. Both local and remote (web) image
#' sources are supported. Position on the map is completely controllable.
#'
#' @param map a mapview or leaflet object.
#' @param img the image to be added to the map.
#' @param alpha opacity of the added image.
#' @param src character specifying the source location ("local" for images from
#' the disk, "remote" for web image sources).
#' @param url an optional URL to be opened when clicking on the image
#' (e.g. company's homepage).
#' @param position one of "topleft", "topright", "bottomleft", "bottomright".
#' @param offset.x the offset in x direction from the chosen position (in pixels).
#' @param offset.y the offset in y direction from the chosen position (in pixels).
#' @param width width of the rendered image in pixels.
#' @param height height of the rendered image in pixels.
#' @param layerId an id for the logo div.
#' @param class optional class
#'
#' @examples
#' library(leaflet)
#' ## default position is topleft next to zoom control
#'
#' img <- "https://www.r-project.org/logo/Rlogo.svg"
#' leaflet() %>% addTiles() %>% addLogo(img, url = "https://www.r-project.org/logo/")
#'
#' ## with local image
#' if (requireNamespace("png")) {
#'   library(png)
#'
#'   img <- system.file("img", "Rlogo.png", package="png")
#'   leaflet() %>% addTiles() %>% addLogo(img, src = "local", alpha = 0.3)
#'
#'   ## dancing banana gif :-)
#'   m <- leaflet() %>%
#'     addTiles() %>%
#'     addCircleMarkers(data = breweries91)
#'
#'   addLogo(m, "https://jeroenooms.github.io/images/banana.gif",
#'           position = "bottomleft",
#'           offset.x = 5,
#'           offset.y = 40,
#'           width = 100,
#'           height = 100)
#' }
#'
#'
#' @export addLogo
#' @name addLogo
#' @rdname addLogo
#' @importFrom leaflet filterNULL
#' @aliases addLogo

## courtesy of
## http://gis.stackexchange.com/questions/203265/add-logo-to-a-map-using-leaflet-mapbox
## http://jsfiddle.net/3v7hd2vx/76/

addLogo <- function(map,
                    img,
                    alpha = 1,
                    src = c("remote", "local"),
                    url = NULL,
                    position = c("topleft", "topright",
                                 "bottomleft", "bottomright"),
                    offset.x = 50,
                    offset.y = 13,
                    width = 60,
                    height = 60,
                    class = NULL,
                    layerId = NULL) {

  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))

  # src <- match.arg(src)
  position <- match.arg(position)

  map$dependencies <- c(map$dependencies, logodeps())

  if (file.exists(img)) {
    fileext <- tools::file_ext(img)
    if (fileext == "svg") fileext <- paste0(fileext, "+xml")
    img <- base64enc::dataURI(file = img, mime = paste0("image/", fileext))
  }

  options <- filterNULL(list(
    alpha = alpha,
    url = url,
    position = position,
    offsetX = offset.x,
    offsetY = offset.y,
    width = width,
    height = height,
    class = class
  ))

  ## Make sure layerId is set and unique
  if (is.null(layerId)) {
    layerId <- as.character(as.numeric(Sys.time()))
  }

  leaflet::invokeMethod(
    map,
    NULL,
    "addLogo",
    img,
    layerId,
    options)
}

#' removeLogo
#' @inheritParams addLogo
#' @rdname addLogo
#' @export
removeLogo <- function(map, layerId) {
  leaflet::invokeMethod(
    map,
    NULL,
    "removeLogo",
    layerId)
}

#' hideLogo
#' @inheritParams addLogo
#' @rdname addLogo
#' @export
hideLogo <- function(map, layerId) {
  leaflet::invokeMethod(
    map,
    NULL,
    "hideLogo",
    layerId)
}

#' showLogo
#' @inheritParams addLogo
#' @rdname addLogo
#' @export
showLogo <- function(map, layerId) {
  leaflet::invokeMethod(
    map,
    NULL,
    "showLogo",
    layerId)
}

