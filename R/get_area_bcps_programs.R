#' Get BCPS programs and attendance zones for a local area
#'
#' Get BCPS programs and attendance zones for a local area
#'
#' Returns a named list with overlapping BCPS attendance zones, program
#' locations associated with those zones, and any additional programs located
#' within the area.
#'
#' @param type Type of BCPS data to return. "all" returns a named list with all
#'   of the following spatial data. "zones" returns attendance zones, "programs"
#'   returns locations of programs (schools) with zones intersecting area (even
#'   if the program is located outside the area), "other" returns charter
#'   schools and other special schools located within the specified area.
#' @inheritParams get_area_data
#' @export
#' @importFrom dplyr select filter
#' @importFrom sfext st_buffer_ext
get_area_bcps_programs <- function(area,
                                   dist = NULL,
                                   diag_ratio = NULL,
                                   asp = NULL,
                                   crop = TRUE,
                                   trim = FALSE,
                                   type = c("all", "zones", "programs", "other")) {
  type <- match.arg(type)

  # Identify school zones that intersect area (excluding zones intersecting <= 1 meter)
  area_bcps_zones <-
    getdata::get_location_data(
      location = sfext::st_buffer_ext(area, dist = -1, diag_ratio = NULL),
      data = bcps_zones,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      crop = crop,
      trim = trim
    )

  if (type == "zones") {
    return(area_bcps_zones)
  }

  # Identify schools matching intersecting zones
  area_bcps_zoned_programs <- bcps_programs %>%
    dplyr::filter(program_number %in% area_bcps_zones$program_number)

  if (type == "programs") {
    return(area_bcps_zoned_programs)
  }

  # Add other schools within the area
  area_bcps_other_programs <-
    getdata::get_location_data(
      location = area,
      data = bcps_programs,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      crop = crop,
      trim = trim
    ) %>%
    dplyr::filter(!(program_number %in% area_bcps_zones$program_number))

  if (type == "other") {
    return(area_bcps_other_programs)
  }

  if (type == "all") {
    area_bcps_programs <- list(
      "zones" = area_bcps_zones,
      "zoned_programs" = area_bcps_zoned_programs,
      "other_programs" = area_bcps_other_programs
    )
    return(area_bcps_programs)
  }
}
