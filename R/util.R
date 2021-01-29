#' Validate area provided to mapping or charting function.
#'
#' Validate an area for a mapping function or another mapbaltimore function.
#'
#' @param area sf object with a column named "name."
#'
#' @export
#'
check_area <- function(area) {

  # Check if area is an sf object
  if (!("sf" %in% class(area))) {
    stop("The area must be an sf class object.")
  } else if (!("name" %in% names(area))) {
    stop("The area must have a 'name' column.")
  }
}


#' Set default map theme
#'
#' Set a map theme using \code{\link[ggplot2]{theme_set()}} and default for \code{geom_label} using \code{\link[ggplot2]{update_geom_defaults()}}. Optionally hides axis text and labels.
#'
#' @param map_theme ggplot2 theme. Optional. Defaults to \code{\link[ggplot2]{theme_minimal()}}
#' @param show_axis Logical. If TRUE, keep theme axis formatting. If FALSE, hide the panel grid, axis title, and axis text.
#'
#' @export
#'
set_map_theme <- function(map_theme = NULL,
                          show_axis = FALSE) {
  if (is.null(map_theme)) {
    # Set minimal theme
    ggplot2::theme_set(
      ggplot2::theme_minimal(base_size = 16)
    )
  } else {
    (
      ggplot2::theme_set(
        map_theme
      )
    )
  }

  if (!show_axis) {
    ggplot2::theme_update(
      panel.grid.major = ggplot2::element_blank(), # Remove lat/lon grid
      axis.title = ggplot2::element_blank(), # Remove lat/lon axis text
      axis.text = ggplot2::element_blank() # Remove numeric labels on lat/lon axis ticks
    )
  }

  # Match font family for label and label_repeal to theme font family
  ggplot2::update_geom_defaults("label", list(color = "grey20", family = ggplot2::theme_get()$text$family))
}

#' Set limits of ggplot map to a selected area
#'
#' Gets the bounding box of an area and passes the coordinates to the \code{\link[ggplot2]{coord_sf}} function. This function is useful for highlighting a defined area within a plot or expanding a plot to make space for labels and/or annotation.
#'
#' @param area sf object.
#' @param crs EPSG code for the coordinate reference system for the plot. Default is 2804. See \url{https://epsg.io/}
#'
#' @export
#'
set_limits_to_area <- function(area,
                               crs = 2804) {

  # Match area to CRS
  if (sf::st_crs(area) != paste0("EPSG:", crs)) {
    sf::st_transform(area, crs)
  }

  bbox <- sf::st_bbox(area) # Get bbox for area

  return(
    ggplot2::coord_sf(
      xlim = c(bbox[[1]], bbox[[3]]),
      ylim = c(bbox[[2]], bbox[[4]])
    )
  )
}

#' Get a mask for an area
#'
#' Returns a mask for an area or areas as an sf object. Used by the \code{map_area_with_snapbox} function.
#'
#' @param area sf object. If multiple areas are provided, they are unioned into a single sf object using \code{\link[sf]{st_union()}}
#' @param edge sf object. Must match CRS of area. Defaults to bounding box of buffered area, converted to an sf object.
#' @inheritParams get_buffered_area
#' @param crs  Selected CRS for returned mask.
#'
#' @export
#'
get_area_mask <- function(area,
                          edge = NULL,
                          diag_ratio = 0.125,
                          dist = NULL,
                          crs = 2804) {
  if (length(area$geometry) > 1) {
    area <- sf::st_union(area)
  }

  if (is.null(edge)) {
    edge <- get_buffered_area(area,
      diag_ratio = diag_ratio,
      dist = dist
    ) %>%
      sf::st_bbox() %>%
      sf::st_as_sfc()
  }

  area_mask <- sf::st_difference(edge, area)
  area_mask <- sf::st_transform(area_mask, crs)

  return(area_mask)
}


#' Get OSM feature
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


