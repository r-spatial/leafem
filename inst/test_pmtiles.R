library(leaflet)
library(leafem)

# url_pmtiles = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines_max14.pmtiles"
# url_fgb = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.fgb"
# url_pmtiles = "http://localhost/test-tiles/nz-building-outlines_max14.pmtiles"
url_pmtiles = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.pmtiles"
url_rivers = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/rivers.pmtiles"
url_fgb = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/rivers.fgb"
url_depoints = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/depoints.pmtiles"


m = leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
  addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
  leafem:::addPMTilesPolygons(
    url = url_pmtiles
    , layerId = "nzbuildings"
    , group = "nzbuildings"
    , style = paintRules(
      layer = "nz-building-outlines"
      , fillColor = "pink"
      , stroke = "green"
    )
  ) %>%
  leafem:::addPMTilesPoints(
    url = url_depoints
    , layerId = "depoints"
    , group = "depoints"
    , style = paintRules(
      layer = "depoints"
      , fillColor = "pink"
      , stroke = "green"
    )
  ) %>%
  # addFgb(
  #   url = url_fgb
  #   , group = "fgb"
  #   , layerId = "fgb"
  #   # , label = "suburb_locality"
  #   , popup = TRUE
  #   , fill = FALSE
  #   , fillColor = "violet"
  #   , fillOpacity = 0.8
  #   , color = "black"
  #   , weight = 1
  #   , minZoom = 3
  # ) %>%
  addMouseCoordinates() %>%
  # setView(173.89, -40.65, zoom = 6) %>%
  setView(0, 0, zoom = 2) %>%
  addLayersControl(
    baseGroups = c(
      "CartoDB.Positron"
      , "Esri.WorldImagery"
    )
    , overlayGroups = c(
      "nzbuildings"
      , "depoints"
    )
  )

mapview::mapshot(
  m
  , url = "/home/tim/Downloads/pmtilesmap/index.html"
)

servr::httd("/home/tim/Downloads/pmtilesmap/")



url = "https://www.carbon.place/tiles/pct/{x}/{y}/{z}.pbf"

m = leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
  addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
  leafem:::addPMTiles(
    url
    , layerName = "bicycle"
    , layerId = "test"
    , group = "test1"
  ) %>%
  addMouseCoordinates() %>%
  # setView(173.89, -40.65, zoom = 6) %>%
  addLayersControl(
    baseGroups = c(
      "CartoDB.Positron"
      , "Esri.WorldImagery"
    )
    , overlayGroups = "test1"
  )

mapview::mapshot(
  m
  , url = "/home/tim/Downloads/pmtilesmap/index.html"
)

servr::httd("/home/tim/Downloads/pmtilesmap/")
