% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/keys.R
\name{addCopyExtent}
\alias{addCopyExtent}
\title{Copy current view extent to the clipboard}
\usage{
addCopyExtent(map, event.code = "KeyE")
}
\arguments{
\item{map}{a mapview or leaflet object.}

\item{event.code}{the JavaScript event.code for ley strokes.}
}
\description{
Add JavaScript functioality to enable copying of the current view bouding box
to the clipboard. The \code{copy.btn} argument expects a valid keycode
\code{event.code} such as "KeyE" (the default).
Use \url{https://www.toptal.com/developers/keycode} to find the
approprate codes for your keyboard.
}
\examples{
  library(leaflet)

  leaflet() \%>\%
  addProviderTiles("CartoDB.Positron") \%>\%
    addCopyExtent(event.code = "KeyE") \%>\%
    addMouseCoordinates()

  # now click on the map (!) and zoom to anywhere in the map, then press 'e' on
  # your keyboard. This will copy the current extent/bounding box as a JSON object
  # to your clipboard which can then be parsed with:

  # jsonlite::fromJSON(<Ctrl+v>)

}
