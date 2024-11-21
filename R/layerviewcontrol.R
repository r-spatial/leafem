#' Extend Layers Control in Leaflet Map
#'
#' This function extends an existing layers control in a `leaflet` map by adding custom views, home buttons,
#' opacity controls, and legends. It enhances the functionality of a layers control created with `leaflet`
#' or `leaflet.extras`.
#'
#' @param map A `leaflet` or `mapview` object to which the extended layers control will be added.
#' @param view_settings A list specifying the view settings for each layer. Each list element should contain
#'   either:
#'   \itemize{
#'     \item \code{coords}: A vector of length 2 (latitude, longitude) for setting the view, or length 4
#'     (bounding box: lat1, lng1, lat2, lng2) for fitting the bounds.
#'     \item \code{zoom}: The zoom level (used for `setView`).
#'     \item \code{fly} (optional): A logical indicating whether to use `flyTo` or `flyToBounds` instead of `setView` or `fitBounds`.
#'     \item \code{options} (optional): Additional options to pass to `setView`, `fitBounds`, or `flyTo`.
#'   }
#' @param home_btns Logical. If `TRUE`, adds a "home" button next to each layer name in the layer control.
#' Clicking the home button zooms the map to the view specified for that layer in \code{view_settings}.
#' @param setviewonselect Logical. If `TRUE` (default) sets the view when the layer is selected.
#' @param home_btn_options A list of options to customize the home button appearance and behavior.
#'   Possible options include:
#'   - `text`: The text or emoji to display on the button (default is '🏠').
#'   - `cursor`: CSS cursor style for the button (default is 'pointer').
#'   - `class`: CSS class name for the button (default is 'leaflet-home-btn').
#'   - `styles`: Semicolon separated CSS-string (default is 'float: inline-end;').
#'
#' @param opacityControl A list specifying the opacity control settings for each layer. Each list element should contain:
#'   \itemize{
#'     \item \code{min}: Minimum opacity value (default is 0).
#'     \item \code{max}: Maximum opacity value (default is 1).
#'     \item \code{step}: Step size for the opacity slider (default is 0.1).
#'     \item \code{default}: Default opacity value (default is 1).
#'     \item \code{width}: Width of the opacity slider (default is '100%').
#'     \item \code{class}: CSS class name for the slider (default is 'leaflet-opacity-slider').
#'   }
#'
#' @param includelegends Logical. If `TRUE` (default), appends legends to the layer control. Legends are matched
#'   to layers by their group name. The legends need to be added with corresponding layer IDs.
#'
#' @return A modified `leaflet` map object with extended layers control including view controls, home buttons, opacity controls, and legends.
#'
#' @details
#' This function generates JavaScript that listens for `overlayadd` or `baselayerchange` events
#' and automatically sets the view or zoom level according to the specified \code{view_settings}.
#' If `home_btns` is enabled, a home button is added next to each layer in the layer control.
#' When clicked, it zooms the map to the predefined view of that layer.
#' The opacity control slider allows users to adjust the opacity of layers. The legend will be appended
#' to the corresponding layer control, matched by the layer's group name.
#'
#' @examples
#' library(sf)
#' library(leaflet)
#' library(leafem)
#'
#' # Example data ##########
#' breweries91 <- st_as_sf(breweries91)
#' lines <- st_as_sf(atlStorms2005)
#' polys <- st_as_sf(leaflet::gadmCHE)
#'
#' # View settings ##########
#' view_settings <- list(
#'   "Base_tiles1" = list(
#'     coords = c(20, 50),
#'     zoom = 3
#'   ),
#'   "Base_tiles2" = list(
#'     coords = c(-110, 50),
#'     zoom = 5
#'   ),
#'   "breweries91" = list(
#'     coords = as.numeric(st_coordinates(st_centroid(st_union(breweries91)))),
#'     zoom = 8
#'   ),
#'   "atlStorms2005" = list(
#'     coords = as.numeric(st_bbox(lines)),
#'     options = list(padding = c(110, 110))
#'   ),
#'   "gadmCHE" = list(
#'     coords = as.numeric(st_bbox(polys)),
#'     options = list(padding = c(2, 2)),
#'     fly = TRUE
#'   )
#' )
#'
#' # Opacity control settings ##########
#' opacityControl <- list(
#'   "breweries91" = list(
#'     min = 0,
#'     max = 1,
#'     step = 0.1,
#'     default = 1,
#'     width = '100%',
#'     class = 'opacity-slider'
#'   )
#' )
#'
#' # Legends ##########
#' legends <- list(
#'   "breweries91" = "<div>Legend for breweries</div>"
#' )
#'
#' leaflet() %>%
#'   ## Baselayer
#'   addTiles(group = "Base_tiles1") %>%
#'   addProviderTiles("CartoDB", group = "Base_tiles2") %>%
#'
#'   ## Overlays
#'   addCircleMarkers(data = breweries91, group = "breweries91") %>%
#'   addPolylines(data = lines, group = "atlStorms2005") %>%
#'   addPolygons(data = polys, group = "gadmCHE") %>%
#'
#'   ## Extend Layers Control
#'   extendLayersControl(
#'     view_settings, home_btns = TRUE,
#'     home_btn_options = list(
#'       "Base_tiles1" = list(text = '🏡', cursor = 'ns-resize', class = 'homebtn'),
#'       "Base_tiles2" = list(text = '❤️', cursor = 'pointer'),
#'       "atlStorms2005" = list(text = '🌎', cursor = 'all-scroll'),
#'       "breweries91" = list(text = '🌎', styles = 'background-color: red'),
#'       "gadmCHE" = list(text = '🌎', styles = 'float: none;')
#'     ),
#'     opacityControl = opacityControl,
#'     includelegends = TRUE
#'   ) %>%
#'
#'   ## LayersControl
#'   addLayersControl(
#'     baseGroups = c("Base_tiles1", "Base_tiles2"),
#'     overlayGroups = c("breweries91", "atlStorms2005", "gadmCHE"),
#'     options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE)
#'   )
#'
#' @export
extendLayersControl <- function(map,
                                view_settings,
                                home_btns = FALSE,
                                home_btn_options = list(),
                                setviewonselect = TRUE,
                                opacityControl = list(),
                                includelegends = TRUE) {

  # Initialize data structures for view settings and home buttons
  view_data <- list()
  home_data <- list()

  # Loop over each layer to populate view_data and home_data
  for (layer in names(view_settings)) {
    setting <- view_settings[[layer]]

    # Store coordinates and zoom options for setView or fitBounds
    if (length(setting$coords) == 2) {
      view_data[[layer]] <- list(
        coords = setting$coords,
        zoom = setting$zoom,
        fly = ifelse(is.null(setting[["fly"]]), FALSE, setting[["fly"]]),
        options = setting$options
      )
    } else if (length(setting$coords) == 4) {
      view_data[[layer]] <- list(
        bounds = setting$coords,
        fly = ifelse(is.null(setting[["fly"]]), FALSE, setting[["fly"]]),
        options = setting$options
      )
    }

    # Store home button data if enabled
    if (isTRUE(home_btns)) {
      home_data[[layer]] <- as.list(c(
        layer = layer, home_btn_options[[layer]]
      ))
    }
  }

  # Add deps & Pass view and home button data using invokeMethod
  map$dependencies <- c(
    map$dependencies
    , layerViewControlDependencies()
  )

  if (requireNamespace("fontawesome")) {
    map$dependencies <- c(
      map$dependencies
      , list(fontawesome::fa_html_dependency())
    )
  }

  leaflet::invokeMethod(
    map,
    NULL,
    'extendLayersControl',
    view_data,
    home_data,
    setviewonselect,
    opacityControl,
    includelegends
  )
}


layerViewControlDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "layerViewControl",
      '0.0.1',
      system.file("htmlwidgets/lib/layerviewcontrol", package = "leafem"),
      script = "layerviewcontrol.js",
      stylesheet = c(
        "layerviewcontrol.css"
        # , "fontawesome.min.css"
      )
    )
  )
}
