
#' Get Open Street Map features for area
#'
#' Wraps \code{osmdata} functions.
#'
#' @param area sf object. If multiple areas are provided, they are unioned into a single sf object using \code{\link[sf]{st_union()}}
#' @param key feature key for overpass query
#' @param value for feature key; can be negated with an initial exclamation mark, value = "!this", and can also be a vector, value = c ("this", "that").
#' @param osm_return  Character vector length 1 with geometry type to return. Defaults to returning all types.
#' @param trim  Logical. Default FALSE. If TRUE, use the \code{\link[sf]{st_intersection()}} function to trim results to area polygon instead of bounding box.
#' @param crs EPSG code for the coordinate reference system for the plot. Default is 2804. See \url{https://epsg.io/}
#'
#' @export
#'
get_osm_feature <- function(area,
                            key,
                            value,
                            osm_return = c(
                              "osm_points",
                              "osm_lines",
                              "osm_polygons",
                              "osm_multilines",
                              "osm_multipolygons"
                            ),
                            trim = FALSE,
                            crs = 4326) {
  if (!missing(osm_return)) {
    osm_return <- match.arg(osm_return)
  }

  area_bbox <- area %>%
    sf::st_transform(4326) %>%
    sf::st_bbox()

  area_osm_sf <- osmdata::opq(bbox = area_bbox) %>%
    osmdata::add_osm_feature(key = key, value = value) %>%
    osmdata::osmdata_sf()

  if (!missing(osm_return)) {
    area_osm_sf <- purrr::pluck(area_osm_sf, var = osm_return)

    if (trim) {
      area_osm_sf <- area_osm_sf %>%
        sf::st_transform(sf::st_crs(area)) %>%
        sf::st_intersection(area)
    }
  }

  area_osm_sf <- sf::st_transform(area_osm_sf, crs = crs)
  return(area_osm_sf)
}
