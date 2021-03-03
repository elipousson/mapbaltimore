#' Add an area mask to a ggplot2 map as a layer
#'
#' Returns a mask for an area or areas as an  \code{sf} object. This function
#' can be called by any function that uses the logical \code{mask} parameter.
#'
#' @param area \code{sf} object. Required. If multiple areas are provided, the
#'   areas are combined into a single geometry with \code{\link[sf]{st_union}}
#' @inheritParams adjust_bbox
#' @param mask_bbox \code{bbox} object to define the edge of the mask.
#'   \code{diag_ratio}, \code{dist}, and \code{asp} parameters are ignored if a
#'   \code{mask_bbox} is provided.
#' @param ... Additional parameters to pass to \code{\link[ggplot2]{geom_sf}}
#' @return  \code{\link[ggplot2]{geom_sf}} function.
#' @export
#' @importFrom sf st_union st_crs st_transform st_bbox st_as_sfc st_difference
#' @importFrom ggplot2 geom_sf
layer_area_mask <- function(area = NULL,
                            diag_ratio = NULL,
                            dist = NULL,
                            asp = NULL,
                            crs = 2804,
                            mask_bbox = NULL,
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
  if (!is.null(mask_bbox)) {
    bbox <- mask_bbox
  } else {
    # Get adjusted bbox
    bbox <- adjust_bbox(
      area = area,
      diag_ratio = diag_ratio,
      dist = dist,
      asp = asp,
      crs = crs
    )
  }

  # Make mask
  area_mask <- sf::st_difference(sf::st_as_sfc(bbox), area)
  area_mask_layer <- ggplot2::geom_sf(data = area_mask, ...)

  return(area_mask_layer)
}