% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/filter_streets.R
\name{filter_streets}
\alias{filter_streets}
\title{Filter streets}
\usage{
filter_streets(
  x,
  sha_class = NULL,
  street_type = NULL,
  block_num = NULL,
  union = FALSE,
  bbox = NULL,
  call = caller_env()
)
}
\arguments{
\item{x}{sf object with streets to filter}

\item{sha_class}{selected SHA classifications to include. "all" selects all
streets with an assigned SHA classification (around one-quarter of all
street segments). Additional options include c("COLL", "LOC", "MART",
"PART", "FWY", "INT")}

\item{street_type}{selected street subtypes to include. By default, the
returned data includes all subtypes except alleys ("STRALY"). Options
include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR",
"STRURD", "STCLN", "STRTN"). Not supported for}

\item{block_num}{Integer vector with block number, e.g. 300, or range of
block numbers (e.g. \code{c(100, 500)}) to filter streets.}

\item{union}{Logical. Default \code{TRUE}. Union geometry based on \code{fullname} of
streets.}

\item{bbox}{Bounding box to filter passed to location parameter of
\code{\link[getdata:get_location_data]{getdata::get_location_data()}}.}

\item{call}{The execution environment of a currently
running function, e.g. \code{caller_env()}. The function will be
mentioned in error messages as the source of the error. See the
\code{call} argument of \code{\link[rlang:abort]{abort()}} for more information.}
}
\value{
streets filtered by parameters
}
\description{
Internal function for filtering streets by multiple parameters
}
