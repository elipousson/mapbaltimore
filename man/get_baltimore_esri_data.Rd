% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_baltimore_esri_data.R
\name{get_baltimore_esri_data}
\alias{get_baltimore_esri_data}
\title{Get Baltimore data}
\usage{
get_baltimore_esri_data(area = NULL, nm = NULL, type = NULL, crs = NULL, ...)
}
\arguments{
\item{area}{Area (passed to location), Default: NULL}

\item{nm}{nm (should match a single value from baltimore_gis_index$nm), Default: NULL}

\item{type}{Type used as an alias for a nm value, Default: NULL}

\item{crs}{Coordinate reference system, Default: NULL}

\item{...}{
  Arguments passed on to \code{\link[getdata:get_esri_data]{getdata::get_esri_data}}
  \describe{
    \item{\code{url}}{FeatureServer or MapServer url to retrieve data from. Passed to
\code{url} parameter of \code{\link[esri2sf:esri2sf]{esri2sf::esri2sf()}} or \code{\link[esri2sf:esri2sf]{esri2sf::esri2df()}} functions.
For \code{\link[getdata:get_esri_layers]{get_esri_layers()}}, the optional url must be a service url which is
the base url for one or more layer urls.}
    \item{\code{location}}{\code{sf}, \code{sfc}, or \code{bbox} object (or other object convertible
with \code{\link[=as_bbox]{as_bbox()}}. Optional.}
    \item{\code{dist}}{buffer distance in units. Optional.}
    \item{\code{diag_ratio}}{ratio of diagonal distance of area's bounding box used as
buffer distance. e.g. if the diagonal distance is 3000 meters and the
"diag_ratio = 0.1"  a 300 meter will be used. Ignored when \code{dist} is
provided.}
    \item{\code{unit}}{Units for buffer. Supported options include "meter", "foot",
"kilometer", and "mile", "nautical mile" Common abbreviations (e.g. "km"
instead of "kilometer") are also supported. Distance in units is converted
to units matching GDAL units for x; defaults to "meter"}
    \item{\code{asp}}{Aspect ratio of width to height as a numeric value (e.g. 0.33) or
character (e.g. "1:3"). If numeric, \code{\link[sfext:get_asp]{get_asp()}} returns the same value
without modification.}
    \item{\code{where}}{where query string passed to esri2sf, Default: \code{NULL}}
    \item{\code{name,name_col}}{Name value and name column found in the ArcGIS
FeatureServer or MapServer data.}
    \item{\code{coords}}{Coordinate columns for input data.frame or output sf object (if
geometry is 'centroid' or 'point') Default: c("lon", "lat").}
    \item{\code{from_crs}}{For \code{\link[sfext:df_to_sf]{df_to_sf()}}, coordinate reference system used by
coordinates or well known text in data frame.}
    \item{\code{clean_names}}{If \code{TRUE}, set .name_repair to
\code{\link[janitor:make_clean_names]{janitor::make_clean_names()}} Ignored when \code{\link[getdata:get_esri_metadata]{get_esri_metadata()}} is not
returning a data.frame, e.g. \code{meta = "id"}.}
    \item{\code{token}}{string for authentication token. defaults to \code{NULL}.}
    \item{\code{progress}}{Show progress bar from \code{\link[cli:cli_progress_along]{cli::cli_progress_along()}} if \code{TRUE}.
Default \code{FALSE}.}
    \item{\code{quiet}}{If \code{TRUE}, use \code{\link[=suppressMessages]{suppressMessages()}} to prevent the printing of
messages about the requested layer. Defaults to \code{FALSE}.}
    \item{\code{.name_repair}}{Defaults to "check_unique"}
  }}
}
\value{
A dataframe or simple feature object
}
\description{
A wrapper for \code{\link[getdata:get_esri_data]{getdata::get_esri_data()}}
}
\seealso{
\code{\link[getdata:get_esri_data]{getdata::get_esri_data()}}
}
