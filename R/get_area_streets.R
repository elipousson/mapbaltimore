#' Get selected area streets
#'
#' Get streets within an area or areas.
#'
#' @param area sf object with area of streets to return.
#' @param street_type selected street subtypes to include. By default, the returned data includes all subtypes except alleys ("STRALY").
#' Options include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR", "STRURD", "STCLN", "STRTN")
#' @param sha_class selected SHA classifications to include.
#' "all" selects all streets with an assigned SHA classification (around one-quarter of all street segments).
#' Additional options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @inheritParams get_area_data
#' @param trim Logical. Default `FALSE`. Trim streets to area using `sf::st_intersection()`.
#' @param msa Logical. Default `FALSE`. Get streets from cached `baltimore_msa_streets.gpkg` file using `cachedata` parameter of `get_area_data` function.
#' @param union Logical. Default `TRUE`. Union geometry based on `fullname` of streets.
#' @export
#' @importFrom dplyr rename mutate
#'
get_area_streets <- function(area = NULL,
                             street_type = NULL,
                             sha_class = NULL,
                             bbox = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             asp = NULL,
                             trim = FALSE,
                             msa = FALSE,
                             union = TRUE) {
  area <- area %||% bbox

  if (!msa) {
    # Get streets in area
    area_streets <- getdata::get_location_data(
      data = streets,
      location = area,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      trim = trim
    )
  } else {
    # Get streets in area that includes MSA
    area_streets <- getdata::get_location_data(
      location = area,
      data = "baltimore_msa_streets",
      package = "mapbaltimore",
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      trim = trim
    ) %>%
      dplyr::rename(
        fullname = road_name,
        geometry = geom
      ) %>%
      dplyr::mutate(
        subtype = ""
      )
  }

  filter_streets(
    x = area_streets,
    sha_class = sha_class,
    street_type = street_type,
    union = union
  )
}
