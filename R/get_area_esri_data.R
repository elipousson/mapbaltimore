#' Get data from an ArcGIS FeatureServer or MapServer
#'
#' Wraps the `esri2sf::esri2sf()` function to download an ArcGIS FeatureServer or MapServer.
#' Some of the data (e.g. Liquor Licenses) is missing data important data.
#'
#' @param area `sf` object. Optional. Only used if trim is TRUE.
#' @param bbox `bbox` object. Optional but suggested to avoid downloading entire layer. See `sf::st_bbox()` for more information.
#' @param url FeatureServer or MapServer url to retrieve data from. Passed to `url` parameter of `esri2sf::esri2sf()` function.
#' @param type Type of data to get. Options include "md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", and "edge of pavement"
#' @param trim Logical. Default `FALSE.` If `TRUE`, area is required.
#' @param crs Coordinate reference system. Default 2804.
#' @export
#' @importFrom esri2sf esri2sf
#' @importFrom dplyr filter pull rename
#' @importFrom sf st_bbox st_transform st_intersection
#' @importFrom janitor clean_names
get_area_esri_data <- function(area = NULL,
                               bbox = NULL,
                               url = NULL,
                               type = c("md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", "edge of pavement"),
                               trim = FALSE,
                               crs = 2804) {

  # Convert type into unqiue slug
  type <- gsub(" ", "_", type)

  if (is.null(url)) {
    # Get URL for FeatureServer or MapServer from internal esri_sources data
    esri_url <- esri_sources %>%
      dplyr::filter(slug == type) %>%
      dplyr::pull(url)
  } else {
    esri_url <- url
  }

  # Get bbox if area is provided
  if (!is.null(area)) {
    bbox <- sf::st_bbox(area)
  }

  # Get spatial data as sf using bbox if provided
  if (is.null(bbox)) {
    esri_data <- esri2sf::esri2sf(url = esri_url)
  } else if (class(bbox) == "bbox") {
    esri_data <- esri2sf::esri2sf(url = esri_url, bbox = bbox)
  } else {
    stop("The value for bbox is not a class 'bbox' object. Use sf::st_bbox() to create the bbox.")
  }

  # Rename geometry field
  esri_data <- esri_data %>%
    janitor::clean_names("snake") %>%
    dplyr::rename(geometry = geoms) %>%
    sf::st_transform(crs)

  # Optionally trim to area
  if (trim & !is.null(area)) {
    esri_data <- esri_data %>%
      sf::st_intersection(area)
  } else if (trim) {
    warning("trim is TRUE but no area is provided so the data is not trimmed.")
  }

  return(esri_data)
}
