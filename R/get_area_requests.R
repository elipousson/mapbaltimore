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
#' @param date_range Date range as character vector in format of c("YYYY-MM-DD",
#'   "YYYY-MM-DD"). Minimum and maximum values are used if length is greater
#'   than 1.
#' @inheritParams sfext::st_filter_ext
#' @example examples/get_area_requests.R
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom getdata get_esri_data fix_epoch_date
#' @importFrom dplyr select rename mutate case_when
#' @importFrom sfext rename_sf_col st_trim
#' @importFrom sf st_drop_geometry
#' @importFrom stringr str_detect str_remove
#' @importFrom cli cli_inform cli_alert
#' @importFrom lubridate int_length interval ymd_hms
get_area_requests <- function(area = NULL,
                              year = 2022,
                              date_range = NULL,
                              request_type = NULL,
                              agency = NULL,
                              where = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              unit = "m",
                              asp = NULL,
                              trim = FALSE,
                              geometry = TRUE,
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                              duplicates = FALSE) {
  url <- set_request_url(date_range, year)

  where <- make_request_query(where, agency, request_type, date_range, year)

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

  if (year == 2017) {
    cli::cli_alert("date formatting is not working consistently for 2017 service requests.")
  }

  requests <- getdata::fix_epoch_date(requests)

  requests <- requests %>%
    dplyr::select(-c(sr_record_id, geo_location, police_post)) %>%
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

#' @noRd
#' @importFrom lubridate year
#' @importFrom getdata as_date_range
#' @importFrom dplyr case_when
set_request_url <- function(date_range = NULL,
                            year = 2022) {
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

  baltimore_gis_url(nm)
}

#' @noRd
#' @importFrom cli cli_alert_warning cli_abort
#' @importFrom glue glue
#' @importFrom getdata as_date_range between_date_range
#' @importFrom lubridate year
make_request_query <- function(where = NULL,
                               agency = NULL,
                               request_type = NULL,
                               date_range = NULL,
                               year = 2022) {
  if (is.null(c(agency, request_type, date_range, year))) {
    return(where)
  }

  if (!is.null(where)) {
    cli::cli_alert_warning(
      "{.arg agency}, {.arg request_type}, {.arg date_range}, and {.arg year}
        are ignored if {.arg where} is provided."
    )

    return(where)
  }

  agency_query <- NULL
  request_type_query <- NULL
  created_date_query <- NULL

  if (!is.null(agency)) {
    # Use internal system data for agency list
    agency <- match.arg(agency, agencies)
    agency_query <- glue::glue("(agency = '{agency}')")
  }

  if (!is.null(request_type)) {
    request_type <- match.arg(request_type, request_types$request_type)
    request_type_query <- glue::glue("(SRType = '{request_type}')")
  }

  if (!is.null(date_range) | !is.null(year)) {
    check_range <- getdata::as_date_range(date_range, year)
    min_year <- lubridate::year(check_range[["start"]])
    max_year <- lubridate::year(check_range[["end"]])

    if ((min_year < 2021) & (min_year != max_year)) {
      cli::cli_abort(
        "{.arg date_range} or {.arg year} can only specify a single year
        if year is less than 2021."
      )
    }

    created_date_query <- getdata::between_date_range(
      date_range,
      "CreatedDate",
      year = year
    )
  }

  paste0(
    c(agency_query, request_type_query, created_date_query),
    collapse = " AND "
  )
}
