#' Layer for area data
#'
#' Combines get_area_data and geom_sf into a single call. Optionally can outline
#' area and call layer_area_mask.
#'
#' @inheritParams get_area_data
#' @inheritDotParams ggplot2::geom_sf mapping
#' @inheritDotParams ggplot2::geom_sf inherit.aes
#' @param show_area Logical. Default FALSE. If TRUE, add an outline of the area
#'   to the layer.
#' @param area_color Character to set fixed color aesthetic for area layer.
#' @param area_fill  to set fixed fill aesthetic for area layer.
#' @param mask Logical. Default FALSE. If TRUE, add a mask using
#'   \code{layer_area_mask}
#' @param ... passed to \code{\link[ggplot2]{geom_sf}} for data layer.
#' @export
#' @importFrom ggplot2 geom_sf aes
layer_area_data <- function(area = NULL,
                            bbox = NULL,
                            data = NULL,
                            extdata = NULL,
                            cachedata = NULL,
                            diag_ratio = NULL,
                            dist = NULL,
                            asp = NULL,
                            crop = TRUE,
                            trim = FALSE,
                            crs = 2804,
                            mapping = aes(),
                            inherit.aes = TRUE,
                            show_area = FALSE,
                            area_color = "gray30",
                            area_fill = NA,
                            mask = FALSE,
                            ...) {
  area_data <- suppressWarnings(get_area_data(
    area = area,
    bbox = bbox,
    data = data,
    cachedata = cachedata,
    extdata = extdata,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    crop = crop,
    trim = trim,
    crs = crs
  ))

  data_layer <- ggplot2::geom_sf(data = area_data, mapping = mapping, inherit.aes = inherit.aes, ...)

  mask_layer <- NULL

  if (mask && !is.null(area)) {
    mask_layer <- layer_area_mask(
      area = area,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crs = crs,
      fill = "white",
      color = NA
    )
  } else if (mask) {
    warning("mask = TRUE is ignored if an area is not provided.")
  }

  area_layer <- NULL

  if (show_area) {
    area_layer <- ggplot2::geom_sf(data = area, color = area_color, fill = area_fill)
  }

  return(list(data_layer, mask_layer, area_layer))
}
