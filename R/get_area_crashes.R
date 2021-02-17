
#' Get vehicle crashes for area in Baltimore from Maryland Open Data portal
#' @description Get vehicle crashes for selected area in Baltimore City.
#' @param area \code{\link{sf}} object.
#' @param start_year earliest year of crash data to return.
#' @param end_year latest year of crash data to return. If \code{end_year} is
#'   not provided, only a single year is returned.
#' @param geometry If TRUE, return a sf object. Default FALSE.
#' @param trim If TRUE, data trimmed to area with
#'   \code{\link[sf]{st_intersection}}. Default FALSE.
#' @param type Data type to return. Options include c("crash", "person", "vehicle"). Data types correspond to different tables.
#' @export
#' @importFrom sf st_bbox st_transform st_intersection st_union st_as_sf
#' @importFrom glue glue
#' @importFrom purrr map_dfr
#' @importFrom dplyr left_join
#'
get_area_crashes <- function(area,
                             start_year = 2020,
                             end_year = 2020,
                             geometry = FALSE,
                             trim = FALSE,
                             type = c("crash", "person", "vehicle")) {
  type <- match.arg(type)

  resource <- "65du-s3qu"

  area_bbox <- area %>%
    sf::st_transform(4326) %>%
    sf::st_bbox()

  where_bbox <- glue::glue("(latitude >= {area_bbox$ymin[[1]]}) AND (latitude <= {area_bbox$ymax[[1]]}) AND (longitude >= {area_bbox$xmin[[1]]}) AND (longitude <= {area_bbox$xmax[[1]]})")

  # Get resource
  crashes <- purrr::map_dfr(
    c(start_year:end_year),
    ~ get_maryland_open_resource(
      resource = resource,
      where = glue::glue(
        "(year = '{.x}') AND (county_desc like 'Baltimore City') AND {where_bbox}"
      ),
      geometry = geometry
    )
  )

  # TODO: Move trim into get_maryland_open_resource
  if (trim && geometry) {
    crashes <- sf::st_intersection(crashes, sf::st_union(area))
  }

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

    message("If multiple vehicles or persons are involved in a crash, the data on the crash represented by the unique report number will appear in multiple rows. Use type = 'crash' for a list of crash reports only.")
    return(type_data)
  } else {
    return(crashes)
  }
}
