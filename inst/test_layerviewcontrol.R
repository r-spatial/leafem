library(sf)
library(shiny)
library(leaflet)
library(leaflet.extras)
library(leaflegend)
library(leafem)
options("shiny.autoreload" = TRUE)

# Example data ##########
breweries91 <- st_as_sf(breweries91)
lines <- st_as_sf(atlStorms2005)
data("gadmCHE")
gadmCHE@data$x <- sample(c('A', 'B', 'C'), nrow(gadmCHE@data), replace = TRUE)
polys <- st_as_sf(gadmCHE)
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
  ## Custom CSS ###########
  tags$head(tags$style("
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
  ## Input + Map  ###########
  tags$div(style="display: inline-flex",
    selectInput("layercontrol", "Layer Control",
                choices = c("layercontrol", "groupedlayercontrol")),
    shiny::checkboxInput("includelegends", "Inlcude Legends", value = TRUE),
    shiny::checkboxInput("homebtns", "Home Buttons", value = TRUE),
    shiny::checkboxInput("setviewonselect", "Set View on select", value = TRUE),
  ),
  leafletOutput("map", height = 800)
)

## Server ##################
server <- function(input, output, session) {
  output$map <- renderLeaflet({

    factorPal <- colorFactor(c('#1f77b4', '#ff7f0e' , '#2ca02c'), gadmCHE@data$x)
    binPal <- colorBin('Set1', lines$MaxWind, bins = 4)
    quantPal <- colorQuantile('Reds', lines$MaxWind, n = 3)

    m <- leaflet() %>%
      ## Baselayer ##########
      addTiles(group = "Base_tiles1") %>%
      addProviderTiles("CartoDB", group = "Base_tiles2") %>%

      ## Overlays ##########
      addCircleMarkers(data = breweries91, group = "breweries91") %>%
      addCircleMarkers(data = pts, opacity = 1, fillOpacity = .4,
                       group = "random_points", color = "red", weight = 1) %>%
      # addLegendSize(values = 1, color = 'red', shape  = 'circle', breaks = 1, group = "random_points", layerId="random_points") %>%
      addLegendImage(images = makeSymbol(shape="circle", color = "red", opacity = 1, fillOpacity = .4, width = 10),
                     labels = "", group = "random_points", layerId="random_points",
                     orientation = 'horizontal') %>%
      addPolylines(data = lines, color = ~quantPal(MaxWind), label=~MaxWind, group = "atlStorms2005") %>%
      addLegendQuantile(data = lines, pal = quantPal, values = ~MaxWind, numberFormat = NULL,
                        group = "atlStorms2005", position = 'topright') %>%
      addPolygons(data = polys, color = ~factorPal(x), label=~x, group = "gadmCHE") %>%
      addLegendFactor(pal = factorPal, shape = 'polygon', fillOpacity = .5,
                      opacity = 0, values = ~x,
                      position = 'topright', data = gadmCHE, group = 'gadmCHE') %>%
      addCircleMarkers(data = dfnew, ~x, ~y, color = ~palnew(z), label=~z, group = overlay1) %>%
      addCircleMarkers(data = dfnew, ~x, ~y, color = ~palnew2(z), label=~z, group = overlay2) %>%
      addLegendNumeric(orientation = "horizontal", width = 180, height = 20,
                       data = dfnew, pal = palnew, layerId = overlay1,
                       values = ~z,  group = overlay1, position = "bottomleft") %>%
      addLegend(data = dfnew, pal = palnew2, layerId = overlay2, values = ~z, group = overlay2, position = "bottomleft") %>%

      ## extendLayerControl ##########
      extendLayersControl(view_settings
                         , includelegends = input$includelegends
                         , home_btns = input$homebtns
                         , setviewonselect = input$setviewonselect
                         , home_btn_options = list(
                            "Base_tiles1" = list(text = '🏡', cursor = 'ns-resize', class = 'homebtn home-btn-layer1'),
                            "Base_tiles2" = list(text = '❤️', cursor = 'pointer', class = 'homebtn home-btn-layer2'),
                            "random_points" = list(text = '🌎', cursor = 'all-scroll', class = 'homebtn home-btn-layer3'),
                            "Overlay with Legend (orange)" = list(text = '🚊', cursor = 'all-scroll', class = 'homebtn home-btn-layer3'),
                            "Overlay with Legend (blue)" = list(text = '🚊', cursor = 'all-scroll', class = 'homebtn home-btn-layer3')
                          )
                         , opacityControl = list(
                           "random_points" = list(min= 0, max= 1, step= 0.01, default= 0.7, width= '140px'),
                           "Overlay with Legend (orange)" = list(min= 0.1, max= 0.8, step= 0.1, default= 1),
                           "Overlay with Legend (blue)" = list(default= 0.5)
                         )
                         )

    ## LayersControls ##########
    if (input$layercontrol == "layercontrol") {
      m %>%
        addLayersControl(
          baseGroups = c("Base_tiles1", "Base_tiles2"
          ),
          overlayGroups = c("breweries91", "random_points",
                            overlay1, overlay2,
                            "atlStorms2005", "gadmCHE"),
          options = layersControlOptions(collapsed = FALSE, autoZIndex = TRUE)
        )
    } else {
      m %>%
        addGroupedLayersControl(
          baseGroups = c("Base_tiles1","Base_tiles2"),
          overlayGroups = list(
            "Group1" = c("breweries91","random_points",
                         overlay1, overlay2),
            "Group2" = c("atlStorms2005", "gadmCHE")),
          position = "topright",
          options = groupedLayersControlOptions(groupCheckboxes = TRUE,
                                                collapsed = FALSE,
                                                groupsCollapsable = TRUE,
                                                groupsExpandedClass = "glyphicon glyphicon-chevron-down",
                                                groupsCollapsedClass = "glyphicon glyphicon-chevron-right",
                                                sortLayers = FALSE,
                                                sortGroups = FALSE,
                                                sortBaseLayers = FALSE,
                                                exclusiveGroups = "Group2")
        )
    }

  })
}
shinyApp(ui, server)
