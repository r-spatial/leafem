addLayerSelector <- function(map, layers, layerId) {
  map$dependencies <- c(
    map$dependencies
    , leafletLayerSelectorDependencies()
    , chromaJsDependencies())
  leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addLayerSelector'
    , layers
    , layerId
  )
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