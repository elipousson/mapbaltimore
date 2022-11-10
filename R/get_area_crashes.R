
#' Get vehicle crashes for area in Baltimore from Maryland Open Data portal
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [mapmaryland::get_md_crash_data()] function which uses a similar set
#' of parameters.
#'
#' Get vehicle crashes for selected area in Baltimore City.
#' @param area `sf` object.
#' @param start_year earliest year of crash data to return. Default 2020.
#' @param end_year latest year of crash data to return. If `end_year` is
#'   not provided, only a single year is returned. Default 2020.
#' @param geometry If TRUE, return a sf object. Default FALSE.
#' @param trim If TRUE, data trimmed to area with
#'   [sf::st_intersection()]. Default FALSE.
#' @param type Data type to return. Options include c("crash", "person",
#'   "vehicle"). Data types correspond to different tables. If 'person', an age
#'   at crash column is added based on the accident date and date of birth
#'   columns (after removing suspected placeholder values).
#' @keywords internal
#' @export
#' @importFrom purrr map_dfr
#' @importFrom glue glue
#' @importFrom dplyr left_join mutate case_when if_else
#' @importFrom sf st_as_sf
#' @importFrom naniar replace_with_na
#' @importFrom lubridate ymd dmy years int_length interval
#' @importFrom stringr str_replace_all str_remove str_detect
#' @importFrom usethis ui_info ui_todo
get_area_crashes <- function(area,
                             start_year = 2020,
                             end_year = 2020,
                             geometry = FALSE,
                             trim = FALSE,
                             type = c("crash", "person", "vehicle")) {
  lifecycle::deprecate_warn("0.1.2", "get_area_crashes()", "mapmaryland::get_md_crash_data()")
  type <- match.arg(type)
  resource <- "65du-s3qu"

  # Get resource
  crashes <- purrr::map_dfr(
    c(start_year:end_year),
    ~ get_maryland_open_resource(
      resource = resource,
      where = glue::glue(
        "(year = '{.x}')"
      ),
      geometry = geometry,
      area = area,
      trim = trim,
      longitude = "longitude",
      latitude = "latitude"
    )
  )

  if (type == "person") {
    resource <- "py4c-dicf"
  } else if (type == "vehicle") {
    resource <- "mhft-5t5y"
  }

  if (type != "crash") {
    area_report_no <- paste0("'", paste0(crashes$report_no, collapse = "','"), "'")

    type_data <- purrr::map_dfr(
      c(start_year:end_year),
      ~ get_maryland_open_resource(
        resource = resource,
        where = glue::glue("(year = '{.x}') AND report_no in({area_report_no})")
      )
    )

    type_data <- type_data %>%
      dplyr::left_join(crashes, by = c("report_no", "year", "quarter"))

    if (geometry) {
      type_data <- type_data %>%
        sf::st_as_sf(sf_column_name = "geometry")
    }

    if (type == "person") {
      type_data <- type_data %>%
        naniar::replace_with_na(replace = list(date_of_birth = c("1/1/1900", "19000101", "19001111", "19001212", "19200202"))) %>%
        dplyr::mutate(
          acc_date = lubridate::ymd(acc_date),
          date_of_birth = stringr::str_replace_all(date_of_birth, "-", " "),
          date_of_birth = stringr::str_remove(date_of_birth, "[:space:]00:00:00"),
          date_of_birth = dplyr::case_when(
            stringr::str_detect(date_of_birth, "[:alpha:]") ~ lubridate::dmy(date_of_birth),
            !stringr::str_detect(date_of_birth, "[:alpha:]") ~ lubridate::ymd(date_of_birth)
          ),
          date_of_birth = dplyr::if_else(date_of_birth > lubridate::ymd(paste0(end_year, "1231")),
            date_of_birth - lubridate::years(100),
            date_of_birth
          ),
          age_at_crash = floor(lubridate::int_length(lubridate::interval(date_of_birth, acc_date)) / 31557600),
          age_at_crash = dplyr::if_else(age_at_crash > (start_year - 100), -1, age_at_crash),
        ) %>%
        naniar::replace_with_na(replace = list(age_at_crash = -1))
    }

    usethis::ui_info("If multiple vehicles or persons are involved in a crash, the data on the crash represented by the unique report number will appear in multiple rows.")
    usethis::ui_todo("Use the parameter {usethis::ui_value('type = \"crash\"')} for a list of crash reports only.")
    return(type_data)
  } else {
    return(crashes)
  }
}
