% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{baltimore_city}
\alias{baltimore_city}
\title{Generalized political boundary for Baltimore City}
\format{
A data frame with 1 row and 3 variables:
\describe{
  \item{\code{name}}{County name}
  \item{\code{countyfp}}{3-character county FIPS code}
  \item{\code{geoid}}{Current county identifier; a concatenation of current state FIPS code and county FIPS code}
  \item{\code{aland}}{Current land area (square meters)}
  \item{\code{awater}}{Current water area (square meters)}
  \item{\code{intptlat}}{Current latitude of the internal point}
  \item{\code{intptlon}}{Current longitude of the internal point}
  \item{\code{geometry}}{Multipolygon with the boundary}
}
}
\source{
\url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
}
\usage{
baltimore_city
}
\description{
A generalized boundary for Baltimore City, Maryland
from statewide dataset of generalized county boundaries.
}
\keyword{datasets}
