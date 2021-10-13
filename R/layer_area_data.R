#' Layer for area data
#'
#' Layer for ggplot to show data for an area or area bbox.
#'
#' Combines get_area_data and geom_sf into a single call. Inherits data from
#' ggplot() if data, extdata, and cachedata are left as NULL. Set asis to TRUE
#' to keep data as is and not crop to area or modified area. Optionally can
#' combine data layer with a mask layer, an area layer, and any additional
#' number of layers after those three. The appearance of the area layer can be
#' modified with fixed aesthetics using the area_aes parameter. Fixed aesthetics
#' for the data layer can be added as additional parameters.
#'
#' @inheritParams get_area_data
#' @param asis Logical. Default FALSE. If TRUE, use inherited data as is without
#'   cropping to area.
#' @param show_area Logical. Default FALSE. If TRUE, add an outline of the area
#'   to the layer.
#' @param area_aes List of fixed aesthetics for area layer. Default to
#'   list(color = "gray30", fill = NA). Supported aesthetics include color,
#'   fill, linetype, alpha, and size. Defaults to color = "gray30", fill = NA,
#'   size = 0.75, alpha = 1, linetype = 0. Default aesthetics for geom_sf are
#'   ignored.
#' @param show_mask Logical. Default FALSE. If TRUE, add a mask using
#'   \code{layer_area_mask}
#' @param layer_after ggplot objects to append to the end of the data, mask,
#'   area layer list. This is intended to be used to append scales, guides, or
#'   labels related to the the data layer.
#' @param ... passed to \code{\link[ggplot2]{geom_sf}} for data layer.
#' @inheritDotParams ggplot2::geom_sf mapping
#' @inheritDotParams ggplot2::geom_sf inherit.aes
#' @section Predefined layers
#' @family layer_area_data
#' @export
#' @importFrom ggplot2 geom_sf aes
#' @importFrom purrr discard list_modify
#'
layer_area_data <- function(area = NULL,
                            bbox = NULL,
                            data = NULL,
                            extdata = NULL,
                            cachedata = NULL,
                            path = NULL,
                            url = NULL,
                            fn = NULL,
                            asis = FALSE,
                            diag_ratio = NULL,
                            dist = NULL,
                            asp = NULL,
                            crop = TRUE,
                            trim = FALSE,
                            crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                            mapping = aes(),
                            inherit.aes = TRUE,
                            show_mask = FALSE,
                            show_area = FALSE,
                            area_aes = list(color = "gray30"),
                            layer_after = NULL,
                            ...) {
  if (asis) {
    # Use data as is (inherited or provided)
    data_layer <- ggplot2::geom_sf(
      data = data,
      mapping = mapping,
      inherit.aes = inherit.aes,
      ...
    )
  } else if (!is.null(data) | !is.null(extdata) | !is.null(cachedata) | !is.null(path) | !is.null(url)) {
    # Get data for area (provided, external, and cached)
    area_data <- suppressWarnings(
      get_area_data(
        area = area,
        bbox = bbox,
        data = data,
        cachedata = cachedata,
        extdata = extdata,
        path = path,
        url = url,
        fn = fn,
        dist = dist,
        diag_ratio = diag_ratio,
        asp = asp,
        crop = crop,
        trim = trim,
        crs = crs
      )
    )

    # Use data to make layer
    data_layer <- ggplot2::geom_sf(
      data = area_data,
      mapping = mapping,
      inherit.aes = inherit.aes,
      ...
    )
  } else {
    # Use inherited data (limit to adjusted area)
    data_layer <- ggplot2::geom_sf(
      data = ~ suppressWarnings(
        get_area_data(
          area = area,
          bbox = bbox,
          data = .x,
          fn = fn,
          dist = dist,
          diag_ratio = diag_ratio,
          asp = asp,
          crop = crop,
          trim = trim,
          crs = crs
        )
      ),
      mapping = mapping,
      inherit.aes = inherit.aes,
      ...
    )
  }

  # Make mask layer
  mask_layer <- NULL
  if (show_mask && !is.null(area)) {
    mask_layer <- layer_area_mask(
      area = area,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crs = crs,
      fill = "white",
      alpha = 0.4,
      color = NA
    )
  } else if (show_mask) {
    message("show_mask is ignored if an area is not provided.")
  }

  # Make area layer
  area_layer <- NULL
  if (show_area && !is.null(area)) {
    # Compare provided aesthetic parameters to defaults
    area_aes <- purrr::list_modify(
      list(show = list(color = NA, fill = NA, linetype = 1, size = 0.75, alpha = 1)),
      show = area_aes
    )

    area_layer <- ggplot2::geom_sf(
      data = area,
      inherit.aes = FALSE,
      color = area_aes$show$color,
      fill = area_aes$show$fill,
      linetype = area_aes$show$linetype,
      size = area_aes$show$size,
      alpha = area_aes$show$alpha
    )
  }

  # Combine layers and discard NULL layers
  layer_list <- list(data_layer, mask_layer, area_layer, layer_after) %>%
    purrr::discard(is.null)

  return(layer_list)
}
