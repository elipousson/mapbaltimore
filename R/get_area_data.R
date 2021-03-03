
#' Get local or cached data for an area
#'
#' Returns data for a selected area or areas with an optional buffer. If both
#' crop and trim are FALSE, the function uses \code{\link[sf]{st_intersects}} to
#' filter data to include the full geometry of anything that overlaps with the
#' area or bbox (if the area is not provided).
#'
#' @param area \code{sf} object. If multiple areas are provided, they are unioned
#'   into a single sf object using \code{\link[sf]{st_union}}
#' @param data \code{sf} object including data in area
#' @param bbox \code{bbox} object defining area used to filter data. If an area is
#'   provided, the bounding box is ignored.
#' @param extdata Character. Name of an external geopackage (.gpkg) file
#'   included with the package where selected data is available. Available data
#'   includes "trees", "unimproved_property", and "vegetated_area"
#' @param cachedata Character. Name of a cached geopackage (.gpkg) file where
#'   selected data is available. Running \code{cache_mapbaltimore_data()} caches
#'   data for "real_property", "baltimore_msa_streets", and "edge_of_pavement"
#' @param path Character. Path to local or remote spatial data file supported by
#'   \code{\link[sf]{st_read}}
#' @inheritParams adjust_bbox
#' @param crop  If TRUE, data cropped to area or bounding box
#'   \code{\link[sf]{st_crop}} adjusted by the `dist`, `diag_ratio`, and `asp`
#'   provided. Default \code{TRUE}.
#' @param trim  If TRUE, data trimmed to area with
#'   \code{\link[sf]{st_intersection}}. This option is not supported for any
#'   adjusted areas that use the `dist`, `diag_ratio`, or `asp` parameters.
#'   Default \code{FALSE}.
#' @param crs Coordinate Reference System (CRS) to use for the returned data.
#'   The CRS of the provided data and bounding box or area must match one
#'   another but are not required to match the CRS provided by this parameter.
#'
#' @export
#' @importFrom sf st_union st_as_sf st_bbox st_as_sfc st_as_text st_read
#'   st_intersection st_join st_crop st_transform st_intersects
#' @importFrom dplyr rename filter select
#' @importFrom tibble add_column
#' @importFrom rlang as_function
get_area_data <- function(area = NULL,
                          bbox = NULL,
                          data = NULL,
                          extdata = NULL,
                          cachedata = NULL,
                          path = NULL,
                          url = NULL,
                          .f = NULL,
                          diag_ratio = NULL,
                          dist = NULL,
                          asp = NULL,
                          crop = TRUE,
                          trim = FALSE,
                          crs = NULL) {

  if (!is.null(area) && (nrow(area) > 1)) {
    area <- area %>%
      sf::st_union() %>%
      sf::st_as_sf()
  }

  # Get adjusted bounding box using any adjustment variables provided
  bbox <- adjust_bbox(
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp
    )

  # Get data from extdata or cached folder if filename is provided
  if (!is.null(extdata) | !is.null(cachedata) | !is.null(path)) {

    # Convert bbox to well known text
    area_wkt_filter <- bbox %>%
      sf::st_as_sfc() %>% # Convert to sfc
      sf::st_as_text()

    # Set path to external or cached data
    if (!is.null(extdata)) {
      path <- system.file("extdata", paste0(extdata, ".gpkg"), package = "mapbaltimore")
    } else if (!is.null(cachedata)) {
      path <- paste0(rappdirs::user_cache_dir("mapbaltimore"), "/", cachedata, ".gpkg")
    }

    # Read external, cached, or data at path with wkt_filter
    data <- sf::st_read(
      dsn = path,
      wkt_filter = area_wkt_filter
    )
  } else if (!is.null(url)) {
    # get_area_esri_data returns CRS 2804 by default
    data <- get_area_esri_data(
      bbox = bbox,
      url = url)
  }

  if (crop && !trim) {
    data <- sf::st_crop(data, bbox)
  } else if (trim && !is.null(area)) {
    data <- sf::st_intersection(data, area)
  } else {
    if (is.null(area)) {
      # Convert bbox back to sf object
      area <- bbox %>%
        sf::st_as_sfc() %>%
        sf::st_as_sf()
    }

    data <- data[lengths(sf::st_intersects(data, area)) > 0, ]
  }

  if (!is.null(.f)) {
    f <- rlang::as_function(.f)
    data <- f(data)
  }

  if (!is.null(crs)) {
    data <- sf::st_transform(data, crs)
  }

  return(data)
}
