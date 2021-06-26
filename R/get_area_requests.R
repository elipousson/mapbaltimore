#' @title Get area 311 service requests
#' @description Get 311 service requests for a specific area. Currently only 2021 service requests are supported.
#' @param year Year for service requests (2021 is currently the only year supported), Default: 2021
#' @param request_type Service request type.
#' @param agency City agency assigned for request. Options include "Transportation", "BGE", "Solid Waste", "Housing", "Water Wastewater", "Health", "Call Center", "Finance", "Liquor Board", "Recreation & Parks", "Fire Department", "Parking Authority", and "General Services"
#' @inheritParams get_area_esri_data
#' @rdname get_area_requests
#' @export
#' @importFrom glue glue
#' @importFrom dplyr filter mutate across ends_with case_when select rename
#' @importFrom stringr str_detect str_remove
#' @importFrom lubridate int_length interval ymd_hms
get_area_requests <- function(area,
                              year = 2021,
                              request_type = NULL,
                              agency = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              trim = FALSE,
                              crs = 2804) {
  if (year == 2021) {
    path <- "https://egis.baltimorecity.gov/egis/rest/services/GeoSpatialized_Tables/ServiceRequest_311/FeatureServer/0"
  } else {
    stop("This function does not currently support any year before to 2021.")
  }

  where <- NULL

  # Currently filter by agency *or* request type - not both
  if (!is.null(agency)) {
    agency <- match.arg(agency, agencies) # Use internal system data for agency list
    where <- glue::glue("Agency = '{agency}'")
  } else if (!is.null(request_type)) {
    request_type <- match.arg(request_type, mapbaltimore::request_types$request_type)
    where <- glue::glue("SRType = '{request_type}'")
  }

  if (is.null(where)) {
    where <- "1=1"
  }

  requests <- get_area_esri_data(
    area = area,
    url = path,
    where = where,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    trim = trim,
    crs = crs
  )

  n_duplicates <- length(dplyr::filter(requests, stringr::str_detect(sr_status, "Duplicate")))

  if (n_duplicates > 0) {
    message(glue::glue("Removing {n_duplicates} duplicate 311 service requests."))
    requests <- dplyr::filter(requests, !stringr::str_detect(sr_status, "Duplicate")) # Remove duplicates
  }

  requests <- requests %>%
    # Filter to selected request types
    dplyr::mutate(
      # Fix date formatting
      dplyr::across(dplyr::ends_with("date"), ~ as.POSIXct(.x / 1000, origin = "1970-01-01")),
      # Calculate the number of days to created to closed
      days_to_close = dplyr::case_when(
        sr_status == "Closed" ~ lubridate::int_length(lubridate::interval(lubridate::ymd_hms(created_date), lubridate::ymd_hms(close_date))) / 86400
      ) %>% round(digits = 2),
      address = stringr::str_remove(address, ",[:space:](BC$|Baltimore[:space:]City.+)")
    ) %>%
    dplyr::select(-c(row_id, sr_record_id, geo_location, needs_sync, is_deleted, police_post)) %>%
    dplyr::rename(geometry = geoms)

  return(requests)
}
