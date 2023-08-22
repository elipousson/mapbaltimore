#' Get area crimes from Open Baltimore
#'
#' Get reported crimes since 2014 for a specific area.
#'
#' @param area sf, sfc, or bbox object. If multiple areas are provided, they are
#'   unioned into a single sf object using [sf::st_union()].
#' @param description Crime type or description. Supported options include "AGG.
#'   ASSAULT", "ARSON", "AUTO THEFT", "BURGLARY", "COMMON ASSAULT", "HOMICIDE",
#'   "LARCENY", "LARCENY FROM AUTO", "RAPE", "ROBBERY - CARJACKING", "ROBBERY -
#'   COMMERCIAL", "ROBBERY - RESIDENCE", "ROBBERY - STREET", or "SHOOTING"
#' @inheritParams getdata::get_esri_data
#' @param date_range Date range as character vector in format of c("YYYY-MM-DD",
#'   "YYYY-MM-DD"). Minimum and maximum values are used if length is greater
#'   than 1.
#' @inheritParams sfext::st_filter_ext
#' @examples
#' \dontrun{
#' # Get shootings for the Lauraville area
#' area <- get_area("neighborhood", "Barclay")
#' crimes <- get_area_crime(
#'   area = area,
#'   date_range = c("2022-01-01", "2022-12-31"),
#'   description = "SHOOTING"
#' )
#' }
#' @export
#' @importFrom glue glue
#' @importFrom dplyr select rename mutate across contains
#' @importFrom getdata between_date_range glue_ansi_sql get_esri_data
get_area_crime <- function(area,
                           description = NULL,
                           date_range = NULL,
                           where = NULL,
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           unit = "m",
                           trim = FALSE,
                           crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  # url <- "https://egis.baltimorecity.gov/egis/rest/services/GeoSpatialized_Tables/Part1_Crime/FeatureServer/0"
  # url <- "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables/part1_Crime_1/FeatureServer/0"
  url <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/Part1_Crime_Beta/FeatureServer/0"

  date_query <- NULL
  description_query <- NULL

  if (!is.null(date_range)) {
    date_query <- getdata::between_date_range(
      date_range,
      .col = "CrimeDateTime"
    )
  }

  if (!is.null(description)) {
    description <- arg_match(
      description,
      c(
        "AGG. ASSAULT", "ARSON", "AUTO THEFT", "BURGLARY", "COMMON ASSAULT",
        "HOMICIDE", "LARCENY", "LARCENY FROM AUTO", "RAPE",
        "ROBBERY - CARJACKING", "ROBBERY - COMMERCIAL",
        "ROBBERY - RESIDENCE", "ROBBERY - STREET", "SHOOTING"
      ),
      multiple = TRUE
    )

    description_query <- getdata::glue_ansi_sql("Description", " IN ({description*})")
  }

  if (!all(is.null(c(date_query, description_query)))) {
    where <- paste0(c(where, date_query, description_query), collapse = " AND ")
  }

  crimes <- getdata::get_esri_data(
      location = area,
      url = url,
      coords = c("longitude", "latitude"),
      where = where,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = unit,
      asp = asp,
      trim = trim,
      crs = crs
    )

  crimes %>%
    dplyr::select(-dplyr::any_of(c("row_id", "geo_location", "total_incidents"))) %>%
    sfext::rename_sf_col() %>%
    getdata::fix_epoch_date()
}
