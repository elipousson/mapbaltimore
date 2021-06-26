#' @title Get area citations
#' @description Get Environmental Control Board (ECB) citations.
#' @param area_type Area type.Options include "neighborhood", "council district", or "police district"
#' @param area_name Area name.
#' @param description String to match to citation description.
#' @inheritParams get_area_esri_data
#' @rdname get_area_citations
#' @export
#' @importFrom snakecase to_any_case
#' @importFrom glue glue
#' @importFrom esri2sf esri2df
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate filter
#' @importFrom tidyr separate
#' @importFrom readr parse_number
#' @importFrom sf st_as_sf st_transform
get_area_citations <- function(area_type = NULL,
                               area_name = NULL,
                               description = NULL,
                               crs = 2804) {
  where <- NULL

  # Currently filter by agency *or* request type - not both
  if (!is.null(area_type)) {
    area_type <- match.arg(area_type, c("neighborhood", "council district", "police district"))
    area_type <- snakecase::to_any_case(area_type, case = "big_camel")
    where <- glue::glue("{area_type} = '{area_name}'")
  }

  if (is.null(where)) {
    where <- "1=1"
  }

  url <- "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/ECB/FeatureServer/0"

  citations <- esri2sf::esri2df(
    url,
    where = where
  ) %>%
    janitor::clean_names("snake") %>%
    dplyr::mutate(
      across(ends_with("date"), ~ as.POSIXct(.x / 1000, origin = "1970-01-01"))
    ) %>%
    tidyr::separate(location, c("lat", "lon"), ",") %>%
    dplyr::mutate(
      lat = readr::parse_number(lat),
      lon = readr::parse_number(lon)
    ) %>%
    dplyr::filter(!is.na(lat)) %>%
    sf::st_as_sf(
      coords = c("lon", "lat"),
      crs = 4326
    ) %>%
    sf::st_transform(crs)

  if (!is.null(description)) {
    select_description <- description
    citations <- citations %>%
      dplyr::filter(str_detect(description, select_description))
  }

  return(citations)
}
