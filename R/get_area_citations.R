#' @title Get area citations
#' @description Get Environmental Control Board (ECB) citations.
#' @param area_type Area type. Requires area_name is also provided. Options include "neighborhood", "council district", or "police district"
#' @param area_name Area name.Requires area_type is also provided.
#' @param description String to filter returned citations, e.g. "SIGNS" filters citations to "PROHIBITED POSTING OF SIGNS ON PUBLIC PROPERTY"
#' @param where string for where condition. Ignore where condition if area_type and area_name are provided.
#' @inheritParams get_area_esri_data
#' @rdname get_area_citations
#' @export
#' @importFrom snakecase to_any_case
#' @importFrom stringr str_remove str_trim
#' @importFrom glue glue
#' @importFrom esri2sf esri2df
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate across filter
#' @importFrom tidyselect ends_with
#' @importFrom tidyr separate
#' @importFrom readr parse_number
#' @importFrom sf st_as_sf st_transform
get_area_citations <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               where = "1=1",
                               crs = 2804) {

    # Currently filter by agency *or* request type - not both
    if (!is.null(area_type)) {
      area_type <- match.arg(area_type, c("neighborhood", "council district", "police district"))
      area_type <- snakecase::to_any_case(area_type, case = "big_camel")

      if (area_type == "CouncilDistrict") {
        area_name <- stringr::str_remove(area_name, "District") |>
        stringr::str_trim()
      }

      where <- glue::glue("{area_type} = '{area_name}'")
    }

  url <- "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/ECB/FeatureServer/0"

  citations <- esri2sf::esri2df(
    url = url,
    where = where
  ) |>
  janitor::clean_names("snake") |>
  dplyr::mutate(
    dplyr::across(tidyselect::ends_with("date"), ~ as.POSIXct(.x / 1000, origin = "1970-01-01"))
  ) |>
  tidyr::separate(location, c("lat", "lon"), ",") |>
  dplyr::mutate(
    lat = readr::parse_number(lat),
    lon = readr::parse_number(lon)
  ) |>
  dplyr::filter(!is.na(lat)) |>
  sf::st_as_sf(
    coords = c("lon", "lat"),
    crs = 4326
  ) |>
  sf::st_transform(crs)

  if (!is.null(description)) {
    select_description <- description
    citations <- citations |>
    dplyr::filter(str_detect(description, select_description))
  }

  return(citations)
}
