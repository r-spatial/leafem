## the two crs we use
wmcrs <- "+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext +no_defs"
llcrs <- "+proj=longlat +datum=WGS84 +no_defs"

### getSFClass
getSFClass <- function(x) {
  if (class(x)[1] == "XY") class(x)[2] else class(x)[1]
}

# Convenience functions for working with spatial objects and leaflet maps
getCallMethods = function(map) {
  sapply(map$x$calls, "[[", "method")
}


getLayerControlEntriesFromMap <- function(map) {
  grep("addLayersControl", getCallMethods(map), fixed = TRUE, useBytes = TRUE)
}

# Get layer names of leaflet map ------------------------------------------

getLayerNamesFromMap <- function(map) {

  len <- getLayerControlEntriesFromMap(map)
  len <- len[length(len)]
  if (length(len) != 0) map$x$calls[[len]]$args[[2]] else NULL

}



getCallEntryFromMap <- function(map, call) {
  grep(call, getCallMethods(map), fixed = TRUE, useBytes = TRUE)
}


combineExtent = function(lst, sf = FALSE, crs = 4326) {
  # lst = list(breweries, st_as_sf(atlStorms2005), st_as_sf(gadmCHE))
  # bb = do.call(rbind, lapply(lst, sf::st_bbox))
  bb = do.call(rbind, lapply(seq(lst), function(i) {
  if (!is.null(lst[[i]])) {
    if (!is.na(getProjection(lst[[i]]))) {
      sf::st_bbox(sf::st_transform(sf::st_as_sfc(sf::st_bbox(lst[[i]])),
                                   crs = crs))
    } else {
      sf::st_bbox(sf::st_as_sfc(sf::st_bbox(lst[[i]])))
    }
  }
  }))

  bbmin = apply(bb, 2, min)
  bbmax = apply(bb, 2, max)
  bb = c(bbmin[1], bbmin[2], bbmax[3], bbmax[4])
  if (sf) {
    attr(bb, which = "class") = "bbox"
    attr(bb, "crs") = sf::st_crs(crs)
    return(sf::st_as_sfc(bb))
  }
  return(bb)
}


makepathStars <- function(group) {
  dirs <- list.dirs(tempdir())
  # tmpPath <- grep(utils::glob2rx("*data_large*"), dirs, value = TRUE)
  # if (length(tmpPath) == 0) {
  tmpPath <- paste(tempfile(pattern = "data_stars"),
                   createFileId(),
                   sep = "_")
  dir.create(tmpPath)
  # }
  baseFn <- paste("data_stars", group, sep = "_")
  extFn <- "txt"
  datFn <- paste0(baseFn, createFileId(), ".", extFn)
  pathDatFn <- paste0(tmpPath, "/", datFn)
  starspathDatFn <- paste0(tmpPath, "/", "stars_", datFn)
  return(list(tmpPath, pathDatFn, starspathDatFn, datFn))
}

createFileId <- function(ndigits = 6) {
  paste(sample(c(letters[1:6], 0:9), ndigits), collapse = "")
}

stars2Array = function(x, band = 1) {
  if(length(dim(x)) == 2) layer = x[[1]] else layer = x[[1]][, , band]
  paste(
    sapply(seq(nrow(x[[1]])), function(i) {
      paste0(
        '[', gsub("NA", "null",
                  paste(as.numeric(layer[i, ]), collapse = ",")), ']'
      )
    }),
    collapse = ","
  )
}


image2Array = function(x, band = 1) {
  switch(class(x)[1],
         "stars" = stars2Array(x, band = band),
         "RasterLayer" = rasterLayer2Array(x),
         stop("can only query single raster or stars layers so far"))
}

rasterLayer2Array = function(x) {
  x = as.matrix(x)
  paste(
    sapply(seq(ncol(x)), function(i) {
      paste0(
        '[', gsub("NA", "null",
                  paste(as.matrix(x)[, i], collapse = ",")), ']'
      )
    }),
    collapse = ","
  )
}

starsDataDependency <- function(jFn, counter = 1, group) {
  data_dir <- dirname(jFn)
  data_file <- basename(jFn)
  list(
    htmltools::htmlDependency(
      name = group,
      version = counter,
      src = c(file = data_dir),
      script = list(data_file)))
}

### mapview to leaflet
mapview2leaflet <- function(x) {
  # methods::slot(x, "map")
  x@map
}


getProjection <- function(x) {

  if (inherits(x, c("Raster", "Spatial"))) {
    prj <- raster::projection(x)
  } else {
    prj <- sf::st_crs(x)$proj4string
  }

  return(prj)

}

getGeometryType <- function(x) {
  # sf
  if (inherits(x, "Spatial")) x = sf::st_as_sfc(x)
  g <- sf::st_geometry(x)
  if (inherits(g, "POINT") |
      inherits(g, "MULTIPOINT") |
      inherits(g, "sfc_POINT") |
      inherits(g, "sfc_MULTIPOINT")) type <- "pt"
  if (inherits(g, "LINESTRING") |
      inherits(g, "MULTILINESTRING") |
      inherits(g, "sfc_LINESTRING") |
      inherits(g, "sfc_MULTILINESTRING")) type <- "ln"
  if (inherits(g, "POLYGON") |
      inherits(g, "MULTIPOLYGON") |
      inherits(g, "sfc_POLYGON") |
      inherits(g, "sfc_MULTIPOLYGON")) type <- "pl"
  if (inherits(g, "sfc_GEOMETRY") |
      inherits(g, "sfc_GEOMETRYCOLLECTION")) type <- "gc" #getGeometryType(sf::st_cast(g))
  return(type)
}

### labels
makeLabels <- function(x, zcol = NULL) {
  if (inherits(x, "XY")) {
    lab <- "1"
  } else if (inherits(x, "sfc")) {
    lab <- as.character(seq(length(x)))
  } else if (inherits(x, "sf") & is.null(zcol)) {
    lab <- rownames(x)
  } else lab <- as.character(as.data.frame(x)[, zcol])
  return(lab)
}