% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/addGeoRaster.R
\name{addGeoRaster}
\alias{addGeoRaster}
\title{Add stars/raster image to a leaflet map using optimised rendering.}
\usage{
addGeoRaster(
  map,
  x,
  group = NULL,
  layerId = NULL,
  resolution = 96,
  opacity = 0.8,
  options = leaflet::tileOptions(),
  colorOptions = NULL,
  project = TRUE,
  pixelValuesToColorFn = NULL,
  autozoom = TRUE,
  ...
)
}
\arguments{
\item{map}{the map to add the raster data to.}

\item{x}{the stars/raster object to be rendered.}

\item{group}{the name of the group this raster image should belong to.}

\item{layerId}{the layerId.}

\item{resolution}{the target resolution for the simple nearest neighbor interpolation.
Larger values will result in more detailed rendering, but may impact performance.
Default is 96 (pixels).}

\item{opacity}{opacity of the rendered layer.}

\item{options}{options to be passed to the layer.
See \code{\link[leaflet]{tileOptions}} for details.}

\item{colorOptions}{list defining the palette, breaks and na.color to be used.}

\item{project}{whether to project the RasterLayer to conform with leaflets
expected crs. Defaults to \code{TRUE} and things are likely to go haywire
if set to \code{FALSE}.}

\item{pixelValuesToColorFn}{optional JS function to be passed to the browser.
Can be used to fine tune and manipulate the color mapping.
See \url{https://github.com/r-spatial/leafem/issues/25} for some examples.}

\item{autozoom}{whether to automatically zoom to the full extent of the layer.
Default is \code{TRUE}}

\item{...}{Further arguments passed to \code{\link[leafem]{addGeotiff}}.}
}
\value{
A leaflet map object.
}
\description{
Add stars/raster image to a leaflet map using optimised rendering.
}
\details{
This uses the leaflet plugin 'georaster-layer-for-leaflet' to render raster data.
See \url{https://github.com/GeoTIFF/georaster-layer-for-leaflet} for details.
The clue is that rendering uses simple nearest neighbor interpolation on-the-fly
to ensure smooth rendering. This enables handling of larger rasters than with
the standard \code{\link[leaflet]{addRasterImage}}.
}
\examples{
if (interactive()) {
  library(leaflet)
  library(leafem)
  library(stars)

  tif = system.file("tif/L7_ETMs.tif", package = "stars")
  x1 = read_stars(tif)
  x1 = x1[, , , 3] # band 3

  leaflet() \%>\%
    addTiles() \%>\%
    leafem:::addGeoRaster(
      x1
      , opacity = 1
      , colorOptions = colorOptions(
        palette = grey.colors(256)
      )
    )
}

}
