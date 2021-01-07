
# mapbaltimore

<!-- badges: start -->
<!-- badges: end -->

The goal of the mapbaltimore package is to provide an easy way to create
maps of Baltimore neighborhoods using open data on demographics,
transportation, housing, and public safety.

## Installation

You can install this development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
remotes::install_github("elipousson/mapbaltimore")
```

## Examples

The mapbaltimore package includes utility functions to a neighborhood or
other area type and mapping functions to create common planning maps
such as this context map for downtown Baltimore.

``` r
library(sf)
```

    ## Linking to GEOS 3.8.1, GDAL 3.1.4, PROJ 6.3.1

``` r
library(mapbaltimore)

downtown <- get_area(type = "neighborhood",
                     area_name = "Downtown")

map_area_in_city(area = downtown) +
  ggplot2::labs(title = "Downtown Baltimore")
```

![](README_files/figure-gfm/downtown-1.png)<!-- -->

Or this map of parks in and around downtown Baltimore.

``` r
map_area_parks(area = downtown) +
  ggplot2::labs(title = "Parks in Downtown Baltimore")
```

![](README_files/figure-gfm/parks-1.png)<!-- -->

Or this map highlighting different neighborhoods around downtown
Baltimore.

``` r
around_downtown <- get_nearby_areas(area = downtown,
                                    type = "neighborhood")

map_area_highlighted(area = around_downtown) +
  ggplot2::labs(title = "Neighborhoods around Downtown Baltimore")
```

![](README_files/figure-gfm/areas_highlighted-1.png)<!-- -->

The package includes several functions for accessing data on Open
Baltimore. However, as of December 31, 2020, Baltimore City has shut
down the Socrata-based Open Baltimore data portal and replaced it with a
ArcGIS data catalog. Consequently, these functions are not currently
working.
