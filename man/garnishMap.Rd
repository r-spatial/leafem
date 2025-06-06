% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/garnish.R
\name{garnishMap}
\alias{garnishMap}
\title{Garnish/decorate leaflet or mapview maps.}
\usage{
garnishMap(map, ...)
}
\arguments{
\item{map}{a mapview or leaflet object.}

\item{...}{functions and their arguments to add things to a map.}
}
\description{
This function provides a versatile interface to add components to a
leaflet or mapview map. It takes functions such as "addMouseCoordinates"
or \code{\link[leaflet]{addLayersControl}} and their respective arguments and adds
them to the map. Arguments must be named. Functions can be plain or
character strings.
}
\examples{
library(leaflet)

m <- leaflet() \%>\% addProviderTiles("OpenStreetMap")
garnishMap(m, addMouseCoordinates)

## add more than one with named argument
library(leaflet)

m1 <- garnishMap(m, addScaleBar, addMouseCoordinates,
                 position = "bottomleft")
m1

}
