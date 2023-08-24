#' Get Baltimore metro area worker flows from the Census Transportation Planning
#' data (2012-2016 ACS)
#'
#' Use FeatureLayers provided by the Baltimore Metropolitan Council.
#'
#' @param area A sf or sfc object that intersects with tracts.
#' @param tracts Data from [tigris::tracts()] for one or more county in the
#'   Balitmore metro area. Defaults to `baltimore_tracts`.
#' @param min_estimate Minimum number of workers or residents a tract must have
#'   to include in results. Tracts with fewer than the min_estimate values are
#'   filtered out of results. Defaults to 10.
#' @param geometry If `TRUE`, return a list of sf objects. If `FALSE`, return a
#'   list of data.frame objects. Defaults to `TRUE`.
#' @param crs Coordinate reference system to use for returned data when
#'   `geometry = TRUE`. Defaults to 2804.
#' @returns A list of two data.frames or sf objects named "to" and "from".
#' @export
#' @importFrom sf st_intersects st_drop_geometry st_as_sf
#' @importFrom getdata get_esri_data
#' @importFrom sfext st_transform_ext
get_baltimore_worker_flows <- function(area,
                                       tracts = baltimore_tracts,
                                       min_estimate = 10,
                                       geometry = TRUE,
                                       crs = 2804) {
  tracts <- janitor::clean_names(
    sf::st_transform(tracts, crs = sf::st_crs(area)),
    "snake"
    )

  area_tracts <- tracts[lengths(sf::st_intersects(tracts, area)) > 0, ]

  area_tracts <- sf::st_drop_geometry(area_tracts)

  area_geoid <- area_tracts[["geoid"]]

  flow_to <- "https://gis.baltometro.org/arcgis/rest/services/Census/CTPP1216_flows/MapServer/5"

  flow_to <- getdata::get_esri_data(
    url = flow_to,
    where = paste0("WP_FIPS = ", paste0("'", area_geoid, "'"), collapse = " OR ", recycle0 = TRUE)
  )

  flow_from <- "https://gis.baltometro.org/arcgis/rest/services/Census/CTPP1216_flows/MapServer/5"

  flow_from <- getdata::get_esri_data(
    url = flow_from,
    where = paste0("RES_FIPS = ", paste0("'", area_geoid, "'"), collapse = " OR ", recycle0 = TRUE)
  )

  if (!geometry) {
    return(
      list(
        "to" = flow_to,
        "from" = flow_from
      )
    )
  }

  wp_fips_in_city <- flow_from[["wp_fips"]] %in% tracts[["geoid"]]
  res_fips_in_city <- flow_to[["res_fips"]] %in% tracts[["geoid"]]
  n_excluded_wp <- length(flow_from[["wp_fips"]]) - length(wp_fips_in_city)
  n_excluded_res <- length(flow_to[["res_fips"]]) - length(res_fips_in_city)

  if (n_excluded_wp > 0) {
    cli::cli_alert_info(
      "No corresponding GeoID in {.arg tracts} for {n_excluded} workplace tract{s} for residents."
    )
  }

  if (n_excluded_res > 0) {
    cli::cli_alert_info(
      "No corresponding GeoID in {.arg tracts} for {n_excluded} residence tract{s} for workers."
    )
  }

  flow_from <- dplyr::filter(
    flow_from,
    wp_fips %in% tracts[["geoid"]],
    est >= min_estimate
  )

  flow_from <- dplyr::left_join(flow_from, tracts, by = c("wp_fips" = "geoid"))

  flow_to <- dplyr::filter(
    flow_to,
    res_fips %in% tracts[["geoid"]],
    est >= min_estimate
  )

  flow_to <- dplyr::left_join(flow_to, tracts, by = c("res_fips" = "geoid"))

  list(
    "to" = sfext::st_transform_ext(sf::st_as_sf(flow_to), crs),
    "from" = sfext::st_transform_ext(sf::st_as_sf(flow_from), crs)
  )
}
