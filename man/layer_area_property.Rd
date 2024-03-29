% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/layer_area_property.R
\name{layer_area_property}
\alias{layer_area_property}
\title{Add a layer to a gpplot2 map with area property categorized by type}
\usage{
layer_area_property(
  area = NULL,
  bbox = NULL,
  data = NULL,
  type = c("improved", "vacant", "principal residence", "use", "building type", "value"),
  asis = FALSE,
  diag_ratio = NULL,
  dist = NULL,
  asp = NULL,
  crop = TRUE,
  trim = FALSE,
  show_area = FALSE,
  show_mask = FALSE,
  crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
  ...
)
}
\arguments{
\item{area}{\code{sf} object. If multiple areas are provided, they are unioned
into a single sf object using \code{\link[sf:geos_combine]{sf::st_union()}}}

\item{bbox}{\code{bbox} object defining area used to filter data. If an area is
provided, the bounding box is ignored.}

\item{data}{\code{sf} object including data in area}

\item{type}{Real property variable to map. Options include c("improved",
"vacant", "principal residence", "value"). Currently supports only one
variable at a time.}

\item{asis}{Logical. Default FALSE. If TRUE, use inherited data as is without
cropping to area.}

\item{diag_ratio}{ratio to set map extent based diagonal distance of area's
bounding box. Ignored when \code{dist} is provided.}

\item{dist}{buffer distance in meters. Optional.}

\item{asp}{Aspect ratio of width to height as a numeric value (e.g. 0.33) or
character (e.g. "1:3").}

\item{crop}{If TRUE, data cropped to area or bounding box
\code{\link[sf:st_crop]{sf::st_crop()}} adjusted by the \code{dist}, \code{diag_ratio}, and \code{asp}
parameters provided. Default \code{TRUE}.}

\item{trim}{If TRUE, data trimmed to area with
\code{\link[sf:geos_binary_ops]{sf::st_intersection()}}. This option is not supported for any
adjusted areas that use the \code{dist}, \code{diag_ratio}, or \code{asp} parameters.
Default \code{FALSE}.}

\item{show_area}{Logical. Default FALSE. If TRUE, add an outline of the area
to the layer.}

\item{show_mask}{Logical. Default FALSE. If TRUE, add a mask using
\code{layer_area_mask}}

\item{crs}{Coordinate Reference System (CRS) to use for the returned data.
The CRS of the provided data and bounding box or area must match one
another but are not required to match the CRS provided by this parameter.}

\item{...}{passed to \code{\link[ggplot2:ggsf]{ggplot2::geom_sf()}} for data layer.}
}
\description{
Real property or parcel data is from the Maryland State Department of
Assessment and Taxation and may include outdated or inaccurate information.
}
\examples{
\dontrun{
area <- get_area("neighborhood", "West Forest Park")

property <- get_area_property(area = area)

ggplot2::ggplot() +
  layer_area_property(area = area, data = property, type = "principal residence")
}
}
\seealso{
layer_area_data
}
