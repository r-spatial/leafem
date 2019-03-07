
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leafsync - (Synced) small multiples of leaflet maps

[![CRAN
status](https://www.r-pkg.org/badges/version/leafsync)](https://cran.r-project.org/package=leafsync)
[![Travis build
status](https://travis-ci.org/r-spatial/leafsync.svg?branch=master)](https://travis-ci.org/r-spatial/leafsync)
[![monthly](http://cranlogs.r-pkg.org/badges/leafsync)](https://www.rpackages.io/package/leafsync)
[![total](http://cranlogs.r-pkg.org/badges/grand-total/leafsync)](https://www.rpackages.io/package/leafsync)
[![CRAN](http://www.r-pkg.org/badges/version/leafsync?color=009999)](https://cran.r-project.org/package=leafsync)

`leafsync` is a plugin for
[`leaflet`](https://github.com/rstudio/leaflet) to produce potentially
synchronised small multiples of leaflet web maps wrapping
[`Leaflet.Sync`](https://github.com/jieter/Leaflet.Sync).

## Installation

You can install the released version of leafsync from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("leafsync")
```

## Example

``` r
library(sp)
library(raster)
library(mapview)

data(meuse)
coordinates(meuse) <- ~x+y
proj4string(meuse) <- CRS("+init=epsg:28992")

## view different aspects of same data set
m1 <- mapview(meuse, zcol = "soil", burst = TRUE)
m2 <- mapview(meuse, zcol = "lead")
m3 <- mapview(meuse, zcol = "landuse", map.types = "Esri.WorldImagery")
m4 <- mapview(meuse, zcol = "dist.m")

sync(m1, m2, m3, m4) # 4 panels synchronised
```

![](man/figures/README-sync.png)

### Code of Conduct

Please note that the ‘leafsync’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.
