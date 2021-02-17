
#' Get nearby areas
#'
#' Return data for all areas of a specified type within a specified distance of another area.
#'
#' @param area sf object. Must have a name column unless an \code{area_label} is provided.
#' @param type Length 1 character vector. Required to match one of the supported area types (excluding U.S. Census types). This is the area type for the areas to return and is not required to be the same type as the provided area.
#' @param dist Distance in meters for matching nearby areas. Default is 1 meter.
#'
#' @export
#'
get_nearby_areas <- function(area,
                             type = c(
                               "neighborhood",
                               "council district",
                               "legislative district",
                               "congressional district",
                               "planning district",
                               "police district",
                               "csa"
                             ),
                             dist = 1) {
  check_area(area)

  type <- match.arg(type)
  type <- paste0(gsub(" ", "_", type), "s")

  dist <- units::set_units(dist, "m")

  # Check what type of nearby area to return
  return_type <- eval(as.name(type))

  # Select areas within provided distance of the area
  nearby_areas <- sf::st_join(
    return_type,
    sf::st_buffer(
      dplyr::select(area, area_name = name),
      dist
    ),
    by = "st_intersects"
  ) %>%
    dplyr::filter(
      # Filter to areas within 2 meters of the provided area
      area_name %in% area$name
    ) %>%
    dplyr::filter(
      # Remove area that was matched (only return nearby areas)
      # This is only necessary if multiple areas are provided
      !(name %in% area$name)
    ) %>%
    # Remove provided area name
    dplyr::select(-area_name)

  return(nearby_areas)
}
