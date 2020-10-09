
# mapbaltimore <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

<!-- badges: end -->

The goal of the mapbaltimore package is to provide an easy way to create
maps of Baltimore neighborhoods using open data on demographics,
transportation, housing, and public safety.

Current functions include:

  - map\_neighborhood\_in\_city
  - map\_zoning
  - map\_bcps\_zone
  - map\_tenure
  - map\_decade\_built

Current data sources include:

  - Baltimore City generalized boundary
  - Baltimore City neighborhood boundaries
  - Real property data for parcels in Baltimore City
  - Baltimore City parks
  - Baltimore City zoning code
  - Maryland Transit Authority bus lines (statewide)

## Installation

You can install this development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("elipousson/mapbaltimore")
```

## Examples

``` r
library(mapbaltimore)
```
