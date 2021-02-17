
#' Get local or cached data for an area
#'
#' Returns data for a selected area or areas with an optional buffer. If both
#' crop and trim are FALSE, the function uses \code{\link[sf]{st_join}} to
#' return provided data without any changes to geometry.
#'
#' @param area `sf` object. If multiple areas are provided, they are unioned
#'   into a single sf object using \code{\link[sf]{st_union}}
#' @param data `sf` object including data in area
#' @param bbox `bbox` object defining area used to filter data. If an area is
#'   provided, the bounding box is ignored.
#' @param extdata Character. Name of an external geopackage (.gpkg) file
#'   included with the package where selected data is available. Available data
#'   includes "trees", "unimproved_property", and "vegetated_area"
#' @param cachedata Character. Name of a cached geopackage (.gpkg) file where
#'   selected data is available. Running \code{cache_mapbaltimore_data()} caches data
#'   for "real_property", "baltimore_msa_streets", and "edge_of_pavement"
#' @inheritParams adjust_bbox
#' @param crop  If TRUE, data cropped to area or bounding box
#'   \code{\link[sf]{st_crop}} adjusted by the `dist`, `diag_ratio`, and `asp`
#'   provided. Default `TRUE`.
#' @param trim  If TRUE, data trimmed to area with
#'   \code{\link[sf]{st_intersection}}. This option is not supported for any
#'   adjusted areas that use the `dist`, `diag_ratio`, or `asp` parameters.
#'   Default `FALSE`.
#' @param crs Coordinate Reference System (CRS) to use for the returned data.
#'   The CRS of the provided data and bounding box or area must match one
#'   another but are not required to match the CRS provided by this parameter.
#'
#' @export
#' @importFrom sf st_union st_as_sf st_bbox st_as_sfc st_as_text st_read
#'   st_intersection st_join st_crop st_transform
#' @importFrom dplyr rename filter select
#' @importFrom tibble add_column
get_area_data <- function(area = NULL,
                          bbox = NULL,
                          data = NULL,
                          extdata = NULL,
                          cachedata = NULL,
                          diag_ratio = NULL,
                          dist = NULL,
                          asp = NULL,
                          crop = TRUE,
                          trim = FALSE,
                          crs = NULL) {

  if (!is.null(area) && length(area$geometry) > 1) {
    # Collapse multiple areas into a single geometry
    area_name <- paste(area$name, collapse = " & ")

    area <- area %>%
      sf::st_union() %>%
      sf::st_as_sf() %>%
      dplyr::rename(geometry = x)

    area$name <- area_name
  }

  # Get adjusted bounding box if any adjustment variables provided
  if (!is.null(dist) | !is.null(diag_ratio) | !is.null(asp)) {
    bbox <- adjust_bbox(
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp
    )
  } else {
    bbox <- sf::st_bbox(area)
  }

  # Get data from extdata or cached folder if filename is provided
  if (!is.null(extdata) | !is.null(cachedata)) {

    # Convert bbox to well known text
    area_wkt_filter <- bbox %>%
      sf::st_as_sfc() %>% # Convert to sfc
      sf::st_as_text()

    # Set path to external or cached data
    if (!is.null(extdata)) {
      path <- system.file("extdata", paste0(extdata, ".gpkg"), package = "mapbaltimore")
    } else {
      path <- paste0(rappdirs::user_cache_dir("mapbaltimore"), "/", cachedata, ".gpkg")
    }

    data <- sf::st_read(path,
      wkt_filter = area_wkt_filter
    )
  }

  if (crop) {
    data <- sf::st_crop(data, bbox)
  } else if (!is.null(area)) {
    if (trim) {
      data <- sf::st_intersection(data, area)
    } else {
      area <- dplyr::rename(area, area_name = name)

      # Join area to data
      data <- data %>%
        sf::st_join(area) %>%
        dplyr::filter(!is.na(area_name)) %>%
        dplyr::select(-area_name)
    }
  } else if (!is.null(bbox)) {
    # Convert bbox to sf object
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf() %>%
      tibble::add_column(area_name = "name")

    # Join to data
    data <- data %>%
      sf::st_join(area) %>%
      dplyr::filter(!is.na(area_name)) %>%
      dplyr::select(-area_name)

    # Warn user that the option for trim is ignored when a bbox is provided w/ no area
    if (trim) {
      warning("trim = TRUE is ignored when using the bbox parameter and no area parameter.")
    }
  }

  if (!is.null(crs)) {
    data <- sf::st_transform(data, crs)
  }

  return(data)
}
