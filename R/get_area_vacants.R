#' Get vacant building notices
#'
#' Parcel boundaries for all properties with an active vacant building notice.
#' If a building is unoccupied and unsafe or unfit for people to live or work
#' inside the building, or has two code violations that have not been fixed, or
#' has six code violations in the past year, then the building may receive a
#' vacant building notice in Baltimore City.
#'
#' If the rehabbed parameter is TRUE, the returned data is use and occupancy
#' permits that were pulled on properties with vacant building notices. DHCD
#' uses this data as proxy for vacant building rehabs.
#'
#' @param rehabbed If TRUE, return building permits pulled on properties with
#'   vacant building notices. Default FALSE.
#' @inheritParams get_area_data
#' @export
#' @importFrom dplyr mutate across select rename
#' @importFrom tidyselect contains
get_area_vacants <- function(area = NULL,
                             bbox = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             asp = NULL,
                             crop = TRUE,
                             trim = FALSE,
                             rehabbed = FALSE) {
  area <- area %||% bbox

  if (!rehabbed) {
    url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxLandPlanning/MapServer/20"

    vacant_building_notices <- getdata::get_location_data(
      location = area,
      data = url,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      crop = crop,
      trim = trim
    ) %>%
      dplyr::mutate(
        dplyr::across(
          tidyselect::contains("date"),
          ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
        )
      ) %>%
      dplyr::select(
        -c(nt, objectid)
      ) %>%
      dplyr::rename(
        geometry = geoms
      )

    return(vacant_building_notices)
  } else {
    url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxLandPlanning/MapServer/21"

    rehabbed_vacants <- getdata::get_location_data(
      location = area,
      data = url,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m",
      asp = asp,
      crop = crop,
      trim = trim
    ) %>%
      dplyr::mutate(
        dplyr::across(
          tidyselect::contains("date"),
          ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
        )
      ) %>%
      dplyr::rename(
        geometry = geoms
      )
  }
}
