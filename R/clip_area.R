
##' Clip an area to a portion of the whole area
##'
##' Clip based on the corner of the bounding box. Used for the street name
##' location option within \code{layer_area_streets}
##'
##' @param area `sf` object to clip
##' @param clip Character string describing the part of the area to clip or
##'   remove (except if clip is "edge"). If "edge" with a negative "edge_dist",
##'   only the edges are kept (center is removed). If "edge" with a positive
##'   "edge_dist", the full area is removed and a buffer kept. Options include
##'   c("edge", "top", "right", "bottom", "left", "topright", "bottomright",
##'   "bottomleft", "topleft"). Expect edge to move to a separate parameter
##'   allowing clip and edge to be combined.
##' @param flip Logical. Default FALSE. If TRUE, the reverse of the select area
##'   is removed, e.g. if clip is "topright" the "bottomleft" area is removed
##'   instead.
##' @param edge_dist Numeric. Distance in meters to use for the edge. Default 5
##'   meters. Use negative values for an inside edge or positive numbers for an
##'   outside edge.
##' @return \code{sf} object clipped based on parameters
##' @export
##' @importFrom sf st_bbox st_centroid st_coordinates st_point  st_sf st_crs
##'   st_sfc st_convex_hull st_buffer st_intersection st_difference
##' @importFrom units set_units
clip_area <- function(area,
                      clip = c("edge", "top", "right", "bottom", "left", "topright", "bottomright", "bottomleft", "topleft"),
                      flip = FALSE,
                      edge_dist = 5) {
  clip <- match.arg(clip)

  bbox <- sf::st_bbox(area)

  center <- sf::st_coordinates(suppressWarnings(sf::st_centroid(area)))

  # TODO: Implement a way of combining clipping with positive/negative edge buffers
  if (clip == "right") {
    corner_pts <- c(
      sf::st_point(c(center[1], bbox$ymin)),
      sf::st_point(c(center[1], bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymin))
    )
  }

  if (clip == "left") {
    corner_pts <- c(
      sf::st_point(c(center[1], bbox$ymin)),
      sf::st_point(c(center[1], bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymin))
    )
  }

  if (clip == "top") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, center[2])),
      sf::st_point(c(bbox$xmax, center[2])),
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymax))
    )
  }

  if (clip == "bottom") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, center[2])),
      sf::st_point(c(bbox$xmax, center[2])),
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmin, bbox$ymin))
    )
  }

  if (clip == "topleft") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymin))
    )
  }

  if (clip == "topright") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmin, bbox$ymax))
    )
  }

  if (clip == "bottomleft") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, bbox$ymin)),
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmin, bbox$ymax))
    )
  }

  if (clip == "bottomright") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymin))
    )
  }

  if (clip != "edge") {
    clip <- sf::st_sf(
      name = clip,
      crs = sf::st_crs(area),
      geometry = sf::st_sfc(sf::st_convex_hull(corner_pts))
    )
  } else {
    # TODO: edge clips
    # flip <- !flip

    if (edge_dist > 0) {
      clip <- area
      area <- sf::st_buffer(area, dist = units::set_units(edge_dist, "m"))
    } else {
      clip <- sf::st_buffer(area, dist = units::set_units(edge_dist, "m"))
    }
  }

  if (flip) {
    area <- suppressWarnings(sf::st_intersection(area, clip))
  } else {
    area <- suppressWarnings(sf::st_difference(area, clip))
  }

  return(area)
}
