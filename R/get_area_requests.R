
#' Get area 311 service requests from Open Baltimore
#'
#' Get 311 service requests for a specific area. Service requests
#'   from 2017 to 2020 area available but only a single year can be requested at
#'   a time. Duplicate requests are removed from the returned data. Requests can
#'   be filtered by request type, responsible city agency, or both. You can
#'   return multiple types or agencies, by using a custom where query parameter
#'   or by calling each type/agency separately.
#'
#' @param year Year for service requests. Default 2021. 2017 to 2022 supported.
#' @param request_type Service request type.
#' @param agency City agency responsible for request. Options include
#'   "Transportation", "BGE", "Solid Waste", "Housing", "Water Wastewater",
#'   "Health", "Call Center", "Finance", "Liquor Board", "Recreation & Parks",
#'   "Fire Department", "Parking Authority", and "General Services"
#' @param where string for where condition. This parameter is ignored if a
#'   request_type or agency are provided.
#' @param geometry Default `TRUE.` If `FALSE`, return requests with missing
#'   latitude/longitude (for years prior to 2021 only).
#' @param duplicates If `TRUE`, return 311 service requests marked as
#'   "Duplicate". If `FALSE`, filter duplicate requests out of results.
#' @inheritParams getdata::get_esri_data
#' @example examples/get_area_requests.R
#' @rdname get_area_requests
#' @export
#' @importFrom dplyr case_when select rename mutate filter across ends_with
#' @importFrom glue glue
#' @importFrom janitor clean_names
#' @importFrom sf st_as_sf st_transform st_intersection
#' @importFrom stringr str_detect str_remove
#' @importFrom lubridate int_length interval ymd_hms
get_area_requests <- function(area,
                              year = 2022,
                              date_range = NULL,
                              request_type = NULL,
                              agency = NULL,
                              where = "1=1",
                              dist = NULL,
                              diag_ratio = NULL,
                              unit = "m",
                              asp = NULL,
                              trim = FALSE,
                              geometry = TRUE,
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                              duplicates = FALSE) {
  is_pkg_installed("esri2sf", repo = "elipousson/esri2sf")

  if (!is.null(date_range)) {
    year <- lubridate::year(getdata::as_date_range(date_range)$start)
  }

  nm <-
    dplyr::case_when(
      year >= 2021 ~ "customer_service_request311_2021_present",
      year == 2020 ~ "x311_customer_service_requests_2020_csv_table",
      year == 2019 ~ "x311_customer_service_requests_2019_csv_table",
      year == 2018 ~ "x311_customer_service_requests_2018_csv_table",
      year == 2017 ~ "t311_customer_service_table"
    )

  url <- baltimore_gis_url(nm)

  if (!is_all_null(c(agency, request_type, date_range, year))) {
    agency_query <- NULL
    request_type_query <- NULL
    created_date_query <- NULL

    if (!is.null(agency)) {
      agency <- match.arg(agency, agencies) # Use internal system data for agency list
      agency_query <- glue::glue("(agency = '{agency}')")
    }

    if (!is.null(request_type)) {
      request_type <- match.arg(request_type, request_types$request_type)
      request_type_query <- glue::glue("(SRType = '{request_type}')")
    }

    if (!is.null(date_range) | !is.null(year)) {
      created_date_query <- getdata::between_date_range(date_range, "CreatedDate", year = year)
    }

    where <- paste0(c(agency_query, request_type_query, created_date_query), collapse = " AND ")
  }

  if (year >= 2021) {
    requests <-
      getdata::get_esri_data(
        location = area,
        url = url,
        where = where,
        dist = dist,
        diag_ratio = diag_ratio,
        unit = unit,
        asp = asp,
        crs = crs
      )

    requests <- requests %>%
      dplyr::select(-c(row_id, needs_sync, is_deleted)) %>%
      sfext::rename_sf_col()
  }

  if (year %in% c(2020, 2019, 2018, 2017)) {
    requests <-
      getdata::get_esri_data(
        location = area,
        dist = dist,
        diag_ratio = diag_ratio,
        unit = unit,
        asp = asp,
        url = url,
        coords = c("longitude", "latitude"),
        where = where,
        crs = crs
      ) %>%
      dplyr::rename(
        service_request_num = servicerequestnum,
        sr_type = srtype,
        status_date = statusdate,
        sr_record_id = srrecordid,
        method_received = methodreceived,
        created_date = createddate,
        close_date = closedate,
        due_date = duedate,
        last_activity = lastactivity,
        last_activity_date = lastactivitydate,
        zip_code = zipcode,
        geo_location = geolocation,
        sr_status = srstatus,
        council_district = councildistrict,
        police_district = policedistrict,
        police_post = policepost
      ) %>%
      dplyr::mutate(council_district = as.character(council_district))
  }

  if (!geometry) {
    requests <- sf::st_drop_geometry(requests)
  }

  if (geometry && trim) {
    requests <- sfext::st_trim(requests, area)
  }

  duplicate_index <- stringr::str_detect(requests$sr_status, "Duplicate")

  if ((sum(duplicate_index) > 0) && !duplicates) {
    # Remove duplicates
    cli::cli_inform(
      "Removing {.val {sum(duplicate_index)}} duplicate 311 service request{?s}."
    )
    requests <- requests[!duplicate_index, ]
  }

  requests <- requests %>%
    dplyr::select(-c(sr_record_id, geo_location, police_post)) %>%
    getdata::fix_epoch_date() %>%
    # Filter to selected request types
    dplyr::mutate(
      zip_code = as.character(zip_code),
      # Fix date formatting
      # Calculate the number of days to created to closed
      days_to_close = dplyr::case_when(
        sr_status == "Closed" ~ lubridate::int_length(lubridate::interval(lubridate::ymd_hms(created_date), lubridate::ymd_hms(close_date))) / 86400
      ) %>% round(digits = 2),
      .after = outcome
    ) %>%
    dplyr::mutate(
      address = stringr::str_remove(address, ",[:space:](BC$|Baltimore[:space:]City.+)")
    ) %>%
    dplyr::mutate(
      sr_status_url = paste0("https://balt311.baltimorecity.gov/citizen/requests/", requests$service_request_num),
      .after = "sr_status"
    )

  requests
}

#' @noRd
fix_date <- function(x) {
  dplyr::mutate(
    x,
    dplyr::across(
      dplyr::contains("date") & where(is.numeric),
      ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
    )
  )
}
