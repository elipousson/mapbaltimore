% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{bcps_programs}
\alias{bcps_programs}
\title{Baltimore City Public School Programs}
\format{
A data frame with 165 rows and 6 variables:
\describe{
  \item{\code{program_name}}{Program or school name}
  \item{\code{program_number}}{Program number}
  \item{\code{type}}{Program type}
  \item{\code{category}}{Program category, e.g. E, EM, H, etc.}
  \item{\code{zone_name}}{Program name with zone appended}
  \item{\code{geometry}}{Multipolygons with school program location}
}
}
\source{
\url{https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2021_Programs/FeatureServer/0}
}
\usage{
bcps_programs
}
\description{
Locations of school buildings/school programs.
}
\keyword{datasets}
