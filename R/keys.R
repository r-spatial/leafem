#' Copy current view extent to the clipboard
#'
#' @description
#' Add JavaScript functioality to enable copying of the current view bouding box
#' to the clipboard. The \code{copy.btn} argument expects a valid keycode
#' \code{event.code} such as "KeyE" (the default). Use \url{https://keycode.info/}
#' to find the approprate codes for your keyboard.
#'
#' @param map a mapview or leaflet object.
#' @param event.code the JavaScript event.code for ley strokes.
#'
#' @examples
#'   library(leaflet)
#'
#'   leaflet() %>%
#'   addProviderTiles("CartoDB.Positron") %>%
#'     addCopyExtent(event.code = "KeyE") %>%
#'     addMouseCoordinates()
#'
#'   # now click on the map (!) and zoom to anwhere in the map, then press 'e' on
#'   # your keyboard. This will copy the current extent/bounding box as a JSON object
#'   # to your clipboard which can then be parsed with:
#'
#'   # jsonlite::fromJSON(<Ctrl+v>)
#'
#' @export addCopyExtent
#' @name addCopyExtent
#' @rdname addCopyExtent
#' @aliases addCopyExtent
addCopyExtent = function(map, event.code = "KeyE") {

  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  map$dependencies = c(
    map$dependencies,
    clipboardDependency()
  )

  htmlwidgets::onRender(
    map,
    htmlwidgets::JS(
      paste0(
        "function(el,x,data){
           var map = this;

           map.on('keypress', function(e) {
               console.log(e.originalEvent.code);
               var key = e.originalEvent.code;
               if (key === '", event.code, "') {
                   var bb = this.getBounds();
                   var txt = JSON.stringify(bb);
                   console.log(txt);

                   setClipboardText('\\'' + txt + '\\'');
               }
           })
        }"
      )
    )
  )
}

## clipboard dependency used in addCopyExtent and addMouseCoordinates
clipboardDependency = function() {
  list(
    htmltools::htmlDependency(
      name = "clipboard",
      version = "0.0.1",
      src = system.file("htmlwidgets/lib/clipboard", package = "leafem"),
      script = "setClipboardText.js"
    )
  )
}
