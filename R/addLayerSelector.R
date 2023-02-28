addGeoJSONLayerSelector <- function(map, layers, layerId) {
  map$dependencies <- c(
    map$dependencies
    , leafletGeoJSONLayerSelectorDependencies()
    , chromaJsDependencies())
  leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , 'addGeoJSONLayerSelector'
    , layers
    , layerId
  )
}

leafletGeoJSONLayerSelectorDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "LayerSelector",
      '0.0.1',
      system.file("htmlwidgets/lib/layerSelector", package = "leafem"),
      script = c("layer_selector.js")
    )
  )
}