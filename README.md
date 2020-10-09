
# mapbaltimore

<!-- badges: start -->
<!-- badges: end -->

The goal of the mapbaltimore package is to provide an easy way to create maps of Baltimore neighborhoods using open data on demographics, transportation, housing, and public safety. Current functions include:

- map_neighborhood_in_city
- map_zoning
- map_bcps_zone
- map_tenure
- map_decade_built

## Installation

``` r
# Install the development version from GitHub:
# install.packages("devtools")
devtools::install_github("elipousson/mapbaltimore")
```

## Example


``` r
library(mapbaltimore)
## basic example code

# Map occupancy and tenure in the Harwood neighborhood
map_tenure("Harwood")
```

