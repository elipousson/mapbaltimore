#' Validate area provided to mapping or charting function.
#'
#' Validate an area for a mapping function or another mapbaltimore function.
#'
#' @param area `sf` object with a column named "name."
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
#' Set a map theme using \code{\link[ggplot2]{theme_set()}} and default for \code{geom_label}
#' using \code{\link[ggplot2]{update_geom_defaults()}}.
#' Optionally hides axis text and labels.
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
      # Remove lat/lon grid
      panel.grid.major = ggplot2::element_blank(),
      # Remove lat/lon axis text
      axis.title = ggplot2::element_blank(),
      # Remove numeric labels on lat/lon axis ticks
      axis.text = ggplot2::element_blank()
    )
  }

  # Match font family for label and label_repeal to theme font family
  ggplot2::update_geom_defaults(
    "label",
    list(
      color = "grey20",
      family = ggplot2::theme_get()$text$family
      )
    )
}

##' Set map limits to area with optional buffer or aspect ratio adjustment
##'
##' Set limits for a map to the bounding box of an area using `coord_sf()`.
##' Optionally, adjust the area size using get_buffered_area function
##' and/or adjust the aspect ratio of the limiting bounding box to match
##' a set aspect ratio.
##'
##' @title Set map limits to area
##' @inheritParams get_adjusted_bbox
##' @param crs Coordinate reference system to use for `coord_sf()`. Default 2804.
##' @param ... Additional parameters to pass to `coord_sf()`.
##' @return `ggplot2::coord_sf()` function to modify a `ggplot2` object
##' @export
set_map_limits <- function(area = NULL,
                           bbox = NULL,
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           crs = 2804,
                           ...) {

  # Pass variables to bbox adjustment function
  bbox <- get_adjusted_bbox(
    area = area,
    bbox = bbox,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    crs = crs
  )

  # Set limits with adjustments using coord_sf
  limits <- ggplot2::coord_sf(
    xlim = c(bbox[[1]], bbox[[3]]),
    ylim = c(bbox[[2]], bbox[[4]]),
    ...
  )

  # Return the adjusted limits
  return(limits)
}

##' Get bounding box buffered and adjusted to match aspect ratio
##'
##' Takes an area as an sf object or a bounding box and returns a bounding box that
##' matches the provided aspect ratio and contains the area or bounding box provided.
##'
##' Common aspect ratios include "1:1" (1), "4:6" (0.666), "8.5:11", "16:9" (1.777).
##' The asp parameter supports both numeric values and character strings with ratios
##' matching the format of "width:height".
##'
##' @title Get bounding box buffered and adjusted to aspect ratio
##' @param area `sf` object to buffer and/or adjust.
##' @param bbox `bbox` object to buffer and/or adjust. If an area is provided, any bbox is ignored.
##' @inheritParams get_buffered_area
##' @inheritParams get_asp_adjusted_bbox
##' @param crs Coordinate reference system of bounding box to return
##' @return Class `bbox` object
##' @export
get_adjusted_bbox <- function(area = NULL,
                              bbox = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              crs = NULL) {

  # If bbox but no area, convert bounding box to sf object
  if (!is.null(bbox) && is.null(area)) {
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()
  } else if (!is.null(bbox) && !is.null(area)) {
    warning("When a bounding box and an area are both provided, the bounding box is ignored.")
    bbox <- NULL
  }

  # Get buffered area
  if (!is.null(dist) | !is.null(diag_ratio)) {
    area <- get_buffered_area(
      area = area,
      dist = dist,
      diag_ratio = diag_ratio
    )
  }

  if (sf::st_crs(area) != paste0("EPSG:", crs) && !is.null(crs)) {
    # Match bbox CRS to selected CRS if it doesn't match and crs is not NULL
    area <- sf::st_transform(area, crs)
  }

  if (is.null(asp)) {
    # Get bbox
    bbox <- sf::st_bbox(area)
  } else { # Equivalent to !is.null(asp)
    # Get aspect adjusted bbox
    bbox <- get_asp_adjusted_bbox(
      area = area,
      asp = asp
    )
  }

  return(bbox)
}

##' Get bounding box adjusted to match aspect ratio
##'
##' Takes an area as an sf object or a bounding box and returns a bounding box that
##' matches the provided aspect ratio and contains the area or bounding box provided.
##' Common aspect ratios include "1:1" (1), "4:6" (0.666), "8.5:11", "16:9" (1.777).
##' The asp parameter supports both numeric values and character strings with ratios
##' matching the format of "width:height".
##'
##' @title Get bounding box adjusted to aspect ratio
##' @param area `sf` object
##' @param bbox `bbox` object
##' @param asp Aspect ratio of width to height as a numeric value (e.g. 0.33) or character (e.g. "1:3").
##' @return Class bbox object
##' @export
get_asp_adjusted_bbox <- function(area = NULL,
                                  bbox = NULL,
                                  asp = NULL) {

  # Check aspect ratio
  # If asp is provided as character string (e.g. "16:9") convert to a numeric ratio
  if (is.character(asp) && stringr::str_detect(asp, ":")) {
    asp <- as.numeric(stringr::str_extract(asp, ".+(?=:)")) / as.numeric(stringr::str_extract(asp, "(?<=:).+"))
  } else if (!is.null(asp) && !is.numeric(asp)) {
    stop("The aspect ratio cannot be determined. asp must be numeric (e.g. 0.666) or a string formatted as a ratio of width to height (e.g. '4:6').")
  }

  if (is.null(area)) {
    # Convert bounding box to sf object if area is NULL
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()
  } else if (!is.null(area)) {
    # Get bbox for area
    bbox <- sf::st_bbox(area)
  } else {
    stop("An area or a bounding box must be provided.")
  }

  xdist <- sfx::st_xdist(area) # Get area width
  ydist <- sfx::st_ydist(area) # Get area height
  area_asp <- as.numeric(xdist) / as.numeric(ydist) # Get width to height aspect ratio for bbox

  # Set adjustments for x and y to 0
  adj_x <- 0
  adj_y <- 0

  # Compare aspect ratio to bbox aspect ratio
  if (asp >= area_asp) {
    # adjust x
    adj_x <- (asp * ydist - xdist) / 2
  } else { # Equivalent to asp < area_asp
    # adjust y
    adj_y <- ((1 / asp) * xdist - ydist) / 2
  }

  # Adjust bbox
  bbox[[1]] <- bbox[[1]] - adj_x
  bbox[[3]] <- bbox[[3]] + adj_x
  bbox[[2]] <- bbox[[2]] - adj_y
  bbox[[4]] <- bbox[[4]] + adj_y

  return(bbox)
}

#' Get a mask for an area
#'
#' Returns a mask for an area or areas as an `sf` object.
#' Used by the \code{map_area_with_snapbox} function.
#'
#' @param area `sf` object. If multiple areas are provided, they are unioned into a single `sf` object using \code{\link[sf]{st_union()}}
#' @inheritParams get_adjusted_bbox
#' @param mask `sf` or `bbox` object to define the edge of the mask
#' @param ... Additional parameters to pass to `ggplot2::geom_sf()`
#' @return `ggplot2::geom_sf()` function.
#' @export
#'
layer_area_mask <- function(area = NULL,
                            bbox = NULL,
                            diag_ratio = NULL,
                            dist = NULL,
                            asp = NULL,
                            crs = 2804,
                            mask = NULL,
                            ...) {

  # Union area sf if multiple geometries provided
  if (length(area$geometry) > 1) {
    area <- sf::st_union(area)
  }

  if (!is.null(crs) && sf::st_crs(area) != paste0("EPSG:", crs)) {
    # Match area CRS to selected CRS
    area <- sf::st_transform(area, crs)
  }

  # Check if mask is provided
  if (!is.null(mask)) {
    # Check if mask is bbox
    if (class(mask) == "bbox") {
      bbox <- mask
    } else {
      bbox <- sf::st_bbox(mask)
    }
  } else {
    # Get adjusted bbox
    bbox <- get_adjusted_bbox(
      area = area,
      bbox = bbox,
      diag_ratio = diag_ratio,
      dist = dist,
      asp = asp,
      crs = crs
    )
  }

  # Make mask
  area_mask <- bbox %>%
    sf::st_as_sfc() %>%
    sf::st_difference(area)

  return(ggplot2::geom_sf(data = area_mask, ...))
}



clip_area <- function(area,
                      clip = c("edge","topleft","topright","bottomleft","bottomright"),
                      flip = FALSE) {

  clip <- match.arg(clip)

  bbox <- sf::st_bbox(area)

  if (clip == "topleft") {
    corner_pts <- c(sf::st_point(c(bbox$xmin, bbox$ymax)),
                    sf::st_point(c(bbox$xmax, bbox$ymax)),
                    sf::st_point(c(bbox$xmin, bbox$ymin)))
  } else if (clip == "topright") {
    corner_pts <- c(sf::st_point(c(bbox$xmax, bbox$ymax)),
                    sf::st_point(c(bbox$xmax, bbox$ymin)),
                    sf::st_point(c(bbox$xmin, bbox$ymax)))
  } else if (clip == "bottomleft") {
    corner_pts <- c(sf::st_point(c(bbox$xmin, bbox$ymin)),
                    sf::st_point(c(bbox$xmax, bbox$ymin)),
                    sf::st_point(c(bbox$xmin, bbox$ymax)))
  } else if (clip == "bottomright") {
    corner_pts <- c(sf::st_point(c(bbox$xmax, bbox$ymin)),
                    sf::st_point(c(bbox$xmax, bbox$ymax)),
                    sf::st_point(c(bbox$xmin, bbox$ymin)))
  }

  if (clip != "edge") {
    clip <- sf::st_sf(name = clip,
                      crs = sf::st_crs(area),
                      geometry = sf::st_sfc(sf::st_convex_hull(corner_pts)))
  } else {
    clip <- sf::st_buffer(area, dist = units::set_units(-1, m))
  }

  if (flip) {
    area <- suppressWarnings(sf::st_intersection(area, clip))
  } else {
    area <- suppressWarnings(sf::st_difference(area, clip))
  }

return(area)

}
