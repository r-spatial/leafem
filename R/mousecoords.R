### addMouseCoordinates ######################################################
##############################################################################
#' Add mouse coordinate information at top of map.
#'
#' @description
#' This function adds a box displaying the current cursor location
#' (latitude, longitude and zoom level) at the top of a rendered
#' mapview or leaflet map. In case of mapview, this is automatically added.
#' NOTE: The information will only render once a mouse movement has happened
#' on the map.
#'
#' @param map a mapview or leaflet object.
#' @param epsg the epsg string to be shown.
#' @param proj4string the proj4string to be shown.
#' @param native.crs logical. whether to use the native crs in the coordinates box.
#'
#' @details
#' If style is set to "detailed", the following information will be displayed:
#' \itemize{
#'   \item x: x-position of the mouse cursor in projected coordinates
#'   \item y: y-position of the mouse cursor in projected coordinates
#'   \item epsg: the epsg code of the coordinate reference system of the map
#'   \item proj4: the proj4 definition of the coordinate reference system of the map
#'   \item lat: latitude position of the mouse cursor
#'   \item lon: longitude position of the mouse cursor
#'   \item zoom: the current zoom level
#' }
#'
#' By default, only 'lat', 'lon' and 'zoom' are shown. To show the details about
#' epsg, proj4 press and hold 'Ctrl' and move the mouse. 'Ctrl' + click will
#' copy the current contents of the box/strip at the top of the map to the clipboard,
#' though currently only copying of 'lon', 'lat' and 'zoom' are supported, not
#' 'epsg' and 'proj4' as these do not change with pan and zoom.
#'
#' @examples
#' library(leaflet)
#'
#' leaflet() %>%
#'   addProviderTiles("OpenStreetMap") # without mouse position info
#' m = leaflet() %>%
#'   addProviderTiles("OpenStreetMap") %>%
#'   addMouseCoordinates()
#'
#' m
#'
#' removeMouseCoordinates(m)
#'
#' @export addMouseCoordinates
#' @name addMouseCoordinates
#' @rdname addMouseCoordinates
#' @aliases addMouseCoordinates

addMouseCoordinates <- function(map,
                                epsg = NULL,
                                proj4string = NULL,
                                native.crs = FALSE) {

  if (inherits(map, "mapview")) map <- mapview2leaflet(map)
  stopifnot(inherits(map, c("leaflet", "leaflet_proxy")))

  if (native.crs) { # | map$x$options$crs$crsClass == "L.CRS.Simple") {
    txt_detailed <- paste0("
                           ' x: ' + (e.latlng.lng).toFixed(5) +
                           ' | y: ' + (e.latlng.lat).toFixed(5) +
                           ' | epsg: ", epsg, " ' +
                           ' | proj4: ", proj4string, " ' +
                           ' | zoom: ' + map.getZoom() + ' '")
  } else {
    txt_detailed <- paste0("
                           ' lon: ' + (e.latlng.lng).toFixed(5) +
                           ' | lat: ' + (e.latlng.lat).toFixed(5) +
                           ' | zoom: ' + map.getZoom() +
                           ' | x: ' + L.CRS.EPSG3857.project(e.latlng).x.toFixed(0) +
                           ' | y: ' + L.CRS.EPSG3857.project(e.latlng).y.toFixed(0) +
                           ' | epsg: 3857 ' +
                           ' | proj4: +proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs '")
  }

  txt_basic <- paste0("
                      ' lon: ' + (e.latlng.lng).toFixed(5) +
                      ' | lat: ' + (e.latlng.lat).toFixed(5) +
                      ' | zoom: ' + map.getZoom() + ' '")

  map$dependencies = c(
    map$dependencies,
    clipboardDependency()
  )

  map <- htmlwidgets::onRender(
    map,
    paste0(
      "
      function(el, x, data) {
      // get the leaflet map
      var map = this; //HTMLWidgets.find('#' + el.id);
      // we need a new div element because we have to handle
      // the mouseover output separately
      // debugger;
      function addElement () {
      // generate new div Element
      var newDiv = $(document.createElement('div'));
      // append at end of leaflet htmlwidget container
      $(el).append(newDiv);
      //provide ID and style
      newDiv.addClass('lnlt');
      newDiv.css({
      'position': 'relative',
      'bottomleft':  '0px',
      'background-color': 'rgba(255, 255, 255, 0.7)',
      'box-shadow': '0 0 2px #bbb',
      'background-clip': 'padding-box',
      'margin': '0',
      'padding-left': '5px',
      'color': '#333',
      'font': '9px/1.5 \"Helvetica Neue\", Arial, Helvetica, sans-serif',
      'z-index': '700',
      });
      return newDiv;
      }


      // check for already existing lnlt class to not duplicate
      var lnlt = $(el).find('.lnlt');

      if(!lnlt.length) {
      lnlt = addElement();

      // grab the special div we generated in the beginning
      // and put the mousmove output there

      map.on('mousemove', function (e) {
      if (e.originalEvent.ctrlKey) {
      if (document.querySelector('.lnlt') === null) lnlt = addElement();
      lnlt.text(", txt_detailed, ");
      } else {
      if (document.querySelector('.lnlt') === null) lnlt = addElement();
      lnlt.text(", txt_basic, ");
      }
      });

      // remove the lnlt div when mouse leaves map
      map.on('mouseout', function (e) {
      var strip = document.querySelector('.lnlt');
      strip.remove();
      });

      };

      //$(el).keypress(67, function(e) {
      map.on('preclick', function(e) {
      if (e.originalEvent.ctrlKey) {
      if (document.querySelector('.lnlt') === null) lnlt = addElement();
      lnlt.text(", txt_basic, ");
      var txt = document.querySelector('.lnlt').textContent;
      console.log(txt);
      //txt.innerText.focus();
      //txt.select();
      setClipboardText('\"' + txt + '\"');
      }
      });

      }
      "
    )
  )
  map
}

#' Remove mouse coordinates information at top of map.
#'
#' @describeIn addMouseCoordinates remove mouse coordinates information from a map
#' @aliases removeMouseCoordinates
#' @export removeMouseCoordinates
removeMouseCoordinates = function(map) {
  if (inherits(map, "mapview")) map = mapview2leaflet(map)

  rc = map$jsHooks$render
  rc_lnlt = grepl("lnlt", rc) #lapply(rc, grepl, pattern = "lnlt")
  map$jsHooks$render = map$jsHooks$render[!rc_lnlt]

  return(map)
}

#' convert mouse coordinates from clipboard to sfc
#'
#' @param x a charcter string with valid longitude and latitude values. Order
#'   matters! If missing and \code{clipboard = TRUE} (the default) contents
#'   will be read from the clipboard.
#' @param clipboard whether to read contents from the clipboard. Default is
#'   \code{TRUE}.
#'
#' @describeIn addMouseCoordinates convert mouse coordinates from clipboard to sfc
#' @aliases clip2sfc
#' @export clip2sfc
clip2sfc = function(x, clipboard = TRUE) {
  if (clipboard) {
    if (!requireNamespace("clipr"))
      stop("\nplease install.packages('clipr') to enable reading from clipboard")
    lns = clipr::read_clip()
    splt = strsplit(lns, " ")[[1]]
    lnlt = regmatches(splt, regexpr("([0-9]+.[0-9]+)", splt))
    x = as.numeric(lnlt[1])
    y = as.numeric(lnlt[2])
    sf::st_sfc(sf::st_point(c(x, y)), crs = 4326)
  } else {
    if (missing(x)) stop("\nneed some text or 'clipboard = TRUE'", call. = FALSE)
    splt = strsplit(x, " ")[[1]]
    lnlt = regmatches(splt, regexpr("([0-9]+.[0-9]+)", splt))
    x = as.numeric(lnlt[1])
    y = as.numeric(lnlt[2])
    sf::st_sfc(sf::st_point(c(x, y)), crs = 4326)
  }
}



##############################################################################
