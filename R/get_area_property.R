#' Map real property data for an area
#'
#' Map real property data by improvement, vacancy, principal residence status, and other characteristics.
#' This function is intended to replace `map_tenure`, `map_vacancy`, and (eventually) `map_decade_built.`
#' Get real property data for an area
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant, and unimproved.
#' Real property or parcel data is from the Maryland State Department of Assessment and Taxation and may include errors.
#'
#' @param area Required `sf` class tibble. Must include a name column.
#' @inheritParams get_area_data
#' @export
#'
get_area_property <- function(area = NULL,
                              bbox = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              trim = FALSE) {
  area_real_property <- get_area_data(
    area = area,
    bbox = bbox,
    cachedata = "real_property",
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    trim = trim
  )

  return(area_real_property)
}
