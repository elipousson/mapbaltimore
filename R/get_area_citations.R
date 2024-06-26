#' Get area citations from Open Baltimore
#'
#' Get Environmental Control Board (ECB) citations from 2007 to 2021.
#'
#' @param area_type Area type. Requires area_name is also provided. Options
#'   include "neighborhood", "council district", or "police district"
#' @param area_name Area name. Requires area_type is also provided.
#' @param description String matching description of citations, e.g. "SIGNS"
#'   filters citations to "PROHIBITED POSTING OF SIGNS ON PUBLIC PROPERTY"
#' @param start_date Character string in format YYYY-MM-DD. Filters citations by
#'   violation date.
#' @param end_date Character string in format YYYY-MM-DD. Filters citations by
#'   violation date.
#' @param where string for where condition. Ignore where condition if area_type
#'   and area_name are provided.
#' @param geometry Return sf object based on lat/lon. Default `TRUE`. Set to
#'   `FALSE` to return citations with missing coordinates.
#' @param crs Coordinate reference system (CRS) to return. Default 2804
#' @param ... Additional parameters passed to [getdata::get_esri_data()]
#'   excluding url, where, crs, and .name_repair.
#' @example examples/get_area_citations.R
#' @export
#' @importFrom snakecase to_any_case
#' @importFrom stringr str_remove str_trim
#' @importFrom glue glue
#' @importFrom janitor clean_names
#' @importFrom dplyr select mutate across filter
#' @importFrom tidyselect ends_with
#' @importFrom tidyr separate
#' @importFrom sf st_as_sf st_transform
#' @importFrom getdata get_esri_data
get_area_citations <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               start_date = NULL,
                               end_date = NULL,
                               where = "1=1",
                               geometry = TRUE,
                               crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                               ...) {
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

      area_query <- glue("{area_type} = '{area_name}'")
    }

    if (!is.null(description)) {
      description_query <- glue("Description LIKE '%{description}%'")
    }

    if (!is.null(start_date)) {
      start_date_query <- glue("ViolationDate >= DATE '{start_date}'")
    }

    if (!is.null(end_date)) {
      end_date_query <- glue("ViolationDate <= DATE '{end_date}'")
    }

    where <- paste0(c(area_query, description_query, start_date_query, end_date_query), collapse = " AND ")
  }

  url <- "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/ECB/FeatureServer/0"

  citations <-
    getdata::get_esri_data(
      url = url,
      where = where,
      crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
      ...,
      .name_repair = janitor::make_clean_names
    )

  if (nrow(citations) == 0) {
    cli_warn("There are no citations matching the provided parameters.")
    return(citations)
  }

  citations <- citations %>%
    dplyr::select(-c(esri_oid)) %>%
    getdata::fix_epoch_date() %>%
    getdata::str_trim_squish_across() %>%
    tidyr::separate(location, c("latitude", "longitude"), ",") %>%
    dplyr::mutate(
      latitude = as.numeric(stringr::str_remove(latitude, "\\(|\\)|,")),
      longitude = as.numeric(stringr::str_remove(longitude, "\\(|\\)|,"))
    )

  if (geometry) {
    citations <- citations %>%
      dplyr::filter(!is.na(latitude)) %>%
      sf::st_as_sf(
        coords = c("longitude", "latitude"),
        crs = 4326,
        remove = FALSE
      ) %>%
      sf::st_transform(crs)
  }

  return(citations)
}
