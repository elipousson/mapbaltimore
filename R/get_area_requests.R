#' @title Get area 311 service requests from Open Baltimore
#' @description Get 311 service requests for a specific area. Service requests
#'   from 2017 to 2020 area available but only a single year can be requested at
#'   a time. Duplicate requests are removed from the returned data. Requests can
#'   be filtered by request type, responsible city agency, or both. You can
#'   return multiple types or agencies, by using a custom where query parameter
#'   or by calling each type/agency separately.
#' @param year Year for service requests. Default 2021. 2017 to 2022 supported.
#' @param request_type Service request type.
#' @param agency City agency responsible for request. Options include
#'   "Transportation", "BGE", "Solid Waste", "Housing", "Water Wastewater",
#'   "Health", "Call Center", "Finance", "Liquor Board", "Recreation & Parks",
#'   "Fire Department", "Parking Authority", and "General Services"
#' @param where string for where condition. This parameter is ignored if a
#'   request_type or agency are provided.
#' @param geometry Default TRUE. If FALSE, return requests with missing
#'   latitude/longitude (for years prior to 2021 only).
#' @inheritParams get_area_esri_data
#' @example examples/get_area_requests.R
#' @rdname get_area_requests
#' @export
#' @importFrom dplyr case_when select rename mutate filter across ends_with
#' @importFrom glue glue
#' @importFrom esri2sf esri2df
#' @importFrom janitor clean_names
#' @importFrom sf st_as_sf st_transform st_intersection
#' @importFrom stringr str_detect str_remove
#' @importFrom lubridate int_length interval ymd_hms
get_area_requests <- function(area,
                              year = 2021,
                              request_type = NULL,
                              agency = NULL,
                              where = "1=1",
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              trim = FALSE,
                              geometry = TRUE,
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  url <- dplyr::case_when(
    year >= 2021 ~ "https://egis.baltimorecity.gov/egis/rest/services/GeoSpatialized_Tables/ServiceRequest_311/FeatureServer/0",
    year == 2020 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/311_Customer_Service_Requests_2020_csv/FeatureServer/0",
    year == 2019 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/311_Customer_Service_Requests_2019_csv/FeatureServer/0",
    year == 2018 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/311_Customer_Service_Requests2018_csv/FeatureServer/0",
    year == 2017 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/311_Customer_Service_Requests_2017/FeatureServer/0"
  )

  if (!is.null(agency) | !is.null(request_type)) {
    agency_query <- NULL
    request_type_query <- NULL

    if (!is.null(agency)) {
      agency <- match.arg(agency, agencies) # Use internal system data for agency list
      agency_query <- glue::glue("agency = '{agency}'")
    }

    if (!is.null(request_type)) {
      request_type <- match.arg(request_type, request_types$request_type)
      request_type_query <- glue::glue("srtype = '{request_type}'")
    }

    where <- paste0(c(agency_query, request_type_query), collapse = " AND ")
  }

  if (year == 2021) {
    requests <- get_area_esri_data(
      area = area,
      url = url,
      where = where,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim,
      crs = crs
    ) %>%
      dplyr::select(-c(row_id, needs_sync, is_deleted)) %>%
      dplyr::rename(geometry = geoms)
  } else if (year %in% c(2020, 2019, 2018, 2017)) {
    bbox <- area %>%
      adjust_bbox(dist = dist, diag_ratio = diag_ratio, asp = asp, crs = 4326)

    bbox_query <- glue::glue("(latitude >= {bbox$ymin[[1]]}) AND (latitude <= {bbox$ymax[[1]]}) AND (longitude >= {bbox$xmin[[1]]}) AND (longitude <= {bbox$xmax[[1]]})")

    if (where == "1=1") {
      where <- bbox_query
    } else {
      where <- paste0(c(where, bbox_query), collapse = " AND ")
    }

    requests <- esri2sf::esri2df(
      url = url,
      where = where,
      bbox = NULL
    ) %>%
      janitor::clean_names("snake") %>%
      dplyr::mutate(councildistrict = as.character(councildistrict))

    if (geometry) {
      requests <- requests %>%
        dplyr::filter(!is.na(latitude)) %>%
        sf::st_as_sf(
          coords = c("longitude", "latitude"),
          remove = FALSE,
          crs = 4326
        ) %>%
        sf::st_transform(crs)
    }


    if (trim) {
      requests <- sf::st_intersection(requests, area)
    }
  }

  n_duplicates <- length(dplyr::filter(requests, stringr::str_detect(sr_status, "Duplicate")))

  if (n_duplicates > 0) {
    message(glue::glue("Removing {n_duplicates} duplicate 311 service requests."))
    requests <- dplyr::filter(requests, !stringr::str_detect(sr_status, "Duplicate")) # Remove duplicates
  }

  requests <- requests %>%
    dplyr::select(-c(sr_record_id, geo_location, police_post)) %>%
    # Filter to selected request types
    dplyr::mutate(
      # Fix date formatting
      dplyr::across(
        dplyr::ends_with("date"),
        ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
      ),
      # Calculate the number of days to created to closed
      days_to_close = dplyr::case_when(
        sr_status == "Closed" ~ lubridate::int_length(lubridate::interval(lubridate::ymd_hms(created_date), lubridate::ymd_hms(close_date))) / 86400
      ) %>% round(digits = 2),
      .after = outcome
    ) %>%
    dplyr::mutate(
      address = stringr::str_remove(address, ",[:space:](BC$|Baltimore[:space:]City.+)")
    )


  return(requests)
}
