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
##' @importFrom sf st_bbox st_as_sfc st_as_sf st_crs st_transform
adjust_bbox <- function(area = NULL,
                        bbox = NULL,
                        dist = NULL,
                        diag_ratio = NULL,
                        asp = NULL,
                        crs = NULL) {

  if (is.null(dist) && is.null(diag_ratio) && is.null(asp) && is.null(bbox)) {
    if (sf::st_crs(area) != paste0("EPSG:", crs) && !is.null(crs)) {
      # Match bbox CRS to selected CRS if it doesn't match and crs is not NULL
      area <- sf::st_transform(area, crs)
    }

    bbox <- sf::st_bbox(area)
    return(bbox)
  }

  # If bbox but no area, convert bounding box to sf object
  if (!is.null(bbox)) {
    if (is.null(area)) {
      area <- bbox %>%
        sf::st_as_sfc() %>%
        sf::st_as_sf()
    } else {
      warning("When a bounding box and an area are both provided, the bounding box is ignored.")
      bbox <- NULL
    }
  }

  # Get buffered area
  area <- buffer_area(
    area = area,
    dist = dist,
    diag_ratio = diag_ratio
  )

  if (sf::st_crs(area) != paste0("EPSG:", crs) && !is.null(crs)) {
    # Match bbox CRS to selected CRS if it doesn't match and crs is not NULL
    area <- sf::st_transform(area, crs)
  }

  # Get aspect adjusted bbox
  bbox <- adjust_bbox_asp(
    area = area,
    asp = asp
  )

  return(bbox)
}
