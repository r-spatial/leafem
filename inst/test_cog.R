library(leaflet)
library(leafem)

cog_url = "https://raster-tiles-data.s3.eu-central-1.amazonaws.com/natearth_3857_cog.tif"
# cog_url = "https://storage.googleapis.com/pdd-stac/disasters/hurricane-harvey/0831/20170831_172754_101c_3b_Visual.tif"
url_depoints = "https://vector-tiles-data.s3.eu-central-1.amazonaws.com/depoints.pmtiles"
url = "https://sentinel-cogs.s3.us-west-2.amazonaws.com/sentinel-s2-l2a-cogs/46/X/DG/2022/8/S2B_46XDG_20220829_0_L2A/L2A_PVI.tif"

m = leaflet() %>%
  # setView(lng =-70.09841, lat = -33.037, zoom = 13) %>%
  addTiles(group = "osm") %>%
  # addMapPane("cog", zIndex = 500) %>%
  leafem:::addCOG(
    url = url
    , group = "RGB"
    , layerId = "test"
    , opacity = 1
    # , options = list(pane = "cog")
    , resolution = 256
    , autozoom = TRUE
    # , colorOptions = colorOptions(
    #   palette = grDevices::hcl.colors(3, "Inferno")
    #   , breaks = seq(0, 1, 0.2)
    #   , domain = c(0, 100)
    #   , na.color = "#ff00ff88"
    # )
    # , pixelValuesToColorFn = JS(js_scale)
  ) %>%
  # leafem:::addPMPoints(
  #   url = url_depoints
  #   , layerId = "depoints"
  #   , group = "depoints"
  #   , style = paintRules(
  #     layer = "depoints"
  #     , fillColor = "pink"
  #     , stroke = "green"
  #   )
  # ) %>%
  # addMouseCoordinates() %>%
  addLayersControl(
    baseGroups = c("esri")
    , overlayGroups =  c("RGB")
  )

mapview::mapshot(
  m
  , url = "/home/tim/Downloads/cogmap/index.html"
)

servr::httd("/home/tim/Downloads/cogmap/")


# library(leafem)
# library(leaflet)
#
# # url of images ####
# ndsi <- 'https://storage.googleapis.com/public-cog/NDSI_S2SR_T19HCD_2019-01-01.tif'
# sr <- 'https://storage.googleapis.com/public-cog/SR_S2SR_T19HCD_2019-01-01.tif'
# # Test NDSI ####
#
# min_scale = 0; max_scale = 1
# js_scale = paste0("function (values) {
#                     var scale = chroma.scale(['white', '#22c7e8']).domain([", min_scale, ",", max_scale, "]);
#                     var val = values[0];
#                     if (val === 0) return;
#                     if (val < 0) return;
#                     return scale(val).hex();
#                     }")
#
# leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
#   setView(lng =-70.09635, lat =  -33.01703, zoom = 13) %>%
#   addProviderTiles("Esri.WorldImagery", group = "esri") %>%
#   addMapPane("cog", zIndex = 500) %>%
#   leafem:::addCOG(
#     url = ndsi
#     , group = "NDSI"
#     , opacity = 0.7
#     , options = list(pane = "cog")
#     # , resolution = 96
#     , autozoom = FALSE
#     , colorOptions = colorOptions(
#       palette = grDevices::hcl.colors(3, "Inferno")
#       , breaks = seq(0, 1, 0.2)
#       , domain = c(0, 100)
#       , na.color = "#ff00ff88"
#     )
#     , pixelValuesToColorFn = JS(js_scale)
#   ) %>%
#   addMouseCoordinates() %>%
#   addLayersControl(
#     baseGroups = c("esri")
#     , overlayGroups =  c("NDSI")
#   )
#
# # Try with surface reflectance ####
#
# m = leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
#   setView(lng =-70.09635, lat =  -33.01703, zoom = 13) %>%
#   addTiles(group = "osm") %>%
#   addMapPane("cog", zIndex = 500) %>%
#   leafem:::addCOG(
#     url = sr,
#     group = "RGB", #opacity = 0.7,
#     options = list(pane = "cog"),
#     resolution = 2,
#     autozoom = FALSE,
#     rgb = TRUE
#   ) %>%
#   addLayersControl(
#     baseGroups = c("esri")
#     , overlayGroups =  c("RGB")
#   )
#
# mapview::mapshot(
#   m
#   , url = "/home/tim/Downloads/cogmap/index.html"
# )
#
# servr::httd("/home/tim/Downloads/cogmap/")
#
#
# # Together RGB and NDSI
#
# leaflet(options = leafletOptions(attributionControl = FALSE)) %>%
#   setView(lng =-70.09635, lat =  -33.01703, zoom = 13) %>%
#   addProviderTiles("Esri.WorldImagery", group = "esri") %>%
#   addMapPane("cog", zIndex = 500) %>%
#   leafem:::addCOG(
#     url = ndsi
#     , group = "NDSI"
#     , opacity = 0.7
#     , options = list(pane = "cog")
#     # , resolution = 96
#     , autozoom = FALSE
#     , colorOptions = colorOptions(
#       palette = grDevices::hcl.colors(3, "Inferno")
#       , breaks = seq(0, 1, 0.2)
#       , domain = c(0, 100)
#       , na.color = "#ff00ff88"
#     )
#     , pixelValuesToColorFn = JS(js_scale)
#   ) %>%
#   leafem:::addCOG(
#     url = sr,
#     group = "RGB", opacity = 0.7,
#     options = list(pane = "cog"),
#     #resolution = 2,
#     autozoom = FALSE,
#     rgb = TRUE
#   ) %>%
#   addMouseCoordinates() %>%
#   addLayersControl(
#     baseGroups = c("esri")
#     , overlayGroups =  c("NDSI",'RGB')
#   )