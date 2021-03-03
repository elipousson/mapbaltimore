
##' Set map limits to area with optional buffer or aspect ratio adjustment
##'
##' Set limits for a map to the bounding box of an area using \code{coord_sf()}.
##' Optionally, adjust the area size by applying a buffer and/or adjust the
##' aspect ratio of the limiting bounding box to match a set aspect ratio.
##'
##' @title Set map limits to area
##' @inheritParams adjust_bbox
##' @param crs Coordinate reference system to use for \code{coord_sf()}. Default
##'   2804.
##' @param ... Additional parameters to pass to \code{coord_sf()}.
##' @return \code{ggplot2::coord_sf()} function with xlim and ylim parameters
##' @export
set_map_limits <- function(area = NULL,
                           bbox = NULL,
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           crs = 2804,
                           ...) {

  # Pass variables to bbox adjustment function
  bbox <- adjust_bbox(
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