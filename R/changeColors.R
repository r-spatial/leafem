# pulled from the gplots package:
# https://cran.r-project.org/web/packages/gplots/index.html
col2hex <- function(cname) {
  colMat <- grDevices::col2rgb(cname)
  grDevices::rgb(
    red = colMat[1, ] / 255,
    green = colMat[2, ] / 255,
    blue = colMat[3, ] / 255
  )
}

changeColorsDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "gradientmaps",
      "0.0.1",
      src = system.file("htmlwidgets/lib/gradientmaps", package = "leafem"),
      script = "gradientmaps.js"
    ),
    htmltools::htmlDependency(
      "gradientmaps_r_binding",
      utils::packageVersion("leafem"),
      src = system.file("htmlwidgets/lib/gradientmaps", package = "leafem"),
      script = "changeColors.js"
    )
  )
}
#' Change the color palette of a map layer

#' @description Given a class name that corresponds to a map layer or layers,
#'   uses the 'gradientmap' JavaScript library to change the color scheme on the
#'   fly
#' @param map a mapview or leaflet object.
#' @param className character vector; one or more class names to apply the
#'   color-change to. The layer(s) must have had this class name assigned to it;
#'   see examples. Note that this will be applied to all HTML elements with this
#'   class, so the more unique the name, the better. `className` should be
#'   missing if `selector` is provided.
#' @param colors character vector; the colors that form the new color palette.
#'   Colors can be either named colors in R (like "red" or "blue") or
#'   hexadecimal colors
#' @param selector character vector; one or more CSS selectors - any element
#'   that matches this selector will have its color changed
#' @param legend boolean; if `TRUE`, the color change will be applied to a
#'   legend created using `leaflet::addLegend()`. The legend must have the
#'   specified class name, which be done with the `className` parameter of
#'   `addLegend()`. Note that the class name of the legend needs to be different
#'   than the class name of the map layer - otherwise the color change will be
#'   applied to the entire legend rather than just the color bar. See examples.
#' @examples
#' if (interactive()) {
#'   library(leaflet)
#'
#'   # example using 'addWMSTiles()'
#'   leaflet() |>
#'     addTiles() |>
#'     fitBounds(-126, 29, -99, 49) |>
#'     addWMSTiles(
#'       paste0(
#'         "https://www.mrlc.gov/geoserver/mrlc_display/",
#'         "NLCD_2016_Bare_Ground_Shrubland_Fractional_Component/",
#'         "ows?SERVICE=WMS&"
#'       ),
#'       layers = "NLCD_2016_Bare_Ground_Shrubland_Fractional_Component",
#'       options = WMSTileOptions(className = "bare_ground",
#'                                transparent = TRUE,
#'                                format = "image/png")) |>
#'     changeColors("bare_ground", terrain.colors(20))
#'
#'   # example using 'addTiles()'
#'   leaflet() |>
#'     addTiles(options = tileOptions(className = "base")) |>
#'     changeColors("base", colorRampPalette(c("red", "white"))(50))
#'
#'   # example using 'addRasterImage()' and 'addLegend()'
#'   r <- raster::raster(xmn = -2.8, xmx = -2.79, ymn = 54.04, ymx = 54.05,
#'   nrows = 30, ncols = 30, crs = "EPSG:4326", vals = 1:900)
#'   old_pal <- colorNumeric(topo.colors(50), c(0, 1000))
#'   new_pal <- heat.colors(50)
#'   leaflet() |>
#'     addTiles() |>
#'     addRasterImage(r, colors = old_pal, opacity = 0.8,
#'                    options = tileOptions(className = "base")) |>
#'     addLegend(pal = old_pal, values = c(0, 1000),
#'               className = "info legend base-legend") |>
#'     changeColors("base", new_pal) |>
#'     changeColors("base-legend", new_pal, legend = TRUE)
#' }
#' @export
changeColors <- function(map, className, colors, selector = NULL,
                         legend = FALSE) {
  if (missing(className)) {
    if (is.null(selector)) {
      stop("when 'className' is missing 'selector' must not be NULL")
    }
  } else {
    if (!is.null(selector)) {
      warning(paste0("both 'className' and 'selector' were provided;",
                     "'selector' will be ignored"))
    }
    selector <- paste0(".", className)
  }

  if (legend) {
    selector <- paste0(selector, " > div:first-child > span")
  }

  if (inherits(map, "mapview")) map <- mapview2leaflet(map)

  map$dependencies <- c(
    map$dependencies,
    changeColorsDependencies()
  )

  if (length(colors) > 201) {
    colors <- grDevices::colorRampPalette(colors)(201)
  }

  cols <- paste0(col2hex(colors), collapse = ", ")
  if (inherits(map, "leaflet_proxy")) {
    for (selector_i in selector) {
      leaflet::invokeMethod(map,
                            leaflet::getMapData(map),
                            "changeColors",
                            selector_i,
                            cols)
    }
  } else {
    for (selector_i in selector) {
      map <- htmlwidgets::onRender(
        map,
        sprintf(
          "function(el, x){
            GradientMaps.applyGradientMapToSelector('%s', '%s');
          }",
          selector_i,
          cols
        )
      )
    }
  }
  return(map)
}
