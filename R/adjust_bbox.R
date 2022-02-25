##' Get bounding box buffered and adjusted to match aspect ratio
##'
##' Takes an area as an sf object or a bounding box and returns a bounding box
##' that matches the provided aspect ratio and contains the area or bounding box
##' provided.
##'
##' Common aspect ratios include "1:1" (1), "4:6" (0.666), "8.5:11", "16:9"
##' (1.777). The asp parameter supports both numeric values and character
##' strings with ratios matching the format of "width:height".
##'
##' @title Get bounding box buffered and adjusted to aspect ratio
##' @param area \code{sf} object to buffer and/or adjust.
##' @param bbox \code{bbox} object to buffer and/or adjust. If an area is provided, any bbox is ignored.
##' @inheritParams buffer_area
##' @inheritParams adjust_bbox_asp
##' @param crs Coordinate reference system of bounding box to return
##' @return Class \code{bbox} object
##' @export
##' @importFrom overedge st_bbox_ext
adjust_bbox <- function(area = NULL,
                        bbox = NULL,
                        dist = NULL,
                        diag_ratio = NULL,
                        asp = NULL,
                        crs = NULL) {
  if (overedge::check_sf(area)) {
    location <- area
  } else if (overedge::check_bbox(area)) {
    location <- area
  } else if (overedge::check_bbox(bbox)) {
    location <- bbox
  }

  if (!is.null(location)) {
    bbox <-
      overedge::st_bbox_ext(
        x = location,
        dist = dist,
        diag_ratio = diag_ratio,
        asp = asp,
        crs = crs
      )
  }

  return(bbox)
}
