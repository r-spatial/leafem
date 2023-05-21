# pulled from the gplots package: https://cran.r-project.org/web/packages/gplots/index.html
col2hex <- function(cname)
{
  colMat <- col2rgb(cname)
  rgb(
    red=colMat[1,]/255,
    green=colMat[2,]/255,
    blue=colMat[3,]/255
  )
}

changeColorsDependencies <- function(){
  list(
    htmltools::htmlDependency(
      "changeColors",
      "0.0.1",
      system.file("htmlwidgets/lib", package = "leafletColorChange"),
      script = "gradientmaps.js"
    )
  )
}

#' Change the color palette of a map layer

#' @description Given a class name that corresponds to a map layer or layers, uses the
#' 'gradientmap' JavaScript library to change the color scheme on the fly
#' @param map a mapview or leaflet object.
#' @param className character; the class name to apply the color-change to. The layer(s)
#'  must have had this class name assigned to it; see examples
#' @param colors character vector; the colors that form the new color palette. Colors dd
#'   can be either named colors in R (like "red" or "blue") or hexadecimal colors
#' @examples
#' if (interactive()) {
#'   library(leafem)
#'   library(leaflet)
#'
#'   leaflet() %>%
#'     addTiles() %>%
#'     addWMSTiles("https://www.mrlc.gov/geoserver/mrlc_display/NLCD_2016_Bare_Ground_Shrubland_Fractional_Component/ows?SERVICE=WMS&",
#'                 layers = "NLCD_2016_Bare_Ground_Shrubland_Fractional_Component",
#'                 options = WMSTileOptions(className = "bare_ground", transparent = TRUE, format = "image/png")) %>%
#'     changeColors("bare_ground", terrain.colors(20))
#'
#'   leaflet() %>%
#'     addTiles(options = tileOptions(className = "base")) %>%
#'     changeColors("base", colorRampPalette(c("red", "white"))(50))
#' }
#' @export
changeColors <- function(map, className, colors){

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  map$dependencies = c(
    map$dependencies,
    changeColorsDependencies()
  )

  cols <- paste0(col2hex(colors), collapse = ", ")
  map <- htmlwidgets::onRender(
    map,
    sprintf("function(el, x){
      el = document.getElementsByClassName('%s');
      for(let i = 0; i < el.length; i++){
        GradientMaps.applyGradientMap(el[i], '%s');
      }
    }", className, cols)
  )
  return(map)
}
