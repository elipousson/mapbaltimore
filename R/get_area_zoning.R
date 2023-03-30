#' Get zoning data for an area
#'
#' Get zoning codes for an area within a provided sf or bbox object.
#'
#' This 2017 zoning data does not include any exemptions granted by the Baltimore
#' City BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required `sf` object with a 'name' column.
#' @param category Zoning category to return. "all", "residential", "commercial", "industrial"
#' @inheritParams get_area_data
#' @param union Logical. Default FALSE. If true, group zoning by label and combine geometry with [sf::st_union()].
#' @return `sf` object with zoning and overlay data for area.
#' @export
#' @importFrom getdata get_location_data
#' @importFrom dplyr filter group_by summarise
#' @importFrom sf st_union
get_area_zoning <- function(area = NULL,
                            bbox = NULL,
                            category = c("all", "residential", "commercial", "industrial"),
                            diag_ratio = NULL,
                            dist = NULL,
                            asp = NULL,
                            crop = TRUE,
                            trim = FALSE,
                            crs = NULL,
                            union = FALSE) {
  category <- match.arg(category)

  area <- area %||% bbox
  # Get zoning with parameters
  area_zoning <- getdata::get_location_data(
    location = area,
    data = zoning,
    diag_ratio = diag_ratio,
    dist = dist,
    unit = "m",
    asp = asp,
    crop = crop,
    trim = trim,
    crs = crs
  )

  if (category == "residential") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning %in% c("Rowhouse and Multi-Family Residential Districts", "Detached and Semi-Detached Residential Districts"))
  } else if (category == "commercial") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning == "Commercial Districts")
  } else if (category == "industrial") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning == "Industrial Districts")
  }

  if (!union) {
    return(area_zoning)
  }

  # Union geometry by label
  area_zoning <- area_zoning %>%
    dplyr::group_by(label) %>%
    dplyr::summarise(
      geometry = sf::st_union(geometry)
    )
}
