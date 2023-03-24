#' @examples
#'
#' md_tracts <- tigris::tracts(state = "MD")
#'
#' @noRd
#' @importFrom sf st_intersects st_drop_geometry st_as_sf
#' @importFrom getdata get_esri_data
#' @importFrom sfext st_transform_ext
get_baltimore_worker_flows <- function(area,
                                       tracts = baltimore_tracts,
                                       min_estimate = 10,
                                       geometry = TRUE,
                                       crs = 2804) {
  tracts <- janitor::clean_names(tracts, "snake")

  area_tracts <-
    tracts[lengths(sf::st_intersects(tracts, area)) > 0, ]

  area_tracts <- sf::st_drop_geometry(area_tracts)

  flow_to <- "https://gis.baltometro.org/arcgis/rest/services/Census/CTPP1216_flows/MapServer/5"

  flow_to <- getdata::get_esri_data(
    url = flow_to,
    where = paste0("WP_FIPS = ", paste0("'", area_tracts$geoid, "'"), collapse = " OR ", recycle0 = TRUE)
  )

  flow_from <- "https://gis.baltometro.org/arcgis/rest/services/Census/CTPP1216_flows/MapServer/5"

  flow_from <- getdata::get_esri_data(
    url = flow_from,
    where = paste0("RES_FIPS = ", paste0("'", area_tracts$geoid, "'"), collapse = " OR ", recycle0 = TRUE)
  )

  if (!geometry) {
    return(
      list(
        "to" = flow_to,
        "from" = flow_from
      )
    )
  }

  flow_from <- dplyr::filter(
    flow_from,
    wp_fips %in% tracts$geoid,
    est >= min_estimate
  )

  flow_from <- dplyr::left_join(flow_from, tracts, by = c("wp_fips" = "geoid"))

  flow_to <- dplyr::filter(
    flow_to,
    res_fips %in% tracts$geoid,
    est >= min_estimate
  )

  flow_to <- dplyr::left_join(flow_to, tracts, by = c("res_fips" = "geoid"))

  list(
    "to" = sfext::st_transform_ext(sf::st_as_sf(flow_to), crs),
    "from" = sfext::st_transform_ext(sf::st_as_sf(flow_from), crs)
  )
}
