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

  layers = sf::st_layers(file)
  # geom_type = gdalUtils::ogrinfo(file)
  geom_type = layers$geomtype[[1]]
  if (any(grepl("Line String", geom_type))) fill = FALSE

  # prj = gdalUtils::gdalsrsinfo(file, o = "proj4")
  # prj = prj[grep("+proj=", prj)]
  # # prjln = srs_info[grep("PROJ[^A-Z]", srs_info)]
  # #
  # # prj = regmatches(prjln, regexpr("'([^]]+)'", prjln))
  # prj = gsub(" '", "", prj)
  # prj = gsub("'", "", prj)
  prj = layers$crs[[1]]

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

  if (is.null(layerId)) layerId = group

  path_header = tempfile()
  dir.create(path_header)
  path_header = paste0(path_header, "/", layerId, "_header.json")
  path_layer = tempfile()
  dir.create(path_layer)
  path_layer = paste0(path_layer, "/", layerId, "_layer.json")
  dir_out = tempfile()
  dir.create(dir_out)
  path_outfile = file.path(dir_out, paste0(layerId, ".js"))

  pre <- paste0('var data = data || {}; data["', layerId, '"] = ')
  writeLines(pre, path_header)

  if (tools::file_ext(file) != "geojson") {
    if (sf::st_is_longlat(sf::st_crs(prj))) {
      # gdalUtils::ogr2ogr(
      #   src_datasource_name = file,
      #   dst_datasource_name = path_layer,
      #   f = "GeoJSON"
      # )
      sf::gdal_utils(
        util = "vectortranslate"
        , source = file
        , destination = path_layer
        , options = c(
          "-f", "GeoJSON"
        )
      )
    }
    if (!sf::st_is_longlat(sf::st_crs(prj))) {
      # gdalUtils::ogr2ogr(
      #   src_datasource_name = file,
      #   dst_datasource_name = path_layer,
      #   t_srs = "+proj=longlat +datum=WGS84 +no_defs",
      #   f = "GeoJSON"
      # )
      sf::gdal_utils(
        util = "vectortranslate"
        , source = file
        , destination = path_layer
        , options = c(
          "-t_srs", "+proj=longlat +datum=WGS84 +no_defs",
          "-f", "GeoJSON"
        )
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
      layerId = layerId
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
#'   gdal2tiles.py (see \url{https://gdal.org/programs/gdal2tiles.html} for details).
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
#'   \url{https://github.com/flatgeobuf/flatgeobuf} and the respective
#'   documentation for the GDAL/OGR driver at
#'   \url{https://gdal.org/drivers/vector/flatgeobuf.html}. \cr
#'   \cr
#'   In contrast to classical ways of serving data from R onto a leaflet map,
#'   flatgeobuf can stream the data chunk by chunk so that rendering of the map
#'   is more or less instantaneous. The map is responsive while data is still
#'   loading so that popup queries, zooming and panning will work even
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
#' @param fill whether to fill the path with \code{fillColor}. If \code{fillColor}
#'   is set, this will be set to \code{TRUE}, default is \code{FALSE}.
#' @param fillColor fill color. If set, \code{fill} will be set to \code{TRUE}.
#' @param fillOpacity fill opacity.
#' @param dashArray a string that defines the stroke dash pattern.
#' @param options a list of extra options for tile layers, popups, paths
#'   (circles, rectangles, polygons, ...), or other map elements.
#' @param className optional class name for the popup (table). Can be used
#'   to define css for the popup.
#' @param scale named list with instructions on how to scale radius, width,
#'   opacity, fillOpacity if those are to be mapped to an attribute column.
#' @param ... currently not used.
#'
#' @examples
#'  if (interactive()) {
#'    library(leaflet)
#'    library(leafem)
#'
#'    # via URL
#'    url = "https://raw.githubusercontent.com/flatgeobuf/flatgeobuf/3.0.1/test/data/UScounties.fgb"
#'
#'    leaflet() %>%
#'      addTiles() %>%
#'      leafem:::addFgb(
#'        url = url
#'        , group = "counties"
#'        , label = "NAME"
#'        , popup = TRUE
#'        , fill = TRUE
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
                  fill = FALSE,
                  fillColor = NULL,
                  fillOpacity = 0.2,
                  dashArray = NULL,
                  options = NULL,
                  className = NULL,
                  scale = scaleOptions(),
                  ...) {

  # if (!is.null(fillColor)) fill = TRUE

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  if (is.null(file) & is.null(url))
    stop("need either file or url!\n", call. = FALSE)

  if (is.null(group))
    group = basename(tools::file_path_sans_ext(file))

  if (is.null(layerId)) layerId = group
  layerId = gsub("\\.", "_", layerId)
  layerId = gsub(" ", "", layerId)
  layerId = gsub('\\"', '', layerId)
  layerId = gsub("\\'", "", layerId)

  if (!is.null(file)) {
    if (!file.exists(file)) {
      stop(
        sprintf(
          "file %s does not seem to exist"
          , file
        )
        , call. = FALSE
      )
    }
    path_layer = tempfile()
    dir.create(path_layer)
    path_layer = paste0(path_layer, "/", layerId, "_layer.fgb")

    file.copy(file, path_layer, overwrite = TRUE)

    style_list = list(radius = radius,
                      stroke = stroke,
                      color = color,
                      weight = weight,
                      opacity = opacity,
                      fill = fill,
                      fillColor = fillColor,
                      fillOpacity = fillOpacity)

    scale = utils::modifyList(scaleOptions(), scale)

    options = options[!(options %in% style_list)]

    map$dependencies = c(
      map$dependencies
      , fgbDependencies()
      , chromaJsDependencies()
    )

    map$dependencies = c(
      map$dependencies
      , fileAttachment(path_layer, layerId)
    )

    leaflet::invokeMethod(
      map
      , leaflet::getMapData(map)
      , "addFlatGeoBuf"
      , layerId
      , group
      , url
      , popup
      , label
      , style_list
      , options
      , className
      , scale
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
      , chromaJsDependencies()
    )

    leaflet::invokeMethod(
      map
      , leaflet::getMapData(map)
      , "addFlatGeoBuf"
      , layerId
      , group
      , url
      , popup
      , label
      , style_list
      , options
      , className
      , scale
    )
  }

}


scaleOptions = function(radius = list(to = c(3, 15), from = c(3, 15)),
                        weight = list(to = c(1, 10), from = c(1, 10)),
                        opacity = list(to = c(0, 1), from = c(0, 1)),
                        fillOpacity = list(to = c(0, 1), from = c(0, 1))) {
  list(
    radius = radius
    , weight = weight
    , opacity = opacity
    , fillOpacity = fillOpacity
  )
}

fgbDependencies = function() {
  list(
    htmltools::htmlDependency(
      "FlatGeoBuf"
      , '3.21.3'
      , system.file("htmlwidgets/lib/FlatGeoBuf", package = "leafem")
      , script = c(
        'fgb.js'
        , 'flatgeobuf-geojson.min.js'
      )
    )
  )
}

chromaJsDependencies = function() {
  list(
    htmltools::htmlDependency(
      "chromajs"
      , '2.1.0'
      , system.file("htmlwidgets/lib/chroma", package = "leafem")
      , script = c(
        'chroma.min.js'
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

fileDependency <- function(fn, layerId) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = layerId,
      version = '0.0.1',
      src = c(file = data_dir),
      script = data_file))
}

fileAttachment = function(fn, layerId) {
  data_dir <- dirname(fn)
  data_file <- basename(fn)
  list(
    htmltools::htmlDependency(
      name = layerId,
      version = '0.0.1',
      src = c(file = data_dir),
      attachment = data_file))
}
