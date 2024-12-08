% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{police_districts}
\alias{police_districts}
\title{Baltimore City Police Districts (1959-2022)}
\format{
A data frame with 9 rows and 3 variables:
\describe{
\item{\code{number}}{Police district number}
\item{\code{name}}{Police district name}
\item{\code{geometry}}{MULITPOLYGON geometry for district boundary}
}
}
\source{
\url{https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7}
}
\usage{
police_districts
}
\description{
Baltimore City Police Districts established in 1959 and used through 2022.
Note this data will be moved to a separate object for historic district
boundaries in 2023.
}
\keyword{datasets}
