addLayerSelector <- function(map, layers) {
  map$dependencies <- c(map$dependencies, leafletLayerSelectorDependencies())
  leaflet::invokeMethod(map, leaflet::getMapData(map), 'addLayerSelector', layers)
}

leafletLayerSelectorDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "LayerSelector",
      '0.0.1',
      system.file("htmlwidgets/lib/layerSelector", package = "leafem"),
      script = c("layer_selector.js")
    )
  )
}