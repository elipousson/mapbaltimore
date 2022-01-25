#' @title Get area 911 calls for service from Open Baltimore
#' @description Get 911 calls for service from 2021 and 2022.
#' @param area_type Area type. Requires area_name is also provided. Options
#'   include "neighborhood", "council district", or "police district"
#' @param area_name Area name. Requires area_type is also provided.
#' @param description String matching call description, e.g. "DISORDERLY",
#'   "BURGLARY", "DISCHRG FIREARM", etc.
#' @param year numeric. Year of calls for service. Currently only one year at a
#'   time is supported (except for 2021 and 2022). If NULL, the oldest year from
#'   the start_date and end_date is used.
#' @param start_date Character string in format YYYY-MM-DD. Filters calls by
#'   date.
#' @param end_date Character string in format YYYY-MM-DD.  Filters calls by
#'   date.
#' @param where string for where condition. Ignored if area_type, area_name,
#'   start_date, or end_date are provided.
#' @rdname get_area_911_calls
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom snakecase to_any_case
#' @importFrom stringr str_remove str_trim
#' @importFrom glue glue
#' @importFrom esri2sf esri2df
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate across
#' @importFrom tidyselect contains
get_area_911_calls <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               year = NULL,
                               start_date = NULL,
                               end_date = NULL,
                               where = "1=1") {


  if (is.null(year)) {
    year <- min(lubridate::year(start_date), lubridate::year(end_date))
  }

  if (is.null(start_date)) {
    start_date <- paste0(year, "-01-01")
  }

  if (is.null(end_date)) {
    end_date <- paste0(year, "-12-31")
  }

  url <- dplyr::case_when(
    year >= 2021 ~ "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/CallsForService_2021_Present/FeatureServer/0",
    year == 2020 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/911_Calls_For_Service_2020_csv/FeatureServer/0",
    year == 2019 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/911_Calls_For_Service_2019_csv/FeatureServer/0",
    year == 2018 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/911_Calls_For_Service_2018_csv/FeatureServer/0",
    year == 2017 ~ "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/911_Calls_For_Service_2017_csv/FeatureServer/0"
  )

  if (!is.null(area_type) | !is.null(description) | !is.null(start_date) | !is.null(end_date)) {
    area_query <- NULL
    description_query <- NULL
    start_date_query <- NULL
    end_date_query <- NULL

    if (!is.null(area_type) && !is.null(area_name)) {
      area_type <- match.arg(area_type, c("neighborhood", "council district", "police district"))
      area_type <- snakecase::to_any_case(area_type, case = "big_camel")

      if (area_type == "CouncilDistrict") {
        area_name <- stringr::str_remove(area_name, "District[:space:]")
      }

      area_query <- glue::glue("{area_type} = '{area_name}'")
    }

    if (!is.null(description)) {
      description_query <- glue::glue("description LIKE '%{description}%'")
    }

    if (!is.null(start_date)) {
      start_date_query <- glue::glue("callDateTime >= DATE '{start_date}'")
    }

    if (!is.null(end_date)) {
      end_date_query <- glue::glue("callDateTime <= DATE '{end_date}'")
    }

    where <- paste0(c(area_query, description_query, start_date_query, end_date_query), collapse = " AND ")
  }

  calls <- esri2sf::esri2df(
    url = url,
    where = where
  ) |>
    janitor::clean_names("snake")

  calls <- calls |>
    dplyr::mutate(
      dplyr::across(where(is.character),
                    ~ stringr::str_trim(.x)),
      dplyr::across(tidyselect::contains("date"),
                    ~ as.POSIXct(.x / 1000, origin = "1970-01-01"))
    )

  if (year < 2021) {
    calls <- calls |>
      dplyr::rename(
        incident_location = incidentlocation,
        call_date_time = calldatetime)
  }

  return(calls)
}
