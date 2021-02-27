#' Get real property data for an area
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant,
#' and unimproved. Real property or parcel data is from the Maryland State
#' Department of Assessment and Taxation and may include errors.
#'
#' @param area \code{sf} object
#' @inheritParams get_area_data
#' @export
#'
get_area_property <- function(area = NULL,
                              bbox = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              crop = TRUE,
                              trim = FALSE) {

  area_real_property <- get_area_data(
    area = area,
    bbox = bbox,
    cachedata = "real_property",
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    crop = crop,
    trim = trim
  )

  return(area_real_property)
}
