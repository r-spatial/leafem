#' add vector data to leaflet map directly from the file system
#'
#' @param map a mapview or leaflet object.
#' @param file file path to the file to be added to \code{map}.
#' @param layerId the layer id.
#' @param group the group name for the file to be added to \code{map}.
#' @param popup logical, whether to show the feature properties (fields) in
#'   popups.
#' @param label name of the field to be shown as a tooltip.
#' @param radius the size of the circle markers.
#' @param stroke whether to draw stroke along the path
#'   (e.g. the borders of polygons or circles).
#' @param color stroke color.
#' @param weight stroke width in pixels.
#' @param opacity stroke opacity.
#' @param fill whether to fill the path with color
#'   (e.g. filling on polygons or circles).
#' @param fillColor fill color.
#' @param fillOpacity fill opacity.
#' @param dashArray a string that defines the stroke dash pattern.
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements.
#'
#' @examples
#' library(leaflet)
#' library(sf)
#'
#' destfile = tempfile(fileext = ".gpkg")
#'
#' st_write(st_as_sf(gadmCHE), dsn = destfile)
#'
#' leaflet() %>%
#'   addTiles() %>%
#'   leafem:::addLocalFile(destfile)
#'
#' @export addLocalFile
#' @name addLocalFile
#' @rdname addLocalFile
#' @aliases addLocalFile
addLocalFile = function(map,
                        file,
                        layerId = NULL,
                        group = NULL,
                        popup = NULL,
                        label = NULL,
                        radius = 10,
                        stroke = TRUE,
                        color = "#03F",
                        weight = 5,
                        opacity = 0.5,
                        fill = TRUE,
                        fillColor = color,
                        fillOpacity = 0.2,
                        dashArray = NULL,
                        options = NULL) {

  geom_type = gdalUtils::ogrinfo(file)
  if (any(grepl("Line String", geom_type))) fill = FALSE

  style_list = list(radius = radius,
                    stroke = stroke,
                    color = color,
                    weight = weight,
                    opacity = opacity,
                    fill = fill,
                    fillColor = fillColor,
                    fillOpacity = fillOpacity)

  options = utils::modifyList(as.list(options), style_list)

  if (is.null(group))
    group = basename(tools::file_path_sans_ext(file))

  path_header = tempfile()
  dir.create(path_header)
  path_header = paste0(path_header, "/", group, "_header.json")
  path_layer = tempfile()
  dir.create(path_layer)
  path_layer = paste0(path_layer, "/", group, "_layer.json")
  dir_out = tempfile()
  dir.create(dir_out)
  path_outfile = file.path(dir_out, paste0(group, ".js"))

  pre <- paste0('var data = data || {}; data["', group, '"] = ')
  writeLines(pre, path_header)

  if (tools::file_ext(file) != "geojson") {
    gdalUtils::ogr2ogr(
      src_datasource_name = file,
      dst_datasource_name = path_layer,
      f = "GeoJSON"
    )
  } else {
    file.copy(file, path_layer, overwrite = TRUE)
  }

  if (.Platform$OS.type == "unix") {
    cmd = paste("cat", path_header, path_layer, ">", path_outfile)
  } else {
    cmd = paste("type", path_header, path_layer, ">", path_outfile)
  }

  system(cmd)
  unlink(path_header)
  unlink(path_layer)

  map$dependencies <- c(
    map$dependencies,
    fileDependency(
      fn = path_outfile,
      group = group
    )
  )

  map$dependencies <- c(
    map$dependencies,
    leafletFileDependencies()
  )

  leaflet::invokeMethod(
    map,
    leaflet::getMapData(map),
    'addFile',
    layerId,
    group,
    popup,
    label,
    options,
    style_list
  )

}

leafletFileDependencies <- function() {
  list(
    htmltools::htmlDependency(
      "File",
      '0.0.1',
      system.file("htmlwidgets/lib/File", package = "leafem"),
      script = c("file.js")
    )
  )
}

fileDependency <- function(fn, group) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = group,
      version = '0.0.1',
      src = c(file = data_dir),
      script = data_file))
}
