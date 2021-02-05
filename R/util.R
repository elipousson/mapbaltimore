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

##' Set map limits to area with optional buffer or aspect ratio adjustment
##'
##' Set limits for a map to the bounding box of an area using coord_sf.
##' Optionally, adjust the area size using get_buffered_area function
##' and/or adjust the aspect ratio of the limiting bounding box to match
##' a set aspect ratio.
##'
##' @title Set map limits to area
##' @param area sf object
##' @inheritParams get_buffered_area
##' @inheritParams get_asp_adj_bbox
##' @param crs Coordinate reference system to use. Default EPSG:2804.
##' @return ggplot2::coord_sf() function to modify a ggplot2 object
##' @export
set_map_limits <- function(area = NULL,
                           bbox = NULL,
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           crs = 2804) {

  # If bbox but no area, convert bounding box to sf object
  if (!is.null(bbox) && is.null(area)) {
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()
  }

  # Get buffered area
  if (!is.null(dist) | !is.null(diag_ratio)) {
    area <- get_buffered_area(area,
      dist = dist,
      diag_ratio = diag_ratio
    )
  }

  # Match area CRS to selected CRS
  if (sf::st_crs(area) != paste0("EPSG:", crs)) {
    area <- sf::st_transform(area, crs)
  }

  if (is.null(asp)) {
    # Get bbox
    bbox <- sf::st_bbox(area)
  } else {
    # Get aspect adjusted bbox
    bbox <- get_asp_adj_bbox(
      area = area,
      bbox = bbox,
      asp = asp
    )
  }

  # Set limits with adjustments using coord_sf
  limits <- ggplot2::coord_sf(
    xlim = c(bbox[[1]], bbox[[3]]),
    ylim = c(bbox[[2]], bbox[[4]])
  )

  # Return the adjusted limits
  return(limits)
}


##' Get area bounding box adjusted to aspect ratio
##'
##' Takes an area or bounding box and returns a bounding box that matches
##' the provided aspect ratio and contains the area or bounding box provided.
##' Common aspect ratios include "1:1" (1), "4:6" (0.666), "8.5:11", "16:9" (1.777).
##' The asp parameter supports both numeric values and ratios matching the
##' format of "width:height".
##'
##' @title Get area bounding box adjusted to aspect ratio
##' @param area sf object
##' @param bbox bbox object
##' @param asp Aspect ratio of width to height as a numeric value (e.g. 0.33) or character (e.g. "1:3").
##' @return Class bbox object
##' @export
get_asp_adj_bbox <- function(area = NULL,
                             bbox = NULL,
                             asp = NULL) {

  # Check aspect ratio
  # If asp is provided as character string (e.g. "16:9") convert to a numeric ratio
  if (is.character(asp) && stringr::str_detect(asp, ":")) {
    asp <- as.numeric(stringr::str_extract(asp, ".+(?=:)")) / as.numeric(stringr::str_extract(asp, "(?<=:).+"))
  } else if (!is.null(asp) && !is.numeric(asp)) {
    stop("The aspect ratio cannot be determined. asp must be numeric (e.g. 0.666) or a string formatted as a ratio of width to height (e.g. '4:6').")
  }

  # If bbox but no area, convert bounding box to sf object
  if (!is.null(bbox) && is.null(area)) {
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()
  } else if (is.null(bbox)) {
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
  } else if (asp < area_asp) {
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
#' Returns a mask for an area or areas as an sf object.
#' Used by the \code{map_area_with_snapbox} function.
#'
#' @param area sf object. If multiple areas are provided, they are unioned into a single sf object using \code{\link[sf]{st_union()}}
#' @param bbox bbox that optionally defines edge of the mask
#' @inheritParams get_buffered_area
#' @inheritParams get_asp_adj_bbox
#' @param crs Selected CRS for returned mask.
#' @return sf object with an outer edge matching the bbox or adjusted bbox with the area cut out.
#' @export
#'
layer_area_mask <- function(area = NULL,
                          bbox = NULL,
                          diag_ratio = NULL,
                          dist = NULL,
                          asp = NULL,
                          crs = NULL,
                          ...) {

  if (length(area$geometry) > 1) {
    area <- sf::st_union(area)
  }

  # Transform CRS if provided
  if (!is.null(crs)) {
    area <- sf::st_transform(area, crs)
  }

  area_cutout <- area

  # Get buffered area
  if (!is.null(dist) | !is.null(diag_ratio)) {
      area <- get_buffered_area(area,
        dist = dist,
        diag_ratio = diag_ratio
      )
    }

    if (is.null(asp) && is.null(bbox)) {
      # Get bbox for area or buffered area
      bbox <- sf::st_bbox(area)
    } else if (is.null(bbox)) {
      # Get aspect adjusted bbox
      bbox <- get_asp_adj_bbox(
        area,
        asp = asp
      )
    }

  # Make mask
  area_mask <- bbox %>%
    sf::st_as_sfc() %>%
    sf::st_difference(area_cutout)

  return(ggplot2::geom_sf(data = area_mask, ...))
}
