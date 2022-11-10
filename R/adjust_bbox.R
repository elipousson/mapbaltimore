#' Get bounding box buffered and adjusted to match aspect ratio
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [sfext::st_bbox_ext()] function which uses a similar set
#' of parameters.
#'
#' Takes an area as an sf object or a bounding box and returns a bounding box
#' that matches the provided aspect ratio and contains the area or bounding box
#' provided.
#'
#' Common aspect ratios include "1:1" (1), "4:6" (0.666), "8.5:11", "16:9"
#' (1.777). The asp parameter supports both numeric values and character
#' strings with ratios matching the format of "width:height".
#'
#' @title Get bounding box buffered and adjusted to aspect ratio
#' @param area `sf` object to buffer and/or adjust.
#' @param bbox `bbox` object to buffer and/or adjust. If an area is provided, any bbox is ignored.
#' @inheritParams buffer_area
#' @inheritParams adjust_bbox_asp
#' @param crs Coordinate reference system of bounding box to return
#' @return Class `bbox` object
#' @keywords internal
#' @export
#' @importFrom sfext is_sf is_bbox st_bbox_ext
adjust_bbox <- function(area = NULL,
                        bbox = NULL,
                        dist = NULL,
                        diag_ratio = NULL,
                        asp = NULL,
                        crs = NULL) {
  lifecycle::deprecate_warn("0.1.2", "adjust_bbox()", "sfext::st_bbox_ext()")

  if (sfext::is_sf(area)) {
    location <- area
  } else if (sfext::is_bbox(area)) {
    location <- area
  } else if (sfext::is_bbox(bbox)) {
    location <- bbox
  }

  if (!is.null(location)) {
    bbox <-
      sfext::st_bbox_ext(
        x = location,
        dist = dist,
        diag_ratio = diag_ratio,
        asp = asp,
        crs = crs
      )
  }

  return(bbox)
}
