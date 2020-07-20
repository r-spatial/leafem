#' Add stars/raster image to a leaflet map using optimised rendering.
#'
#' @details
#' This uses the leaflet plugin 'georaster-layer-for-leaflet' to render raster data.
#' See \url{https://github.com/GeoTIFF/georaster-layer-for-leaflet} for details.
#' The clue is that rendering uses simple nearest neighbor interpolation on-the-fly
#' to ensure smooth rendering. This enables handling of larger rasters than with
#' the standard \code{\link[leaflet]{addRasterImage}}.
#'
#' @param map the map to add the raster data to.
#' @param x the stars/raster object to be rendered.
#' @param group he name of the group this raster image should belong to.
#' @param layerId the layerId.
#' @param resolution the target resolution for the simple nearest neighbor interpolation.
#'   Larger values will result in more detailed rendering, but may impact performance.
#'   Default is 96 (pixels).
#' @param opacity opacity of the rendered layer.
#' @param options options to be passed to the layer.
#'   See \code{\link[leaflet]{tileOptions}} for details.
#' @param colorOptions list defining the palette, breaks and na.color to be used.
#' @param project whether to project the RasterLayer to conform with leaflets
#'   expected crs. Defaults to \code{TRUE} and things are likely to go haywire
#'   if set to \code{FALSE}.
#' @param pixelValuesToColorFn optional JS function to be passed to the browser.
#'   Can be used to fine tune and manipulate the color mapping.
#'   See \url{https://github.com/r-spatial/leafem/issues/25} for some examples.
#' @param ... currently not used.
#'
#' @return
#' A leaflet map object.
#'
#' @examples
#' if (interactive()) {
#'   library(leaflet)
#'   library(leafem)
#'   library(stars)
#'
#'   tif = system.file("tif/L7_ETMs.tif", package = "stars")
#'   x1 = read_stars(tif)
#'   x1 = x1[, , , 3] # band 3
#'
#'   leaflet() %>%
#'     addTiles() %>%
#'     leafem:::addGeoRaster(
#'       x1
#'       , opacity = 1
#'       , colorOptions = colorOptions(
#'         palette = grey.colors(256)
#'       )
#'     )
#' }
#'
#' @export addGeoRaster
#' @name addGeoRaster
#' @rdname addGeoRaster
addGeoRaster = function(map,
                        x,
                        group = NULL,
                        layerId = NULL,
                        resolution = 96,
                        opacity = 0.8,
                        options = leaflet::tileOptions(),
                        colorOptions = colorOptions(),
                        project = TRUE,
                        pixelValuesToColorFn = NULL,
                        ...) {

  if (inherits(x, "Raster")) {
    x = stars::st_as_stars(x)
  }

  if (project && !sf::st_is_longlat(x)) {
    x = stars::st_warp(x, crs = 4326)
  }

  fl = tempfile(fileext = ".tif")

  if (inherits(x, "stars_proxy")) {
    file.copy(x[[1]], fl)
  }

  if (!inherits(x, "stars_proxy")) {
    stars::write_stars(x, dsn = fl)
  }

  addGeotiff(
    map
    , file = fl
    , url = NULL
    , group = group
    , layerId = layerId
    , resolution = resolution
    , opacity = opacity
    , options
    , colorOptions = colorOptions
    , pixelValuesToColorFn = pixelValuesToColorFn
  )

}


#' Add a GeoTIFF file to a leaflet map using optimised rendering.
#'
#' @details
#' This uses the leaflet plugin 'georaster-layer-for-leaflet' to render GeoTIFF data.
#' See \url{https://github.com/GeoTIFF/georaster-layer-for-leaflet} for details.
#' The GeoTIFF file is read directly in the browser using geotiffjs
#' (\url{https://geotiffjs.github.io/}), so there's no need to read data into
#' the current R session. GeoTIFF files can be read from the file system or via url.
#' The clue is that rendering uses simple nearest neighbor interpolation on-the-fly
#' to ensure smooth rendering. This enables handling of larger rasters than with
#' the standard \code{\link[leaflet]{addRasterImage}}.
#'
#' @param map the map to add the raster data to.
#' @param file path to the GeoTIFF file to render.
#' @param url url to the GeoTIFF file to render. Ignored if \code{file} is provided.
#' @param group he name of the group this raster image should belong to.
#' @param layerId the layerId.
#' @param resolution the target resolution for the simple nearest neighbor interpolation.
#'   Larger values will result in more detailed rendering, but may impact performance.
#'   Default is 96 (pixels).
#' @param opacity opacity of the rendered layer.
#' @param options options to be passed to the layer.
#'   See \code{\link[leaflet]{tileOptions}} for details.
#' @param colorOptions list defining the palette, breaks and na.color to be used.
#' @param pixelValuesToColorFn optional JS function to be passed to the browser.
#'   Can be used to fine tune and manipulate the color mapping.
#'   See examples & \url{https://github.com/r-spatial/leafem/issues/25} for some examples.
#' @param ... currently not used.
#'
#' @return
#' A leaflet map object.
#'
#' @examples
#' if (interactive()) {
#'   library(leaflet)
#'   library(leafem)
#'   library(stars)
#'
#'   tif = system.file("tif/L7_ETMs.tif", package = "stars")
#'   x1 = read_stars(tif)
#'   x1 = x1[, , , 3] # band 3
#'
#'   tmpfl = tempfile(fileext = ".tif")
#'
#'   write_stars(st_warp(x1, crs = 4326), tmpfl)
#'
#'   myCustomJSFunc = htmlwidgets::JS(
#'     "
#'       pixelValuesToColorFn = (raster, colorOptions) => {
#'         const cols = colorOptions.palette;
#'         var scale = chroma.scale(cols);
#'
#'         if (colorOptions.breaks !== null) {
#'           scale = scale.classes(colorOptions.breaks);
#'         }
#'         var pixelFunc = values => {
#'           let clr = scale.domain([raster.mins, raster.maxs]);
#'           if (isNaN(values)) return colorOptions.naColor;
#'           return clr(values).hex();
#'         };
#'         return pixelFunc;
#'       };
#'     "
#'   )
#'
#'   leaflet() %>%
#'     addTiles() %>%
#'     addGeotiff(
#'       file = tmpfl
#'       , opacity = 0.9
#'       , colorOptions = colorOptions(
#'         palette = grey.colors
#'         , na.color = "transparent"
#'       )
#'       , pixelValuesToColorFn = myCustomJSFunc
#'     )
#'
#' }
#'
#' @export addGeotiff
#' @name addGeotiff
#' @rdname addGeotiff
addGeotiff = function(map,
                      file = NULL,
                      url = NULL,
                      group = NULL,
                      layerId = NULL,
                      resolution = 96,
                      opacity = 0.8,
                      options = leaflet::tileOptions(),
                      colorOptions = NULL, #colorOptions(),
                      pixelValuesToColorFn = NULL,
                      ...) {

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  if (is.null(file) & is.null(url))
    stop("need either file or url!\n", call. = FALSE)

  if (is.null(group))
    group = basename(tools::file_path_sans_ext(file))

  if (is.null(layerId)) layerId = group
  layerId = gsub("\\.", "_", layerId)

  if (!is.null(file)) {
    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", layerId, "_layer.tif")

    file.copy(file, path_layer, overwrite = TRUE)

    map$dependencies <- c(
      map$dependencies
      , fileAttachment(path_layer, layerId)
      , leafletGeoRasterDependencies()
      , chromaJsDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeotiff"
      , url
      , group
      , layerId
      , resolution
      , opacity
      , options
      , colorOptions
      , pixelValuesToColorFn
    )
  } else {
    map$dependencies <- c(
      map$dependencies
      , leafletGeoRasterDependencies()
      , chromaJsDependencies()
    )

    leaflet::invokeMethod(
      map
      , data = leaflet::getMapData(map)
      , method = "addGeotiff"
      , url
      , group
      , layerId
      , resolution
      , opacity
      , options
      , colorOptions
      , pixelValuesToColorFn
    )
  }

}


#' Color options for addGeoRaster and addGeotiff
#'
#' @param palette the color palette to use. Can be a set of colors or a
#'   color generating function such as the result of \code{\link[grDevices]{colorRampPalette}}.
#' @param breaks the breaks at which color should change.
#' @param na.color color for NA values (will map to NaN in Javascript).
#'
#' @export
colorOptions = function(palette = NULL,
                        breaks = NULL,
                        na.color = "#bebebe22") {
  if (is.function(palette)) {
    palette = palette(256)
  }
  list(
    palette = palette
    , breaks = breaks
    , naColor = na.color
  )
}


leafletGeoRasterDependencies = function() {
  list(
    htmltools::htmlDependency(
      "GeoRaster",
      '0.0.1',
      system.file("htmlwidgets/lib/georaster-for-leaflet", package = "leafem"),
      script = c(
        "georaster.min.js"
        , "georaster-layer-for-leaflet.browserify.min.js"
        , "georaster-binding.js"
      )
    )
  )
}