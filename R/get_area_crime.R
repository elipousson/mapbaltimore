#' @title Get area crimes from Open Baltimore
#' @description Get reported crimes since 2014 for a specific area.
#' @param description Crime type or description. Supported options include "AGG.
#'   ASSAULT", "ARSON", "AUTO THEFT", "BURGLARY", "COMMON ASSAULT", "HOMICIDE",
#'   "LARCENY", "LARCENY FROM AUTO", "RAPE", "ROBBERY - CARJACKING", "ROBBERY -
#'   COMMERCIAL", "ROBBERY - RESIDENCE", "ROBBERY - STREET", or "SHOOTING"
#' @param where string for where condition. This parameter is ignored if a
#'   description is provided.
#' @inheritParams get_area_esri_data
#' @examples
#' \dontrun{
#' # Get shootings for the Lauraville area
#' area <- get_area("neighborhood", "Lauraville")
#' crimes <-
#'   get_area_crime(area = area, description = "SHOOTING")
#' }
#' @rdname get_area_crime
#' @export
#' @importFrom glue glue
#' @importFrom dplyr select rename mutate across contains
get_area_crime <- function(area,
                           description = NULL,
                           where = "1=1",
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           trim = FALSE,
                           crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  url <- "https://egis.baltimorecity.gov/egis/rest/services/GeoSpatialized_Tables/Part1_Crime/FeatureServer/0"

  if (!is.null(description)) {
    description_query <- match.arg(
      description,
      c(
        "AGG. ASSAULT", "ARSON", "AUTO THEFT", "BURGLARY", "COMMON ASSAULT", "HOMICIDE",
        "LARCENY", "LARCENY FROM AUTO", "RAPE", "ROBBERY - CARJACKING", "ROBBERY - COMMERCIAL",
        "ROBBERY - RESIDENCE", "ROBBERY - STREET", "SHOOTING"
      )
    )
    description_query <- glue::glue("Description = '{description}'")
    where <- description_query
  }

  crimes <- get_area_esri_data(
    area = area,
    url = url,
    where = where,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    trim = trim,
    crs = crs
  ) |>
    dplyr::select(-c(row_id, geo_location, total_incidents)) |>
    dplyr::rename(geometry = geoms) |>
    dplyr::mutate(
      # Fix date formatting
      dplyr::across(
        dplyr::contains("date"),
        ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
      )
    )

  return(crimes)
}
