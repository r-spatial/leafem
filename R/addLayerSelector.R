addGeoJSONLayerSelector <- function(
    map
    , layers
    , layerId
    , group = NULL
    , position = "topleft"
    , options = colorOptions()
) {

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

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
    , group
    , position
    , options
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