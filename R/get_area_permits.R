#' @title Get area building permits from Open Baltimore
#' @description Get building permits from 2019 through the present.
#' @param year Year. Must be 2019 or later.
#' @param permit_type Optional. Supported values include "USE", "DEM", "COM", or
#'   "BMZ".
#' @param where string for where condition. permit_type and year are ignored if
#'   a custom `where` is provided. Set where to "1=1" to return data for all
#'   years since 2019.
#' @inheritParams get_area_esri_data
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom dplyr case_when mutate across select rename
#' @importFrom usethis ui_stop
#' @importFrom glue glue
#' @importFrom stringr str_trim
#' @importFrom tidyselect ends_with
get_area_permits <- function(area,
                             year = 2021,
                             permit_type = NULL,
                             where = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             asp = NULL,
                             trim = FALSE,
                             crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  if (year >= 2019) {
    url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/3"
  } else if (is.null(year)) {
    url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/3"
  } else {
    usethis::ui_stop("Open Baltimore does not currently provide any permit data for years prior to 2019.")
  }

  if (is.null(where)) {
    where <- glue::glue("IssuedDate BETWEEN DATE '{year}-01-01' AND DATE '{year}-12-31'")

    if (!is.null(permit_type)) {
      permit_type <- match.arg(permit_type, c("USE", "DEM", "COM", "BMZ"))
      query <- glue::glue("CaseNumber LIKE '{permit_type}%'")
      where <- paste0(where, " AND ", query)
    }
  }

  permits <- get_area_esri_data(
    area = area,
    url = url,
    where = where,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    trim = trim,
    crs = crs
  ) |>
    dplyr::mutate(
      dplyr::across(
        where(is.character),
        ~ stringr::str_trim(.x)
      ),
      dplyr::across(
        tidyselect::ends_with("date"),
        ~ as.POSIXct(.x / 1000, origin = "1970-01-01")
      )
    ) |>
    dplyr::select(
      - c(objectid, esri_oid)
    ) |>
    dplyr::rename(
      hmt_cluster = housing_market_typology2017,
      block = prc_block_no,
      lot = prc_lot,
      geometry = geoms
    )

  return(permits)
}
