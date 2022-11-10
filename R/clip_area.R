
#' Clip an area to a portion of the whole area
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [sfext::st_clip()] function which uses a similar set
#' of parameters.
#'
#' Clip based on the corner of the bounding box. Used for the street name
#' location option within `layer_area_streets`
#'
#' @param area `sf` object to clip
#' @param clip Character string describing the part of the area to clip or
#'   remove. Options include c("top", "right", "bottom", "left", "topright",
#'   "bottomright", "bottomleft", "topleft"). If NULL, the area is not clipped
#'   and a full edge can be returned.
#' @param flip Logical. Default FALSE. If TRUE, the reverse of the select area
#'   is removed, e.g. if `clip` is "topright" the "bottomleft" area is removed
#'   instead.
#' @param edge Logical. Default TRUE. If TRUE, only the edge of the clipped area
#'   is returned.  If TRUE with a negative `edge_dist`, only the edges are kept
#'   (center is removed). If TRUE with a positive `edge_dist`, the full area is
#'   removed and a buffer kept. If FALSE, the full clipped area is returned.
#' @param edge_dist Numeric. Distance in meters to use for the edge. Default 5
#'   meters. Use negative values for an inside edge or positive numbers for an
#'   outside edge.
#' @return `sf` object clipped based on parameters
#' @keywords internal
#' @export
#' @importFrom sf st_coordinates st_centroid st_difference st_bbox st_point
#'   st_sf st_crs st_sfc st_convex_hull st_intersection
#' @importFrom dplyr select
#' @importFrom tidyselect all_of
#' @importFrom sfext st_buffer_ext
clip_area <- function(area,
                      clip = c("top", "right", "bottom", "left", "topright", "bottomright", "bottomleft", "topleft"),
                      flip = FALSE,
                      edge = TRUE,
                      edge_dist = 5) {
  lifecycle::deprecate_warn("0.1.2", "clip_area()", "sfext::st_clip()")
  area_names <- names(area)

  center <- sf::st_coordinates(suppressWarnings(sf::st_centroid(area)))

  if (edge) {
    if (edge_dist > 0) {
      area <- suppressWarnings(sf::st_difference(sfext::st_buffer_ext(area, dist = edge_dist), area))
    } else if (edge_dist < 0) {
      area <- suppressWarnings(sf::st_difference(area, sfext::st_buffer_ext(area, dist = edge_dist)))
    }
  }

  bbox <- sf::st_bbox(area)

  if (!is.null(clip)) {
    clip <- match.arg(clip)

    if (clip == "right") {
      clip_pts <- c(
        sf::st_point(c(center[1], bbox$ymin)),
        sf::st_point(c(center[1], bbox$ymax)),
        sf::st_point(c(bbox$xmax, bbox$ymax)),
        sf::st_point(c(bbox$xmax, bbox$ymin))
      )
    }

    if (clip == "left") {
      clip_pts <- c(
        sf::st_point(c(center[1], bbox$ymin)),
        sf::st_point(c(center[1], bbox$ymax)),
        sf::st_point(c(bbox$xmin, bbox$ymax)),
        sf::st_point(c(bbox$xmin, bbox$ymin))
      )
    }

    if (clip == "top") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmin, center[2])),
        sf::st_point(c(bbox$xmax, center[2])),
        sf::st_point(c(bbox$xmax, bbox$ymax)),
        sf::st_point(c(bbox$xmin, bbox$ymax))
      )
    }

    if (clip == "bottom") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmin, center[2])),
        sf::st_point(c(bbox$xmax, center[2])),
        sf::st_point(c(bbox$xmax, bbox$ymin)),
        sf::st_point(c(bbox$xmin, bbox$ymin))
      )
    }

    if (clip == "topleft") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmin, bbox$ymax)),
        sf::st_point(c(bbox$xmax, bbox$ymax)),
        sf::st_point(c(bbox$xmin, bbox$ymin))
      )
    }

    if (clip == "topright") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmax, bbox$ymax)),
        sf::st_point(c(bbox$xmax, bbox$ymin)),
        sf::st_point(c(bbox$xmin, bbox$ymax))
      )
    }

    if (clip == "bottomleft") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmin, bbox$ymin)),
        sf::st_point(c(bbox$xmax, bbox$ymin)),
        sf::st_point(c(bbox$xmin, bbox$ymax))
      )
    }

    if (clip == "bottomright") {
      clip_pts <- c(
        sf::st_point(c(bbox$xmax, bbox$ymin)),
        sf::st_point(c(bbox$xmax, bbox$ymax)),
        sf::st_point(c(bbox$xmin, bbox$ymin))
      )
    }

    clip <- sf::st_sf(
      name = clip,
      crs = sf::st_crs(area),
      geometry = sf::st_sfc(sf::st_convex_hull(clip_pts))
    )

    if (flip) {
      area <- suppressWarnings(sf::st_intersection(area, clip))
    } else {
      area <- suppressWarnings(sf::st_difference(area, clip))
    }
  }

  area <- dplyr::select(area, tidyselect::all_of(area_names))

  return(area)
}
