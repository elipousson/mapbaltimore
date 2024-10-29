#' Get area 911 calls for service from Open Baltimore
#'
#' [get_area_911_calls()] can return public records on 911 calls for service
#' from 2017 through the present year.
#'
#' @param area_type Area type. Requires area_name is also provided. Options
#'   include "neighborhood", "council district", or "police district"
#' @param area_name Area name. Requires area_type is also provided.
#' @param description String matching call description, e.g. "DISORDERLY",
#'   "BURGLARY", "DISCHRG FIREARM", etc.
#' @param year numeric. Year of calls for service. Currently only one year at a
#'   time is supported (except for years since 2021). If `NULL`, the oldest year
#'   from the start_date and end_date is used.
#' @param start_date Character string in format YYYY-MM-DD. Filters calls by
#'   date.
#' @param end_date Character string in format YYYY-MM-DD.  Filters calls by
#'   date.
#' @param where string for where condition. Ignored if area_type, area_name,
#'   start_date, or end_date are provided.
#' @param ... Additional parameters passed to [getdata::get_esri_data()]
#'   excluding url, where, crs, and .name_repair.
#' @examples
#' \dontrun{
#' get_area_911_calls(
#'   area_type = "neighborhood",
#'   area_name = "Downtown",
#'   start_date = "2022-01-01",
#'   end_date = "2022-01-02",
#'   description = "AUTO"
#' )
#' }
#' @export
#' @importFrom cli cli_abort
#' @importFrom dplyr case_when rename
#' @importFrom snakecase to_any_case
#' @importFrom stringr str_remove
#' @importFrom glue glue
#' @importFrom pkgconfig get_config
#' @importFrom janitor make_clean_names
get_area_911_calls <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               year = 2023,
                               start_date = NULL,
                               end_date = NULL,
                               where = NULL,
                               ...) {
  check_installed("lubridate")

  date_range <- getdata::as_date_range(c(start_date, end_date), year = year)
  start_date <- date_range[["start"]]
  end_date <- date_range[["end"]]
  year <- lubridate::year(start_date)

  cli_if(
    !is.null(year) && (year < 2013),
    "{.arg year} or year of {.arg start_date} must be 2013 or later.",
    .fn = cli::cli_abort
  )

  if (year <= 2022) {
    url <- paste0(
      "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/911_2013_2022/FeatureServer/",
      year - 2013
    )
  } else if (year == 2023) {
    url <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/police_CallsForService_PreviousYear/FeatureServer/0"
  } else {
    url <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/911_Calls_For_Services_2024/FeatureServer/0"
  }

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

    area_query <- glue("{area_type} = '{area_name}'")
  }

  if (!is.null(description)) {
    description_query <- glue("description LIKE '%{description}%'")
  }

  if (!is.null(start_date)) {
    start_date_query <- glue("callDateTime >= DATE '{start_date}'")
  }

  if (!is.null(end_date)) {
    end_date_query <- glue("callDateTime <= DATE '{end_date}'")
  }

  where <-
    glue_collapse(
      c(where, area_query, description_query, start_date_query, end_date_query),
      sep = " AND "
    )

  calls <- getdata::get_esri_data(
    url = url,
    where = where,
    crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
    ...,
    .name_repair = janitor::make_clean_names
  )

  if (!is_installed("arcgislayers")) {
    calls <- calls %>%
      getdata::fix_epoch_date()
  }

  calls <- calls %>%
    getdata::str_trim_squish_across()

  dplyr::rename(
    calls,
    any_of(
      c(
        "incident_location" = "incidentlocation",
        "call_date_time" = "calldatetime"
      )
    )
  )
}
