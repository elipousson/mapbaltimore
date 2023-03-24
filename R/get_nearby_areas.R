#' Get nearby areas
#'
#' Return areas of a selected type within a set distance of another area.
#'
#' @param area sf object. Must have a name column for exclude_area to work.
#' @param type Required. Supported values include "neighborhood", "council
#'   district", "legislative district", "congressional district", "planning
#'   district", "police district", "csa", and "park district". The type may be
#'   different than the type of the area provided.
#' @param dist Distance in meters for matching nearby areas. Default is 1 meter.
#' @param exclude_area Logical. Default TRUE. If FALSE, include the same areas
#'   provided to area (assuming the areas provide are the same type as the
#'   parameter provided to get_nearby_areas).
#' @param residential Logical. Default FALSE. If the type is neighborhood, set
#'   TRUE to only return residential neighborhoods (excluding industrial areas,
#'   business parks, and parks/reservoirs).
#' @export
#' @importFrom dplyr filter
#' @importFrom sfext st_buffer_ext
get_nearby_areas <- function(area,
                             type = c(
                               "neighborhood",
                               "council district",
                               "legislative district",
                               "congressional district",
                               "planning district",
                               "police district",
                               "csa",
                               "park district"
                             ),
                             dist = 1,
                             exclude_area = TRUE,
                             residential = FALSE) {
  type <- match.arg(type)

  nearby_areas <- get_area(type = type, location = sfext::st_buffer_ext(x = area, dist = dist))

  if (exclude_area && ("name" %in% names(area))) {
    nearby_areas <- dplyr::filter(nearby_areas, !(name %in% area$name))
  }

  if (residential && (type == "neighborhood")) {
    nearby_areas <- dplyr::filter(nearby_areas, type == "Residential")
  }

  return(nearby_areas)
}
