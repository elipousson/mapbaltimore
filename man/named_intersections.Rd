% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{named_intersections}
\alias{named_intersections}
\title{Baltimore City Street Intersection Names}
\format{
A data frame with 11506 rows and 3 variables:
\describe{
\item{\code{id}}{Intersection identifier matching id in \code{edge_of_pavement} data}
\item{\code{name}}{Intersection name}
\item{\code{geometry}}{POINT geometry for intersection center}
}
}
\usage{
named_intersections
}
\description{
Index of Baltimore City intersections using names from street centerlines
within 20 meters of the intersection boundaries. Data supports the for
\code{\link[=get_intersection]{get_intersection()}} function. Updated 2022 October 13.
}
\keyword{datasets}
