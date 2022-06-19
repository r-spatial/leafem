library(leaflet)
library(leafem)

url_pmtiles = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.pmtiles"
url_fgb = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.fgb"

m = leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
  addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
  leafem:::addPMTiles(
    url = url_pmtiles
    , file = NULL
    , layerId = "pmtiles"
    , group = "pmtiles"
    , style = paintRules(layer = "nz-building-outlines")
  ) %>%
  addFgb(
    url = url_fgb
    , group = "fgb"
    , layerId = "fgb"
    , label = "suburb_locality"
    , popup = TRUE
    , fill = TRUE
    , fillColor = "violet"
    , fillOpacity = 0.8
    , color = "black"
    , weight = 1
    , minZoom = 15
  ) %>%
  addMouseCoordinates() %>%
  setView(173.89, -40.65, zoom = 6) %>%
  addLayersControl(
    baseGroups = c(
      "CartoDB.Positron"
      , "Esri.WorldImagery"
    )
    , overlayGroups = c(
      "pmtiles"
      , "fgb"
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
