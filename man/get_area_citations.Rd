% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_area_citations.R
\name{get_area_citations}
\alias{get_area_citations}
\title{Get area citations from Open Baltimore}
\usage{
get_area_citations(
  area_type = NULL,
  area_name = NULL,
  description = NULL,
  start_date = NULL,
  end_date = NULL,
  where = "1=1",
  geometry = TRUE,
  crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
  ...
)
}
\arguments{
\item{area_type}{Area type. Requires area_name is also provided. Options
include "neighborhood", "council district", or "police district"}

\item{area_name}{Area name. Requires area_type is also provided.}

\item{description}{String matching description of citations, e.g. "SIGNS"
filters citations to "PROHIBITED POSTING OF SIGNS ON PUBLIC PROPERTY"}

\item{start_date}{Character string in format YYYY-MM-DD. Filters citations by
violation date.}

\item{end_date}{Character string in format YYYY-MM-DD. Filters citations by
violation date.}

\item{where}{string for where condition. Ignore where condition if area_type
and area_name are provided.}

\item{geometry}{Return sf object based on lat/lon. Default \code{TRUE}. Set to
\code{FALSE} to return citations with missing coordinates.}

\item{crs}{Coordinate reference system (CRS) to return. Default 2804}

\item{...}{Additional parameters passed to \code{\link[getdata:get_esri_data]{getdata::get_esri_data()}}
excluding url, where, crs, and .name_repair.}
}
\description{
Get Environmental Control Board (ECB) citations from 2007 to 2021.
}
\examples{
# Get bulk trash citations for Council District 5
get_area_citations(
   area_type = "council district",
   area_name = "5",
   description = "BULK TRASH")
}
