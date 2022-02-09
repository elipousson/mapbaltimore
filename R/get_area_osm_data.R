
#' Get Open Street Map features for area
#'
#' Wraps \code{osmdata} functions.
#'
#' @param area sf object. If multiple areas are provided, they are unioned into
#'   a single sf object using \code{\link[sf]{st_union}}
#' @param key feature key for overpass query. If key is "building" and value is
#'   NULL, a preset list of tag values will be used to return all available
#'   buildings in the bounding box.
#' @param value for feature key; can be negated with an initial exclamation
#'   mark, value = "!this", and can also be a vector, value = c ("this",
#'   "that").
#' @param return_type  Character vector length 1 with geometry type to return.
#'   Defaults to returningpolygons. Set to NULL to return all types.
#' @param crop Logical. Default TRUE. If TRUE, use the \code{\link[sf]{st_crop}}
#'   to trim results to area bounding box.
#' @param trim  Logical. Default FALSE. If TRUE, use the
#'   \code{\link[sf]{st_intersection}} function to trim results to area polygon.
#' @param crs EPSG code for the coordinate reference system for the plot.
#'   Default is 2804. See \url{https://epsg.io/} for more information.
#' @inheritParams adjust_bbox
#' @export
#' @importFrom sf st_as_sfc st_as_sf st_transform st_crop st_intersection
#' @importFrom osmdata opq add_osm_feature osmdata_sf
#' @importFrom purrr pluck
get_area_osm_data <- function(area = NULL,
                              bbox = NULL,
                              key,
                              value = NULL,
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
                              crop = TRUE,
                              trim = FALSE,
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  if (!is.null(return_type)) {
    return_type <- match.arg(return_type)
  }

  # Get adjusted bounding box if any adjustment variables provided
  bbox <- adjust_bbox(
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crs = crs
    )

  crs_osm <- 4326

  bbox_osm <- bbox %>%
    sf::st_as_sfc() %>%
    sf::st_as_sf() %>%
    sf::st_transform(crs_osm)

  if (key == "building" && is.null(value)) {
    value <- c("terrace", "yes", "garage", "house", "commercial", "library", "post_office", "university", "parking", "hospital", "central_office", "school", "church", "industrial", "apartments", "civic", "retail", "roof", "pavilion", "dormitory")
  }

  data <- osmdata::opq(bbox = bbox_osm) %>%
    osmdata::add_osm_feature(key = key, value = value) %>%
    osmdata::osmdata_sf()

  if (!is.null(return_type)) {
    data <- purrr::pluck(data, var = return_type)

    data <- sf::st_transform(data, crs = crs)

    if (crop && !trim) {
      data <- sf::st_crop(data, bbox)
    } else if (trim && !is.null(area)) {
      data <- sf::st_intersection(data, area)
    }

  } else {
    message("When returning all geometry types, the data is not transformed to the default CRS and remains in EPSG:4326.")
  }

  message("Open Street Map data is available under the Open Database Licence which requires attribution. See https://www.openstreetmap.org/copyright for more information.")
  return(data)
}
