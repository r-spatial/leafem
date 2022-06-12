library(leaflet)
library(leafem)

url = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.pmtiles"
file = "/home/tim/Downloads/lds-nz-building-outlines/dunedin-building-outlines3857.pmtiles"

m = leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
  addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
  leafem:::addPMTiles(
    url = url
    , file = NULL
    , layerId = "test"
    , group = "test1"
    , style = paintRules(layer = "zcta")
  ) %>%
  addMouseCoordinates() %>%
  setView(173.89, -40.65, zoom = 6) %>%
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
