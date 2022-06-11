library(leaflet)
library(leafem)

url = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/nz-building-outlines.pmtiles"

m = leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB.Positron") %>%
  addProviderTiles("Esri.WorldImagery", group = "Esri.WorldImagery") %>%
  leafem:::addPMTiles(
    url
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
