#' Get area building permits from Open Baltimore
#'
#'  Get building permits from 2019 through the present.
#'
#' @param area sf, sfc, or bbox object. If multiple areas are provided, they are
#'   unioned into a single sf object using [sf::st_union()].
#' @param year Year. Must be 2019 or later.
#' @param permit_type Optional. Supported values include "USE", "DEM", "COM", or
#'   "BMZ".
#' @param where string for where condition. permit_type and year are ignored if
#'   a custom `where` is provided. Set where to "1=1" to return data for all
#'   years since 2019.
#' @inheritParams getdata::get_esri_data
#' @param date_range Date range as character vector in format of c("YYYY-MM-DD",
#'   "YYYY-MM-DD"). Minimum and maximum values are used if length is greater
#'   than 1.
#' @inheritParams sfext::st_filter_ext
#' @param ... Additional parameters passed to [getdata::get_esri_data()].
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom cli cli_abort
#' @importFrom getdata between_date_range get_esri_data str_trim_squish_across
#'   fix_epoch_date
#' @importFrom glue glue
#' @importFrom dplyr select rename
#' @importFrom tidyselect any_of
#' @importFrom sfext rename_sf_col
#' @importFrom rlang `%||%`
get_area_permits <- function(area,
                             year = 2022,
                             date_range = NULL,
                             permit_type = NULL,
                             where = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             unit = "m",
                             asp = NULL,
                             trim = FALSE,
                             crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                             ...) {
  year <- year %||% pkgconfig::get_config("mapbaltimore.current_year", 2022)

  url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/3"

  if (year < 2019) {
    cli::cli_abort(
      "Permits for {.arg year} {.val {year}} are not available from Open Baltimore."
    )
  }

  if (is.null(where)) {
    where <- getdata::between_date_range(date_range, .col = "IssuedDate", year = year)

    if (!is.null(permit_type)) {
      permit_type <- match.arg(permit_type, c("USE", "DEM", "COM", "BMZ"))
      query <- glue("(CaseNumber LIKE '{permit_type}%')")
      where <- paste0(where, " AND ", query)
    }
  }

  permits <- getdata::get_esri_data(
    location = area,
    url = url,
    where = where,
    dist = dist,
    diag_ratio = diag_ratio,
    unit = unit,
    asp = asp,
    crs = crs,
    ...
  )

  if (!is_installed("arcgislayers")) {
    permits <- permits %>%
      getdata::fix_epoch_date()
  }

  permits %>%
    getdata::str_trim_squish_across() %>%
    dplyr::select(-tidyselect::any_of(c("objectid", "esri_oid"))) %>%
    dplyr::rename(
      hmt_cluster = housing_market_typology2017,
      block = prc_block_no,
      lot = prc_lot
    ) %>%
    sfext::rename_sf_col()
}
