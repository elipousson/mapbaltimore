% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_area_crashes.R
\name{get_area_crashes}
\alias{get_area_crashes}
\title{Get vehicle crashes for area in Baltimore from Maryland Open Data portal}
\usage{
get_area_crashes(
  area,
  start_year = 2020,
  end_year = 2020,
  geometry = FALSE,
  trim = FALSE,
  type = c("crash", "person", "vehicle")
)
}
\arguments{
\item{area}{\code{sf} object.}

\item{start_year}{earliest year of crash data to return. Default 2020.}

\item{end_year}{latest year of crash data to return. If \code{end_year} is
not provided, only a single year is returned. Default 2020.}

\item{geometry}{If TRUE, return a sf object. Default FALSE.}

\item{trim}{If TRUE, data trimmed to area with
\code{\link[sf:geos_binary_ops]{sf::st_intersection()}}. Default FALSE.}

\item{type}{Data type to return. Options include c("crash", "person",
"vehicle"). Data types correspond to different tables. If 'person', an age
at crash column is added based on the accident date and date of birth
columns (after removing suspected placeholder values).}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#deprecated}{\figure{lifecycle-deprecated.svg}{options: alt='[Deprecated]'}}}{\strong{[Deprecated]}}

This function is deprecated because the functionality has been incorporated
into the improved \code{\link[mapmaryland:get_md_crash_data]{mapmaryland::get_md_crash_data()}} function which uses a similar set
of parameters.

Get vehicle crashes for selected area in Baltimore City.
}
\keyword{internal}
