#' Add vector data to leaflet map directly from the file system
#'
#' @param map a mapview or leaflet object.
#' @param file file path to the file to be added to \code{map}. NOTE: will be
#'   reprojected on-the-fly if not in "longlat".
#' @param layerId the layer id.
#' @param group the group name for the file to be added to \code{map}.
#' @param popup either a logical of whether to show the feature properties
#'   (fields) in popups or the name of the field to show in popups.
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
#' if (interactive()) {
#'   library(leafem)
#'   library(leaflet)
#'   library(sf)
#'
#'   destfile = tempfile(fileext = ".gpkg")
#'
#'   st_write(st_as_sf(gadmCHE), dsn = destfile)
#'
#'   leaflet() %>%
#'     addTiles() %>%
#'     addLocalFile(destfile, popup = TRUE)
#' }
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

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  geom_type = gdalUtils::ogrinfo(file)
  if (any(grepl("Line String", geom_type))) fill = FALSE

  prj = gdalUtils::gdalsrsinfo(file, o = "proj4")
  prj = prj[grep("+proj=", prj)]
  # prjln = srs_info[grep("PROJ[^A-Z]", srs_info)]
  #
  # prj = regmatches(prjln, regexpr("'([^]]+)'", prjln))
  prj = gsub(" '", "", prj)
  prj = gsub("'", "", prj)

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
    if (sf::st_is_longlat(sf::st_crs(prj))) {
      gdalUtils::ogr2ogr(
        src_datasource_name = file,
        dst_datasource_name = path_layer,
        f = "GeoJSON"
      )
    }
    if (!sf::st_is_longlat(sf::st_crs(prj))) {
      gdalUtils::ogr2ogr(
        src_datasource_name = file,
        dst_datasource_name = path_layer,
        t_srs = "+proj=longlat +datum=WGS84 +no_defs",
        f = "GeoJSON"
      )
    }
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

#' Add raster tiles from a local folder
#'
#' @description
#'   Add tiled raster data pyramids from a local folder that was created with
#'   gdal2tiles.py (see \url{https://gdal.org/gdal2tiles.html} for details).
#'
#' @param map a mapview or leaflet object.
#' @param folder the (top level) folder where the tiles (folders) reside.
#' @param tms whether the tiles are served as TMS tiles.
#' @param layerId the layer id.
#' @param group the group name for the tile layer to be added to \code{map}.
#' @param attribution the attribution text of the tile layer (HTML).
#' @param options a list of extra options for tile layers.
#'   See \code{\link[leaflet]{tileOptions}} for details. When the tiles
#'   were created with \code{gdal2tiles.py} argument \code{tms} needs to be
#'   set to \code{TRUE}.
#' @param data the data object from which the argument values are derived;
#'   by default, it is the data object provided to leaflet() initially,
#'   but can be overridden.
#'
#' @export addTileFolder
#' @name addTileFolder
#' @rdname addTileFolder
#' @aliases addTileFolder
addTileFolder = function(map,
                         folder,
                         tms = TRUE,
                         layerId = NULL,
                         group = NULL,
                         attribution = NULL,
                         options = leaflet::tileOptions(),
                         data = leaflet::getMapData(map)) {

  options = utils::modifyList(options, list(tms = tms), keep.null = TRUE)

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  # fldrs = list.dirs(folder, recursive = FALSE)
  # bsn = basename(fldrs)
  #
  # zooms = as.numeric(bsn)
  # mnzm = min(zooms)
  #
  # fldr_mnzm = fldrs[basename(fldrs) == as.character(mnzm)]
  # fldrs_mnzm = list.dirs(fldr_mnzm, recursive = TRUE)[-1]
  #
  # fldrs_mnzm_mn = fldrs_mnzm[which.min(as.numeric(basename(fldrs_mnzm)))]
  # fldrs_mnzm_mx = fldrs_mnzm[which.max(as.numeric(basename(fldrs_mnzm)))]
  #
  # x_mn = min(as.numeric(basename(fldrs_mnzm_mn)))
  # x_mx = max(as.numeric(basename(fldrs_mnzm_mx)))
  #
  # tiles_mn = list.files(fldrs_mnzm_mn)
  # y_mn = min(as.numeric(tools::file_path_sans_ext(tiles_mn)))
  # y_mn = (2^mnzm) - y_mn - 1
  #
  # tiles_mx = list.files(fldrs_mnzm_mx)
  # y_mx = max(as.numeric(tools::file_path_sans_ext(tiles_mx)))
  # y_mx = (2^mnzm) - y_mx - 1
  #
  # ll_mn = tilenum_to_lonlat(x_mn, y_mn + 1, mnzm)
  # ll_mx = tilenum_to_lonlat(x_mx, y_mx, mnzm)

  m = leaflet::addTiles(
    map = map,
    urlTemplate = paste0(
      "lib/",
      basename(folder),
      "-0.0.1/{z}/{x}/{y}.png"
    ),
    group = group,
    options = options,
    data = data
  )

  m$dependencies =  c(m$dependencies, tiledDataDependency(folder))

  return(m)

}


#' Add a flatgeobuf file to leaflet map
#'
#' @description
#'   flatgeobuf is a performant binary geo-spatial file format suitable for
#'   serving large data. For more details see
#'   \url{https://github.com/bjornharrtell/flatgeobuf} and the respective
#'   documentation for the GDAL/OGR driver at
#'   \url{https://gdal.org/drivers/vector/flatgeobuf.html}. \cr
#'   \cr
#'   In contrast to classical ways of serving data from R onto a leaflet map,
#'   flatgeobuf will stream the data chunk by chunk so that rendering of the map
#'   is more or less instantaneous. The map is responsive while data is still
#'   being streamed so that popup queries, zooming and panning will work even
#'   though not all data has been rendered yet. This makes for a rather pleasant
#'   user experience as we don't have to wait for all data to be added to the map
#'   before interacting with it.
#'
#' @param map a mapview or leaflet object.
#' @param file file path to the .fgb file to be added to \code{map}.
#'   If set, \code{url} is ignored.
#' @param url url of the data to be added to \code{map}. Only respected if
#'   \code{file = NULL}.
#' @param layerId the layer id.
#' @param group the group name for the file to be added to \code{map}.
#' @param popup either a logical of whether to show the feature properties
#'   (fields) in popups or the name of the field to show in popups.
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
#'  if (interactive()) {
#'    library(leaflet)
#'    library(leafem)
#'
#'    # via URL
#'    url = "https://raw.githubusercontent.com/bjornharrtell/flatgeobuf/3.0.1/test/data/UScounties.fgb"
#'
#'    leaflet() %>%
#'      addTiles() %>%
#'      leafem:::addFgb(
#'        url = url
#'        , group = "counties"
#'        , label = "NAME"
#'        , popup = TRUE
#'        , fillColor = "blue"
#'        , fillOpacity = 0.6
#'        , color = "black"
#'        , weight = 1
#'      ) %>%
#'        addLayersControl(overlayGroups = c("counties")) %>%
#'        addMouseCoordinates() %>%
#'        setView(lng = -105.644, lat = 51.618, zoom = 3)
#'  }
#'
#' @export addFgb
#' @name addFgb
#' @rdname addFgb
#' @aliases addFgb
addFgb = function(map,
                  file = NULL,
                  url = NULL,
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

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  if (is.null(file) & is.null(url))
    stop("need either file or url!\n", call. = FALSE)

  if (is.null(group))
    group = basename(tools::file_path_sans_ext(file))

  if (!is.null(file)) {
    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", group, "_layer.fgb")

    file.copy(file, path_layer, overwrite = TRUE)

    style_list = list(radius = radius,
                      stroke = stroke,
                      color = color,
                      weight = weight,
                      opacity = opacity,
                      fill = fill,
                      fillColor = fillColor,
                      fillOpacity = fillOpacity)

    options = utils::modifyList(as.list(options), style_list)

    map$dependencies = c(
      map$dependencies
      , fgbDependencies()
    )

    map$dependencies = c(
      map$dependencies
      , fileAttachment(path_layer, group)
    )

    leaflet::invokeMethod(
      map
      , leaflet::getMapData(map)
      , "addFlatGeoBuf"
      , group
      , url
      , popup
      , label
      , style_list
      , options
    )
  } else {
    style_list = list(radius = radius,
                      stroke = stroke,
                      color = color,
                      weight = weight,
                      opacity = opacity,
                      fill = fill,
                      fillColor = fillColor,
                      fillOpacity = fillOpacity)

    options = utils::modifyList(as.list(options), style_list)

    map$dependencies = c(
      map$dependencies
      , fgbDependencies()
    )

    leaflet::invokeMethod(
      map
      , leaflet::getMapData(map)
      , "addFlatGeoBuf"
      , group
      , url
      , popup
      , label
      , style_list
      , options
    )
  }

}

fgbDependencies = function() {
  list(
    htmltools::htmlDependency(
      "FlatGeoBuf"
      , '0.0.1'
      , system.file("htmlwidgets/lib/FlatGeoBuf", package = "leafem")
      , script = c(
        'fgb.js'
        , 'flatgeobuf-geojson.min.js'
      )
    )
  )
}

tiledDataDependency <- function(tiles_dir) {
  list(
    htmltools::htmlDependency(
      name = basename(tiles_dir),
      version = "0.0.1",
      src = c(file = tiles_dir)
    )
  )
}


degrees <- function(angle_rad) (angle_rad * 180) / pi

# copyright Miles McBain
tilenum_to_lonlat <- function(x, y, zoom){
  n_tiles <- 2^zoom

  lon_rad <- (((x / n_tiles) * 2) - 1) * pi

  merc_lat <- (1 - ((y / n_tiles) * 2)) * pi
  lat_rad <- atan(sinh(merc_lat))

  list(lon = degrees(lon_rad),
       lat = degrees(lat_rad))
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

fileAttachment = function(fn, group) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = group,
      version = '0.0.1',
      src = c(file = data_dir),
      attachment = data_file))
}
