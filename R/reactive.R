addReactiveFeatures = function(map,
                               x,
                               bindTo,
                               by,
                               on,
                               group,
                               layerId = NULL,
                               options = NULL,
                               style = NULL,
                               updateStyle = NULL,
                               popup = NULL) {

  if (!inherits(x, "geojson")) {
    x = geojsonsf::sf_geojson(x)
  }

  map$dependencies = c(
    map$dependencies
    , reactiveDependencies()
  )

  leaflet::invokeMethod(
    map
    , leaflet::getMapData(map)
    , "addReactiveLayer"
    , x
    , bindTo
    , by
    , on
    , group
    , layerId
    , options
    , style
    , updateStyle
    , popup
  )

}


reactiveDependencies = function() {
  list(
    htmltools::htmlDependency(
      "reactive"
      , '0.0.1'
      , system.file("htmlwidgets/lib/reactive", package = "leafem")
      , script = c(
        'reactive.js'
      )
    )
  )
}