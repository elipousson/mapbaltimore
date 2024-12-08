#' Get data from an ArcGIS FeatureServer or MapServer
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [getdata::get_esri_data()] function which uses a similar
#' set of parameters.
#'
#' Wraps the [esri2sf::esri2sf()] function to download an ArcGIS
#' FeatureServer or MapServer.
#'
#' @param area `sf` object. Optional. Only used if trim is TRUE.
#' @param bbox `bbox` object. Optional but suggested to avoid downloading
#'   entire layer. See [sf::st_bbox()] for more information.
#' @param url FeatureServer or MapServer url to retrieve data from. Passed to
#'   `url` parameter of [esri2sf::esri2sf()] function.
#' @param type Type of data to get. Options include "md food stores 2017 2018",
#'   "farmers markets 2020", "baltimore food stores 2016", "baltimore
#'   demolitions", "contour 2ft", "contours 10ft", "open vacant building
#'   notices", "liquor licenses", "fixed speed cameras", "red light cameras",
#'   and "edge of pavement"
#' @param where string for where condition. Default is 1=1 for all rows.
#' @param trim Logical. Default `FALSE`. If `TRUE`, area is required.
#' @param crs Coordinate reference system. Default 2804.
#' @inheritParams adjust_bbox
#' @keywords internal
#' @export
#' @importFrom dplyr filter pull
#' @importFrom janitor clean_names
#' @importFrom sf st_transform st_intersection
get_area_esri_data <- function(area = NULL,
                               bbox = NULL,
                               url = NULL,
                               where = "1=1",
                               type = c("md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", "edge of pavement"),
                               dist = NULL,
                               diag_ratio = NULL,
                               asp = NULL,
                               trim = FALSE,
                               crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  lifecycle::deprecate_warn("0.1.2", "get_area_esri_data()", "getdata::get_esri_data()")

  # Load data index (esri sources is the only one available now)
  data_index <- esri_sources

  if (is.null(url)) {
    # Get URL for FeatureServer or MapServer from internal esri_sources data
    url <- data_index %>%
      dplyr::filter(slug == gsub(" ", "_", type)) %>%
      dplyr::pull(url)
  }

  # Get spatial data as sf using bbox or area
  if (!is.null(bbox) | !is.null(area)) {
    # Adjust bounding box
    bbox <- getdata::get_esri_data(
      url = url,
      location = bbox %||% area,
      where = where,
      crs = crs
    )
  } else {
    data <- getdata::get_esri_data(
      url = url,
      where = where
    )
  }

  # Optionally trim to area
  if (trim & !is.null(area)) {
    data <- data %>%
      sf::st_intersection(area)
  }

  return(data)
}
