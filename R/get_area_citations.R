#' @title Get area citations from Open Baltimore
#' @description Get Environmental Control Board (ECB) citations from 2007 to
#'   2021.
#' @param area_type Area type. Requires area_name is also provided. Options
#'   include "neighborhood", "council district", or "police district"
#' @param area_name Area name. Requires area_type is also provided.
#' @param description String matching description of citations, e.g. "SIGNS"
#'   filters citations to "PROHIBITED POSTING OF SIGNS ON PUBLIC PROPERTY"
#' @param where string for where condition. Ignore where condition if area_type
#'   and area_name are provided.
#' @param crs Coordinate reference system (CRS) to return. Default 2804
#' @rdname get_area_citations
#' @examples
#' \dontrun{
#' # Get bulk trash citations for Council District 5
#' get_area_citations(
#'   area_type = "council district",
#'   area_name = "5",
#'   description = "BULK TRASH")
#' }
#' @export
#' @importFrom snakecase to_any_case
#' @importFrom stringr str_remove str_trim
#' @importFrom glue glue
#' @importFrom esri2sf esri2df
#' @importFrom janitor clean_names
#' @importFrom dplyr select mutate across filter
#' @importFrom tidyselect ends_with
#' @importFrom tidyr separate
#' @importFrom sf st_as_sf st_transform
get_area_citations <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               where = "1=1",
                               crs = 2804) {
  if (!is.null(area_type) | !is.null(description)) {
    area_query <- NULL
    description_query <- NULL

    if (!is.null(area_type) && !is.null(area_name)) {
      area_type <- match.arg(area_type, c("neighborhood", "council district", "police district"))
      area_type <- snakecase::to_any_case(area_type, case = "big_camel")

      if (area_type == "CouncilDistrict") {
        area_name <- stringr::str_remove(area_name, "District[:space:]")
      }

      area_query <- glue::glue("{area_type} = '{area_name}'")
    }

    if (!is.null(description)) {
      description_query <- glue::glue("Description LIKE '%{description}%'")
    }

    where <- paste0(c(area_query, description_query), collapse = " AND ")
  }

  url <- "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/ECB/FeatureServer/0"

  citations <- esri2sf::esri2df(
    url = url,
    where = where
  ) |>
  janitor::clean_names("snake") |>
    dplyr::select(-c(esri_oid)) |>
  dplyr::mutate(
    dplyr::across(where(is.character),
                  ~ stringr::str_trim(.x)),
    dplyr::across(tidyselect::ends_with("date"),
                  ~ as.POSIXct(.x / 1000, origin = "1970-01-01"))
  ) |>
  tidyr::separate(location, c("latitude", "longitude"), ",") |>
  dplyr::mutate(
    latitude = as.numeric(stringr::str_remove(latitude, "\\(|\\)|,")),
    longitude = as.numeric(stringr::str_remove(longitude, "\\(|\\)|,"))
  ) |>
  dplyr::filter(!is.na(latitude)) |>
  sf::st_as_sf(
    coords = c("longitude", "latitude"),
    crs = 4326,
    remove = FALSE
  ) |>
  sf::st_transform(crs)

  return(citations)
}
