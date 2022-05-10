#' Garnish/decorate leaflet or mapview maps.
#'
#' @description
#' This function provides a versatile interface to add components to a
#' leaflet or mapview map. It takes functions such as "addMouseCoordinates"
#' or \code{\link{addLayersControl}} and their respective arguments and adds
#' them to the map. Arguments must be named. Functions can be plain or
#' character strings.
#'
#' @param map a mapview or leaflet object.
#' @param ... functions and their arguments to add things to a map.
#'
#' @examples
#' library(leaflet)
#'
#' m <- leaflet() %>% addProviderTiles("OpenStreetMap")
#' garnishMap(m, addMouseCoordinates)
#'
#' ## add more than one with named argument
#' library(leaflet)
#'
#' m1 <- garnishMap(m, addScaleBar, addMouseCoordinates,
#'                  position = "bottomleft")
#' m1
#'
#' @export garnishMap
#' @name garnishMap
#' @rdname garnishMap
#' @aliases garnishMap
garnishMap <- function(map, ...) {

  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy", "mapdeck")))

  ls = list(...)

  funs <- sapply(ls, is.function)

  if (all(sapply(ls, is.null)) && all(sapply(funs, is.null))) {
    return(map)
  }

  fn_lst <- lapply(ls[funs], function(i) {
    tst <- try(match.fun(i), silent = TRUE)
    if (inherits(tst, "try-error")) tst <- NULL
    return(tst)
  })
  fn_lst <- fn_lst[!sapply(fn_lst, is.null)]

  for (i in fn_lst) {
    args_i = try(
      match.arg(c("map", names(ls)), names(as.list(i)), several.ok = TRUE)
      , silent = TRUE
    )
    if (!inherits(args_i, "try-error")) {
      if (!"map" %in% names(as.list(i))) {
        next
      }
      args_lst = ls[args_i][!(is.na(names(ls[args_i])))]
      maptry = tryCatch(
        do.call(i, append(list(map = map), args_lst))
        , error = function(e) { e }
      )
      if (inherits(maptry, "error")) {
        stop(maptry$message, call. = FALSE)
      } else {
        map = maptry
      }
    }
  }
  return(map)
}


### decorateMap lets you pass lists of functions with respective lists of
### named lists of arguments as in
### decorateMap(map, list(addCircleMarkers), list(list(data = breweries91)))
decorateMap <- function(map, funs, args) {
  for (i in seq(funs)) {
    map <- do.call("garnishMap", c(list(map), funs[[i]], args))
  }
  return(map)
}

