addLocalFile = function(map, file, group = NULL) {

  # file = "/home/timpanse/software/testing/gpkg/data1.gpkg"

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

  gdalUtils::ogr2ogr(
    src_datasource_name = file,
    dst_datasource_name = path_layer,
    f = "GeoJSON"
  )

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
    group
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
