
<!-- README.md is generated from README.Rmd. Please edit that file -->

# leafem - leaflet extensions for mapview

<!-- badges: start -->

[![R-CMD-check](https://github.com/r-spatial/leafem/workflows/R-CMD-check/badge.svg)](https://github.com/r-spatial/leafem/actions)
[![cran
checks](https://badges.cranchecks.info/worst/dplyr.svg)](https://cran.r-project.org/web/checks/check_results_leafem.html)
![monthly](http://cranlogs.r-pkg.org/badges/leafem)
![total](http://cranlogs.r-pkg.org/badges/grand-total/leafem)
[![CRAN](http://www.r-pkg.org/badges/version/leafem?color=009999)](https://cran.r-project.org/package=leafem)
[![status](https://tinyverse.netlify.com/badge/leafem)](https://CRAN.R-project.org/package=leafem)
<!-- badges: end -->

`leafem` provides extensions for package `leaflet` many of which are
used by package `mapview`. The intention of this package is to enhance
`leaflet` functionality to provide a more GIS-like feeling when plotting
spatial data interactively.

## Installation

You can install the released version of leafem from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("leafem")
```

## Extensions

#### addFeatures

``` r
library(leaflet)

leaflet() %>% addProviderTiles("OpenStreetMap") %>% addFeatures(data = breweries91)
```

![](man/figures/README-features.png)

#### addMouseCoordinates

``` r
leaflet() %>%
  addProviderTiles("OpenStreetMap") %>%
  addMouseCoordinates()
```

![](man/figures/README-garnish.png)

#### garnishMap

``` r
library(leaflet)

m <- leaflet() %>% addProviderTiles("OpenStreetMap")
garnishMap(m, addMouseCoordinates)
```

![](man/figures/README-garnish.png)

#### addHomeButton

``` r
library(leaflet)
library(raster)

m <- leaflet() %>%
  addProviderTiles("OpenStreetMap") %>%
  addCircleMarkers(data = breweries91) %>%
  addHomeButton(extent(breweries91), "breweries91")
m
```

![](man/figures/README-home.png)

#### addImageQuery

``` r
library(leaflet)
library(plainview)

leaflet() %>%
  addProviderTiles("OpenStreetMap") %>%
  addRasterImage(poppendorf[[1]], project = TRUE, group = "poppendorf",
                 layerId = "poppendorf") %>%
  addImageQuery(poppendorf[[1]], project = TRUE,
                layerId = "poppendorf") %>%
  addLayersControl(overlayGroups = "poppendorf")
```

![](man/figures/README-query.png)

#### addLogo

``` r
img <- "https://www.r-project.org/logo/Rlogo.svg"

leaflet() %>% addTiles() %>% addLogo(img, url = "https://www.r-project.org/logo/")
```

![](man/figures/README-logo.png)

### Code of Conduct

Please note that the ‘leafem’ project is released with a [Contributor
Code of
Conduct](https://github.com/r-spatial/leafem/blob/master/CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.
