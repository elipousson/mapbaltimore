#' Get zoning data for an area
#'
#' Get zoning codes for an area within a provided sf or bbox object.
#'
#' This 2017 zoning data does not include any exemptions granted by the Baltimore
#' City BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area sf, sfc, or bbox object. If multiple areas are provided, they are
#'   unioned into a single sf object using [sf::st_union()].
#' @param category Zoning category to return. "all", "residential", "commercial", "industrial"
#' @inheritParams get_area_data
#' @param union Logical. Default FALSE. If true, group zoning by label and combine geometry with [sf::st_union()].
#' @return `sf` object with zoning and overlay data for area.
#' @export
#' @importFrom getdata get_location_data
#' @importFrom dplyr filter group_by summarise
#' @importFrom sf st_union
#' @importFrom sfext st_union_by
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

  category <-
    switch(category,
      "residential" = c(
        "Rowhouse and Multi-Family Residential Districts",
        "Detached and Semi-Detached Residential Districts"
      ),
      "commercial" = "Commercial Districts",
      "industrial" = "Industrial Districts"
    )

  area_zoning <- dplyr::filter(area_zoning, category_zoning %in% category)

  if (!union) {
    return(area_zoning)
  }

  # Union geometry by label
  sfext::st_union_by(area_zoning, label)
}
