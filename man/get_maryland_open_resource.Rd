% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_maryland_open_resource.R
\name{get_maryland_open_resource}
\alias{get_maryland_open_resource}
\title{Get dataset from Maryland Open Data portal with optional SoQL parameters}
\usage{
get_maryland_open_resource(
  resource = NULL,
  select = NULL,
  where = NULL,
  query = NULL,
  geometry = FALSE,
  crs = 2804
)
}
\arguments{
\item{resource}{Socrata dataset identifier for selected dataset from Maryland's Open Data portal}

\item{select}{SODA $select parameter. Set of columns to be returned, similar to a SELECT in SQL. \url{https://dev.socrata.com/docs/queries/select.html}}

\item{where}{SODA $where parameter. Filters the rows to be returned, similar to WHERE. \url{https://dev.socrata.com/docs/queries/where.html}}

\item{query}{SODA $query parameter. A full SoQL query string, all as one parameter. \url{https://dev.socrata.com/docs/queries/query.html}}

\item{geometry}{If TRUE and latitude/longitude columns available, return a \code{\link{sf}} object. Default FALSE.}

\item{crs}{Coordinate reference system to return.}
}
\description{
Get a selected dataset using Socrata Query Language (SoQL) parameters as a tibble or sf object.
Details on SoQL queries are found in the Socrata API documentation \url{https://dev.socrata.com/docs/queries/}
}
\examples{

\dontrun{
## Get Q2 2020 vehicle crash data for Cecil County, Maryland
get_maryland_open_resource(
  resource = "65du-s3qu",
  where = "(year = '2020') AND (quarter = 'Q2') AND county_desc like 'Cecil'"
)
}
}
