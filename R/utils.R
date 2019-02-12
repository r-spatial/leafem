### mapview to leaflet
#' @importFrom methods slot
mapview2leaflet <- function(x) {
  methods::slot(x, "map")
}
