#' Get local or cached data for an area
#'
#' Returns data for a selected area or areas with an optional buffer. If both
#' crop and trim are FALSE, the function uses [sf::st_intersects()] to
#' filter data to include the full geometry of anything that overlaps with the
#' area or bbox (if the area is not provided).
#'
#' @param area `sf` object. If multiple areas are provided, they are unioned
#'   into a single sf object using [sf::st_union()]
#' @param data `sf` object including data in area
#' @param bbox `bbox` object defining area used to filter data. If an area is
#'   provided, the bounding box is ignored.
#' @param extdata Character. Name of an external geopackage (.gpkg) file
#'   included with the package where selected data is available. Available data
#'   includes "trees", "unimproved_property", and "vegetated_area"
#' @param cachedata Character. Name of a cached geopackage (.gpkg) file where
#'   selected data is available. Running `cache_mapbaltimore_data()` caches
#'   data for "real_property", "baltimore_msa_streets", and "edge_of_pavement"
#' @param path Character. Path to local or remote spatial data file supported by
#'   [sf::st_read()]
#' @param url Character. URL for FeatureServer or MapServer layer to pass to get_area_esri_data.
#' @param fn Function to apply to area data before returning.
#' @inheritParams adjust_bbox
#' @param crop  If TRUE, data cropped to area or bounding box
#'   [sf::st_crop()] adjusted by the `dist`, `diag_ratio`, and `asp`
#'   parameters provided. Default `TRUE`.
#' @param trim  If TRUE, data trimmed to area with
#'   [sf::st_intersection()]. This option is not supported for any
#'   adjusted areas that use the `dist`, `diag_ratio`, or `asp` parameters.
#'   Default `FALSE`.
#' @param crs Coordinate Reference System (CRS) to use for the returned data.
#'   The CRS of the provided data and bounding box or area must match one
#'   another but are not required to match the CRS provided by this parameter.
#'
#' @export
#' @importFrom sf st_union st_as_sf st_as_sfc st_as_text st_read st_crop st_intersection st_filter st_transform
#' @importFrom rappdirs user_cache_dir
#' @importFrom stringr str_detect
#' @importFrom rlang as_function
get_area_data <- function(area = NULL,
                          bbox = NULL,
                          data = NULL,
                          extdata = NULL,
                          cachedata = NULL,
                          path = NULL,
                          url = NULL,
                          fn = NULL,
                          diag_ratio = NULL,
                          dist = NULL,
                          asp = NULL,
                          crop = TRUE,
                          trim = FALSE,
                          crs = NULL) {
  if (!is.null(area)) {
    if (nrow(area) > 1) {
      area <- area %>%
        sf::st_union() %>%
        sf::st_as_sf()
    }
  }

  # Get adjusted bounding box using any adjustment variables provided
  bbox <- adjust_bbox(
    area = area,
    bbox = bbox,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp
  )


  # Temporary function while moving to deprecate extdata and cachedata parameters
  if (!is.null(extdata)) {
    path <- system.file("extdata", paste0(extdata, ".gpkg"), package = "mapbaltimore")
  } else if (!is.null(cachedata)) {
    path <- file.path(rappdirs::user_cache_dir("mapbaltimore"), paste0(cachedata, ".gpkg"))
  }

  if (is.character(data) && (length(data) == 1)) {
    # Convert bbox to well known text
    area_wkt_filter <- bbox %>%
      sf::st_as_sfc() %>% # Convert to sfc
      sf::st_as_text()

    if (data %in% data(package = "mapbaltimore")$results[, "Item"]) {
      # If data is loaded with mapbaltimore
      data <- eval(parse(text = data))
    } else if (paste0(data, ".gpkg") %in% list.files(system.file("extdata", package = "mapbaltimore"))) {
      # If data is in extdata folder
      path <- system.file("extdata", paste0(data, ".gpkg"), package = "mapbaltimore")
    } else if (paste0(data, ".gpkg") %in% list.files(rappdirs::user_cache_dir("mapbaltimore"))) {
      # If data is in the mapbaltimore cache directory
      path <- file.path(rappdirs::user_cache_dir("mapbaltimore"), paste0(data, ".gpkg"))
    } else if (stringr::str_detect(data, "^http")) {
      # If data appears to be a valid URL
      url <- data
    }
  }

  if (!is.null(path)) {
    # Convert bbox to well known text
    area_wkt_filter <- bbox %>%
      sf::st_as_sfc() %>% # Convert to sfc
      sf::st_as_text()

    # Read external, cached, or data at path with wkt_filter
    data <- sf::st_read(
      dsn = path,
      wkt_filter = area_wkt_filter
    )
  } else if (!is.null(url)) {
    # get_area_esri_data returns CRS 2804 by default
    data <- get_area_esri_data(
      bbox = bbox,
      url = url
    )
  }

  if (crop && !trim) {
    data <- sf::st_crop(data, bbox) %>%
      suppressWarnings()
  } else if (trim && !is.null(area)) {
    data <- sf::st_intersection(data, area) %>%
      suppressWarnings()
  } else {
    # Convert bbox back to sf object
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()

    data <- sf::st_filter(data, area)
  }

  if (!is.null(fn)) {
    fn <- rlang::as_function(fn)
    data <- fn(data)
  }

  if (!is.null(crs)) {
    data <- sf::st_transform(data, crs)
  }

  return(data)
}
