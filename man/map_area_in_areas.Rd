% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_area_in_areas.R
\name{map_area_in_areas}
\alias{map_area_in_areas}
\title{Map area within selected overlapping areas}
\usage{
map_area_in_areas(
  area,
  type = c("neighborhood", "council district", "legislative district",
    "congressional district", "planning district", "police district", "csa"),
  show_area = TRUE,
  show_label = FALSE,
  background = NULL
)
}
\arguments{
\item{area}{sf object. Required}

\item{type}{Type of area to map. Supports the same types as the get_area function.}

\item{show_area}{Logical. Default TRUE.}

\item{show_label}{Logical. Default FALSE. If TRUE, label areas with ggplot2::geom_sf_label()}

\item{background}{ggplot layer. Default NULL. Passing a ggplot2 layer may be necessary to have an appropriate background for the congressional district maps.}
}
\description{
Map an area or areas within selected overlapping areas.
}
