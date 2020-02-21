### addStaticLabels ##########################################################
##############################################################################
#' Add static labels to \code{leaflet} or \code{mapview} objects
#'
#' @description
#' Being a wrapper around \code{\link[leaflet]{addLabelOnlyMarkers}}, this
#' function provides a smart-and-easy solution to add custom text labels to an
#' existing \code{leaflet} or \code{mapview} map object.
#'
#' @param map A \code{leaflet} or \code{mapview} object.
#' @param data A \code{sf} or \code{Spatial*} object used for label placement,
#' defaults to the locations of the first dataset in 'map'.
#' @param label The labels to be placed at the positions indicated by 'data' as
#' \code{character}, or any vector that can be coerced to this type.
#' @param group the group of the static labels layer.
#' @param layerId the layerId of the static labels layer.
#' @param ... Additional arguments passed to
#' \code{\link[leaflet]{labelOptions}}.
#'
#' @return
#' A labelled \strong{leaflet} map
#'
#' @author
#' Florian Detsch, Lorenzo Busetto
#'
#' @seealso
#' \code{\link[leaflet]{addLabelOnlyMarkers}}.
#'
#' @examples
#' \dontrun{
#' ## leaflet label display options
#' library(leaflet)
#'
#' lopt = labelOptions(noHide = TRUE,
#'                     direction = 'top',
#'                     textOnly = TRUE)
#'
#' ## Add labels on a Leaflet map
#'
#' indata <- sf::st_read(system.file("shape/nc.shp", package="sf"))
#'
#' leaflet(indata) %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addFeatures(.) %>%
#'   addStaticLabels(., label = indata$NAME)
#'
#' Modify styling -
#'
#' leaflet(indata) %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addFeatures(.) %>%
#'   addStaticLabels(., label = indata$NAME,
#'                     style = list("color" = "red", "font-weight" = "bold"))
#'
#' }
#'
#' @export addStaticLabels
#' @name addStaticLabels
addStaticLabels = function(map,
                           data,
                           label,
                           group = NULL,
                           layerId = NULL,
                           ...) {

  stopifnot(inherits(map, c("leaflet", "leaflet_proxy", "mapview")))

  if (inherits(map, "mapview")) {
    if (missing(data)) {
      data = map@object[[1]]
      if (is.null(group)) {
        group = getLayerNamesFromMap(map@map)[1]
      } else {
        group = NULL
      }
    } else {
      data = sf::st_transform(data, sf::st_crs(map@object[[1]]))
    }
  }

  if (inherits(map, c("leaflet", "leaflet_proxy"))) {
    if (missing(data)) {
      data = attributes(map[["x"]])[["leafletData"]]
    }
    # data = checkAdjustProjection(data)
  }

  if (is.null(data)) stop("argument \"data\" is missing, with no default")

  dots = list(...)
  min_opts = list(permanent = TRUE,
                  direction = "top",
                  textOnly = TRUE,
                  offset = c(0, 20))

  dots = utils::modifyList(min_opts, dots)
  # dots = utils::modifyList(leafletOptions(), dots)

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  ## 'Raster*' locations not supported so far -> error
  if (inherits(data, "Raster")) {
    stop(paste("'Raster*' input is not supported, yet."
               , "Please refer to ?addStaticLabels for compatible input formats.\n"),
         call. = FALSE)
  }

  ## if input is 'Spatial*', convert to 'sf'
  if (inherits(data, "Spatial")) {
    data = sf::st_as_sf(data)
  }

  if (missing(label)) label = makeLabels(data, NULL)
  #   {
  #   sf_col = attr(data, "sf_column")
  #   if (inherits(data, "sf")) {
  #     if (ncol(data) == 2) {
  #       colnm = setdiff(colnames(data), sf_col)
  #       label = data[[colnm]]
  #     } else {
  #       label = seq(nrow(data))
  #     }
  #   } else {
  #     label = seq(length(data))
  #   }
  # }

  if (getGeometryType(data) == "ln") {
    crds = as.data.frame(sf::st_coordinates(data))
    crds_lst = split(crds, crds[[ncol(crds)]])
    mat = do.call(rbind, lapply(seq(crds_lst), function(i) {
      crds_lst[[i]][sapply(crds_lst, nrow)[i], c("X", "Y")]
    }))
  } else {
    mat = sf::st_coordinates(suppressWarnings(sf::st_centroid(data)))
  }

  ## add labels to map
  # map = garnishMap(leaflet::addLabelOnlyMarkers,
  #                  map = map,
  #                  lng = unname(mat[, 1]),
  #                  lat = unname(mat[, 2]),
  #                  label = as.character(label),
  #                  group = group,
  #                  layerId = layerId,
  #                  labelOptions = dots)
  map = leaflet::addLabelOnlyMarkers(map,
                                     lng = mat[, 1],
                                     lat = mat[, 2],
                                     label = as.character(label),
                                     group = group,
                                     layerId = layerId,
                                     labelOptions = dots)

  return(map)
}