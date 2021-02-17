#' Get BCPS programs and attendance zones for a local area
#'
#' Get BCPS programs and attendance zones for a local area
#'
#' Returns a named list with overlapping BCPS attendance zones, program
#' locations associated with those zones, and any additional programs located
#' within the area.
#'
#' @param area Name of the neighborhood in sentence case.
#' @export
#' @importFrom sf st_buffer st_intersection
#' @importFrom units set_units
#' @importFrom dplyr select filter
get_area_bcps_programs <- function(area) {

  # TODO: Implement type parameter to return some or all of the data, e.g. type = c("all", "zones", "zoned programs", "other")
  # Identify school zones that intersect area (excluding zones intersecting <= 1 meter)
  area_bcps_zones <- area %>%
    sf::st_buffer(units::set_units(-1, "m")) %>%
    get_area_data(
      data = bcps_zones
    ) %>%
    dplyr::select(program_name:zone_name)

  # Identify schools matching intersecting zones
  area_bcps_zoned_programs <- bcps_programs %>%
    dplyr::filter(program_number %in% area_bcps_zones$program_number)

  # Add other schools within the area
  area_bcps_other_programs <- bcps_programs %>%
    sf::st_intersection(area) %>%
    dplyr::filter(!(program_number %in% area_bcps_zoned_programs$program_number)) %>%
    dplyr::select(program_name:zone_name)

  area_bcps_programs <- list(
    "zones" = area_bcps_zones,
    "zoned_programs" = area_bcps_zoned_programs,
    "other_programs" = area_bcps_other_programs
  )

  return(area_bcps_programs)
}
