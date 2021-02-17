
##' Clip an area to a portion of the whole area
##'
##' Clip based on the corner of the bounding box. Used for the labelling option
##' within \code{layer_area_streets}
##'
##' @param area `sf` object to clip
##' @param clip Character string describing the part of the area to remove or,
##'   if "edge", the only area to keep. Options include c("edge", "topleft",
##'   "topright", "bottomleft", "bottomright")
##' @param flip Logical. Default FALSE. If TRUE, the reverse of the select area
##'   is removed, e.g. if clip is "topright" the "bottomleft" area is removed
##'   instead.
##' @return \code{sf} object clipped based on parameters
##' @export
clip_area <- function(area,
                      clip = c("edge", "topleft", "topright", "bottomleft", "bottomright"),
                      flip = FALSE) {

  clip <- match.arg(clip)

  bbox <- sf::st_bbox(area)

  if (clip == "topleft") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmin, bbox$ymin))
    )
  } else if (clip == "topright") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmax, bbox$ymax)),
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmin, bbox$ymax))
    )
  } else if (clip == "bottomleft") {
    corner_pts <- c(
      sf::st_point(c(bbox$xmin, bbox$ymin)),
      sf::st_point(c(bbox$xmax, bbox$ymin)),
      sf::st_point(c(bbox$xmin, bbox$ymax))
    )
  } else if (clip == "bottomright") {
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
    clip <- sf::st_buffer(area, dist = units::set_units(-1, m))
  }

  if (flip) {
    area <- suppressWarnings(sf::st_intersection(area, clip))
  } else {
    area <- suppressWarnings(sf::st_difference(area, clip))
  }

  return(area)
}
