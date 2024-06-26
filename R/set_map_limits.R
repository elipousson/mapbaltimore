#' Set map limits to area with optional buffer or aspect ratio adjustment
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [maplayer::layer_neatline()] function which uses a similar
#' set of parameters.
#'
#' Set limits for a map to the bounding box of an area using `coord_sf()`.
#' Optionally, adjust the area size by applying a buffer and/or adjust the
#' aspect ratio of the limiting bounding box to match a set aspect ratio.
#'
#' @title Set map limits to area
#' @inheritParams adjust_bbox
#' @param crs Coordinate reference system to use for `coord_sf()`. Default
#'   `pkgconfig::get_config("mapbaltimore.crs", 2804)`
#' @param expand Default FALSE. If TRUE, use scale_y_continuous and
#'   scale_x_continuous to expand map extent to provided parameters.
#' @param ... Additional parameters to pass to `coord_sf()`.
#' @return `ggplot2::coord_sf()` function with xlim and ylim parameters
#' @example examples/set_map_limits.R
#' @rdname set_map_limits
#' @keywords internal
#' @export
set_map_limits <- function(area = NULL,
                           bbox = NULL,
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                           expand = FALSE,
                           ...) {
  lifecycle::deprecate_warn("0.1.2", "set_map_limits()", "maplayer::layer_neatline()")
  check_installed("ggplot2")

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

  if (expand) {
    limits <- list(
      limits,
      ggplot2::scale_y_continuous(expand = c(0, 0)),
      ggplot2::scale_x_continuous(expand = c(0, 0))
    )
  }

  # Return the adjusted limits
  return(limits)
}
