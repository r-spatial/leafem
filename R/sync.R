#' View two or more (possibly synchronised) mapview or leaflet maps
#'
#' @description
#' This function produces a lattice like view of two or more maps. It is possible to sync
#' any combination of panels or all or none. For synchronising all panels it
#' is best to use the provided convenience function \code{sync}.
#'
#' @param ... any number of mapview or leaflet objects or a list thereof
#' @param ncol how many columns should be plotted
#' @param full.height \code{logical}; should the produced lattice view be
#'   scaled to the complete height of the viewer (or browser); default to \code{TRUE}.
#'   If \code{FALSE}, the height of each panel falls back to the default
#'   sizing policy height of leaflet (400px).
#' @param sync whether to synchronise zoom and pan for certain elements.
#'   Possible values are "all" (default) to sync all maps, "none" to disable
#'   synchronisation or a list of panel numbers, e.g. \code{list(c(1, 3), c(2, 4))}
#'   will synchronise panels 1 & 3 and panels 2 & 4. Panels are drawn from top right
#'   to bottom left.
#' @param sync.cursor whether to show cursor position in synced panels (default TRUE).
#' @param no.initial.sync whether to sync the initial view (default TRUE).
#'
#' @examples
#' if (interactive()) {
#' library(leaflet)
#' library(leafsync)
#'
#' m1 = leaflet() %>%
#'   addTiles() %>%
#'   addPolygons(data = gadmCHE)
#'
#' m2 = leaflet() %>%
#'   addProviderTiles("Esri.WorldImagery") %>%
#'   addCircleMarkers(data = breweries91,
#'                    color = "black",
#'                    opacity = 0.9,
#'                    fillColor = "white",
#'                    fillOpacity = 0.9)
#'
#' # synced
#' sync(m1, m2)
#' sync(m1, m2, no.initial.sync = TRUE)
#'
#' # not synced
#' latticeview(m1, m2)
#' latticeview(m1, m2, ncol = 1)
#' }
#'
#' @export latticeView
#' @name latticeView
#' @aliases latticeView
#'

latticeView <- function(...,
                        ncol = 2,
                        full.height = TRUE,
                        sync = "none",
                        sync.cursor = FALSE,
                        no.initial.sync = TRUE) {

  ## convert all ... objects to list or extract list if list was passed
  ls <- list(...)
  if (length(ls) == 1) ls <- ls[[1]]

  for (i in seq(ls)) {
    # convert each list element to class leaflet (if necessary)
    if (inherits(ls[[i]], "mapview")) ls[[i]] <- mapview2leaflet(ls[[i]])
    if (length(ls[[i]]$dependencies) == 0) {
      ls[[i]]$dependencies = list()
    }

    # modify the sizingPolicy for full screen heights
    if (full.height == TRUE) {
      nrow = round(length(ls) / ncol, 0)
      hght = 100 / nrow - 1
      ls[[i]]$sizingPolicy$defaultHeight = paste0(hght, "vh")
    }

    #ls[[i]]$dependencies[[length(ls[[i]]$dependencies) + 1]] <- sync_dep
    # give a "unique" id to each leaflet map for lookup
    if (is.null(ls[[i]]$elementId)) {
      # use unique same id generator as htmlwidgets
      #  https://github.com/ramnathv/htmlwidgets/blob/master/R/htmlwidgets.R#L165
      ls[[i]]$elementId <- paste("htmlwidget", as.integer(stats::runif(1, 1, 10000)), sep = "-")
    }
  }

  ## calculate div width depending on ncol and set div style
  wdth <- paste0("width:", round(1 / ncol * 100, 0) - 1, "%;")
  styl <- paste0("display:inline;",
                 wdth,
                 "float:left;border-style:solid;border-color:#BEBEBE;border-width:1px 1px 1px 1px;")

  ## htmltools stuff ... ?
  tg <- lapply(seq(ls), function(i) {
    htmltools::tags$div(style = styl, ls[[i]])
  })

  ## string operations for syncing, depending on sync argument
  ## initialize sync_string as empty
  sync_strng <- ""
  if (!is.list(sync) && sync == "all") {
    sync = list(seq(ls))
  }
  if (is.list(sync)) {
    for (i in seq(sync)) {
      synci <- sync[[i]]
      sync_grid <- expand.grid(synci,synci,KEEP.OUT.ATTRS = FALSE)
      sync_strng <- c(sync_strng,apply(
        sync_grid,
        MARGIN = 1,
        function(combo){
          # don't sync to self
          if (combo[1] != combo[2]) {
            return(sprintf(
              "leaf_widgets['%s'].sync(leaf_widgets['%s'],{syncCursor: %s, noInitialSync: %s});",
              ls[[combo[1]]]$elementId,
              ls[[combo[2]]]$elementId,
              tolower(as.logical(sync.cursor)),
              tolower(as.logical(no.initial.sync))
            ))
          }
          return("")
        }
      ))
    }
  }
  sync_strng <- paste0(sync_strng, collapse = "\n")

  tl <- htmltools::attachDependencies(
    htmltools::tagList(
      tg,
      htmlwidgets::onStaticRenderComplete(
        paste0('var leaf_widgets = {};
                Array.prototype.map.call(
                 document.querySelectorAll(".leaflet"),
                   function(ldiv){
                     if (HTMLWidgets.find("#" + ldiv.id) && HTMLWidgets.find("#" + ldiv.id).getMap()) {
                        leaf_widgets[ldiv.id] = HTMLWidgets.find("#" + ldiv.id).getMap();
                     }
                   }
                );
               ',
               sync_strng
        )
      )
    ),
    dependencyLeafletsync()
  )

  return(htmltools::browsable(tl))
}

#' @describeIn latticeView alias for ease of typing
#' @aliases latticeview
#' @export latticeview
latticeview <- function(...) latticeView(...)

#' @describeIn latticeView convenience function for syncing maps
#' @aliases sync
#' @export sync
sync <- function(...,
                 ncol = 2,
                 full.height = TRUE,
                 sync = "all",
                 sync.cursor = TRUE,
                 no.initial.sync = TRUE) {

  latticeView(...,
              ncol = ncol,
              full.height = full.height,
              sync = sync,
              sync.cursor = sync.cursor,
              no.initial.sync = no.initial.sync)

}


# Reduce(paste0, sapply(seq(ls), function(i) {
#   first <-  do.call(c, lapply(seq(ls), function(j) {
#     paste0("leaf_widgets[", j - 1, "]")
#   }))
#   paste0(first, ".sync(leaf_widgets[", i - 1, "]);")
# }))


# ## more htmltools stuff... ??
# tl <- htmltools::tagList(
#   # htmltools::tags$head(htmltools::tags$script(
#   #   type="text/javascript",
#   #   src="https://cdn.rawgit.com/turban/Leaflet.Sync/master/L.Map.Sync.js"
#   # )),
#   tg,
#   htmlwidgets::onStaticRenderComplete(
#     paste0('var leaf_widgets = Array.prototype.map.call(
#       document.querySelectorAll(".leaflet"),
#         function(ldiv){
#           return HTMLWidgets.find("#" + ldiv.id).getMap();
#         }
#       );',
#            sync_strng
#     )
#   )
# )


# htmltools::tags$head(htmltools::tags$script(
#   type="text/javascript",
#   src="https://cdn.rawgit.com/turban/Leaflet.Sync/master/L.Map.Sync.js"
# )),


# Provide Leaflet.sync Dependency
dependencyLeafletsync <- function(){
  htmltools::htmlDependency(
    name = "Leaflet.Sync"
    ,version = "0.0.5"
    ,src = c(file = system.file("htmlwidgets/lib/Leaflet.Sync",
                                package = "leafsync"))
    ,script = "L.Map.Sync.js"
  )
}
