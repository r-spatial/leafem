### addHomeButton ############################################################
##############################################################################
#' Add a home button / zoom-to-layer button to a map.
#'
#' @description
#' This function adds a button to the map that enables zooming to a
#' provided extent / bbox.
#'
#' @param map a mapview or leaflet object.
#' @param ext the extent / bbox to zoom to.
#' @param group the name of the group/layer to be zoomed to (or any character
#' string)
#' @param position the position of the button (one of 'topleft', 'topright',
#' 'bottomleft', 'bottomright'). Defaults to 'bottomright'.
#' @param add logical. Whether to add the button to the map (mainly for internal use).
#'
#' @examples
#' library(leaflet)
#' library(raster)
#'
#' ## pass a group name only
#' m <- leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addCircleMarkers(data = breweries91, group = "breweries91") %>%
#'   addHomeButton(group = "breweries91")
#' m
#'
#' ## pass a raster extent - group can now be an arbitrary label
#' m <- leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addCircleMarkers(data = breweries91, group = "breweries91") %>%
#'   addHomeButton(ext = extent(breweries91), group = "Brew")
#' m
#'
#' ## remove the button
#' removeHomeButton(m)
#'
#' @importFrom raster extent
#'
#' @export addHomeButton
#' @name addHomeButton
#' @rdname addHomeButton
#' @param css,hover_css list of valid CSS key-value pairs. See e.g.
#' \url{https://www.w3schools.com/cssref/index.php} for possible values.
#' @aliases addHomeButton
addHomeButton <- function(map, ext, group = "layer",
                          position = 'bottomright', add = TRUE,
                          css = list(), hover_css = list()) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))

  # drop names in case extent of sf object
  if (!missing(ext)) {
    if (inherits(ext, "Extent")) {
      ext = as.vector(ext)[c(1, 3, 2, 4)]
    } else {
      ext = as.vector(ext)
    }
    useext = TRUE
  } else {
    ext = c(0, 0, 0, 0)
    useext = FALSE
  }

  hb <- try(getCallEntryFromMap(map, "addHomeButton"), silent = TRUE)
  if (!inherits(hb, "try-error") & length(hb) == 1) {
    ext_coords <- unlist(map$x$calls[[hb]][["args"]][1:4])
    ext_map <- c(ext_coords[1], ext_coords[2], ext_coords[3], ext_coords[4])
    if (identical(ext, ext_map)) add = FALSE
  }

  if (add) {
    if (inherits(extent, "matrix")) ext = raster::extent(ext)
    label <- paste("Zoom to", group)

    txt <- paste('<strong>', group, '</strong>')

    css_dflt = list(
      "background-color" = "#ffffff95",
      "border" = "none",
      "width" = "100%",
      "height" = "20px",
      "line-height" = "15px",
      "font-size" = "85%",
      "text-align" = "center",
      "text-decoration" = "none",
      "color" = "black",
      "cursor" = "pointer",
      "overflow-x" = "visible",
      "overflow-y" = "hidden",
      "opacity" = "0.25",
      # "filter" = "alpha(opacity = 25)",
      "background-position" = "50% 50%",
      "background-repeat" = "no-repeat",
      "display" = "inline-block"
    )

    hover_css_dflt = list(
      'background-color' =  '#00ffff'
      , 'text-decoration' =  'underline'
      , 'opacity' = '0.9'
    )

    css = jsonlite::toJSON(utils::modifyList(css_dflt, css), auto_unbox = TRUE)
    hover_css = jsonlite::toJSON(
      utils::modifyList(hover_css_dflt, hover_css)
      , auto_unbox = TRUE
    )

    css_txt = sprintf(
      ".leaflet-bar button %s \n\n .leaflet-bar button:hover %s"
      , css
      , hover_css
    )

    css_txt = gsub('\"', '', css_txt)
    css_txt = gsub(",", ";", css_txt)

    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", group, "_home-button.css")
    writeLines(css_txt, path_layer)


    map$dependencies <- c(
      map$dependencies
      , leafletHomeButtonDependencies()
      , cssFileAttachment(path_layer, group)
    )

    leaflet::invokeMethod(map, leaflet::getMapData(map), 'addHomeButton',
                          ext[1], ext[2], ext[3], ext[4],
                          useext, group, label, txt, position)
  }

  else map

}


#' Use removeHomeButton to remove home button
#'
#' @describeIn addHomeButton remove a homeButton from a map
#' @aliases removeHomeButton
#' @export removeHomeButton
removeHomeButton <- function(map) {
  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))
  leaflet::invokeMethod(map, NULL, 'removeHomeButton')
}


addZoomFullButton = function(map, lst, position = "bottomleft") {
  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  crs = ifelse(
    !map$x$options$crs$crsClass == "L.CRS.Simple"
    , 4326
    , getProjection(lst[[1]])
  )
  bb = combineExtent(lst, sf = FALSE, crs = crs)
  names(bb) = NULL
  label = "Zoom to full extent"
  txt = "<strong>Zoom full</strong>"

  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addHomeButton',
                        bb[1], bb[2], bb[3], bb[4], TRUE, NULL, label, txt,
                        position)

}


leafletHomeButtonDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "HomeButton",
      '0.0.1',
      system.file("htmlwidgets/lib/HomeButton", package = "leafem"),
      script = c("home-button.js", 'easy-button-src.min.js')
      # stylesheet = 'home-button.css'
    ))
}

cssFileAttachment = function(fn, layerId) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = paste0(layerId, "-CSS"),
      version = '0.0.1',
      src = c(file = data_dir),
      stylesheet = data_file))
}

##############################################################################
