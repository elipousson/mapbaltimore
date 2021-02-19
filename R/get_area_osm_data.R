
#' Get Open Street Map features for area
#'
#' Wraps \code{osmdata} functions.
#'
#' @param area sf object. If multiple areas are provided, they are unioned into
#'   a single sf object using \code{\link[sf]{st_union}}
#' @param key feature key for overpass query
#' @param value for feature key; can be negated with an initial exclamation
#'   mark, value = "!this", and can also be a vector, value = c ("this",
#'   "that").
#' @param return_type  Character vector length 1 with geometry type to return.
#'   Defaults to returningpolygons. Set to NULL to return all types.
#' @param trim  Logical. Default FALSE. If TRUE, use the
#'   \code{\link[sf]{st_intersection}} function to trim results to area polygon
#'   instead of bounding box.
#' @param crs EPSG code for the coordinate reference system for the plot.
#'   Default is 2804. See \url{https://epsg.io/} for more information.
#' @inheritParams adjust_bbox
#' @export
#' @importFrom sf st_transform st_bbox st_intersection
#' @importFrom osmdata opq add_osm_feature osmdata_sf
#' @importFrom purrr pluck
get_area_osm_data <- function(area = NULL,
                              bbox = NULL,
                            key,
                            value,
                            return_type = c(
                              "osm_polygons",
                              "osm_points",
                              "osm_lines",
                              "osm_multilines",
                              "osm_multipolygons"
                            ),
                            dist = NULL,
                            diag_ratio = NULL,
                            asp = NULL,
                            trim = FALSE,
                            crs = 2804) {

  if (!is.null(return_type)) {
    return_type <- match.arg(return_type)
  }

  osm_crs <- 4326

  # Get adjusted bounding box if any adjustment variables provided
  if (!is.null(dist) | !is.null(diag_ratio) | !is.null(asp)) {
    bbox <- adjust_bbox(
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crs = osm_crs
    )
  } else if (!is.null(area)) {
    bbox <- area %>%
      sf::st_transform(osm_crs) %>%
      sf::st_bbox()
  }

  data <- osmdata::opq(bbox = bbox) %>%
    osmdata::add_osm_feature(key = key, value = value) %>%
    osmdata::osmdata_sf()

  if (!is.null(return_type)) {
    data <- purrr::pluck(data, var = return_type)
  }

  data <- sf::st_transform(data, crs = crs)

  if (trim && !is.null(area)) {
    data <- sf::st_intersection(data, area)
  }

  return(data)
}
