library(sf)
library(shiny)
library(leaflet)
library(leafem)

# Example data ##########
breweries91 <- st_as_sf(breweries91)
lines <- st_as_sf(atlStorms2005)
polys <- st_as_sf(leaflet::gadmCHE)
overlay1 <- "Overlay with Legend (orange)"
overlay2 <- "Overlay with Legend (blue)"

n = 300
df1 = data.frame(id = 1:n,
                 x = rnorm(n, 20, 3),
                 y = rnorm(n, -49, 1.8))
pts = st_as_sf(df1, coords = c("x", "y"), crs = 4326)
dfnew <- local({
  n <- 300; x <- rnorm(n, mean = 30); y <- rnorm(n, 50)
  z <- sqrt(x ^ 2 + y ^ 2); z[sample(n, 10)] <- NA
  data.frame(x, y, z)
})
palnew <- colorNumeric("OrRd", dfnew$z)
palnew2 <- colorNumeric("Blues", dfnew$z)

# View settings: Each entry is a list with 'coords', 'zoom', and optional 'options' (e.g., padding) ##########
view_settings <- list(
  "Base_tiles1" = list(
    coords = c(20, 50)
    , zoom = 3
  ),
  "Base_tiles2" = list(
    coords = c(-110, 50)
    , zoom = 5
  ),
  "breweries91" = list(
    coords = as.numeric(st_coordinates(st_centroid(st_union(breweries91))))
    , zoom = 8
    , options = NULL
  ),
  "atlStorms2005" = list(
    coords = as.numeric(st_bbox(lines))
    # , options = list(padding = c(10, 10), maxZoom = 6)
  ),
  "gadmCHE" = list(
    coords = as.numeric(st_bbox(polys))
    , options = list(padding = c(10, 10))
    , fly = TRUE
  ),
  "random_points" = list(
    coords = as.numeric(st_coordinates(st_centroid(st_union(pts))))
    , zoom = 7
    , fly = TRUE
  ),
  overlay1 = list(
    coords = c(mean(dfnew$x), mean(dfnew$y))
    , zoom = 7
  )  ,
  overlay2 = list(
    coords = c(mean(dfnew$x), mean(dfnew$y))
    , zoom = 7
  )
)
names(view_settings)[names(view_settings)=="overlay1"] <- overlay1
names(view_settings)[names(view_settings)=="overlay2"] <- overlay2

# Create leaflet map and apply the layer control function  #########
ui <- fluidPage(
  tags$head(tags$style("
    .homebtn, .leaflet-home-btn {
      float: inline-end;
    }
    .home-btn-layer3 {
      background-color: gray;
      padding; 4px
    }
    .home-btn-layer3 {
      background-image: url(https://png.pngtree.com/png-clipart/20190904/original/pngtree-zoom-in-icon-png-image_4490537.jpg);
      content: '';
      color: transparent;
      width: 22px;
      height: 22px;
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
    }
  ")),
  leafletOutput("map")
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    leaflet() %>%
      ## Baselayer
      addTiles(group = "Base_tiles1") %>%
      addProviderTiles("CartoDB", group = "Base_tiles2") %>%

      ## Overlays
      addCircleMarkers(data = breweries91, group = "breweries91") %>%
      addCircleMarkers(data = pts, group = "random_points", color = "red", weight = 1) %>%
      addPolylines(data = lines, group = "atlStorms2005") %>%
      addPolygons(data = polys, group = "gadmCHE") %>%
      addCircleMarkers(data = dfnew, ~x, ~y, color = ~palnew(z), group = overlay1) %>%
      addCircleMarkers(data = dfnew, ~x, ~y, color = ~palnew2(z), group = overlay2) %>%
      addLegend(data = dfnew, pal = palnew, values = ~z,  group = overlay1, position = "bottomleft") %>%
      addLegend(data = dfnew, pal = palnew2, values = ~z, group = overlay2, position = "bottomleft") %>%

      ## LayerViewControl
      addLayerViewControl(view_settings, home_btns = TRUE,
                          home_btn_options = list(
                            "Base_tiles1" = list(text = '🏡', cursor = 'ns-resize', class = 'homebtn home-btn-layer1'),
                            "Base_tiles2" = list(text = '❤️', cursor = 'pointer', class = 'homebtn home-btn-layer2'),
                            "random_points" = list(text = '🌎', cursor = 'all-scroll', class = 'homebtn home-btn-layer3'),
                            "Overlay with Legend (orange)" = list(text = '🚊', cursor = 'all-scroll', class = 'homebtn home-btn-layer3'),
                            "Overlay with Legend (blue)" = list(text = '🚊', cursor = 'all-scroll', class = 'homebtn home-btn-layer3')
                          )) %>%

      ## LayersControl
      addLayersControl(
        baseGroups = c("Base_tiles1", "Base_tiles2"
                       ),
        overlayGroups = c("breweries91", "random_points",
                          overlay1, overlay2,
                          "atlStorms2005", "gadmCHE"),
        options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE)
      )
  })
}
shinyApp(ui, server)
