#' Map area using the snapbox package
#'
#' Map an area or areas using the \code{\link{snapbox}} package.
#'
#' @param area Required sf object with a 'name' column.
#' @param map_style Required. \code{\link{stylebox}} function referencing mapbox map styles. Default is \code{\link[stylebox]{mapbox_satellite_streets()}}
#' @inheritParams adjust_bbox
#' @param mask Logical. Default TRUE. If TRUE, apply a transparent (alpha = 0.4) white mask over the Mapbox map outside the area. Uses the layer_area_mask function.
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#' @importFrom snapbox layer_mapbox mapbox_satellite_streets
#' @importFrom sf st_transform st_bbox
#' @importFrom ggplot2 ggplot geom_sf
map_area_with_snapbox <- function(area,
                                  map_style = snapbox::mapbox_satellite_streets(),
                                  diag_ratio = 0.125,
                                  dist = NULL,
                                  asp = NULL,
                                  mask = TRUE) {

  # Set appropriate CRS for Mapbox
  mapbox_crs <- 3857

  # Make cutout for mask
  area_cutout <- area

  # Get adjusted bounding box if any adjustment variables provided
  if (!is.null(dist) | !is.null(diag_ratio) | !is.null(asp)) {
    bbox <- adjust_bbox(
      area = area,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crs = mapbox_crs
    )
  } else {
    bbox <- area %>%
      sf::st_transform(mapbox_crs) %>%
      sf::st_bbox()
  }

  # Get Mapbox map
  area_snapbox_map <- ggplot2::ggplot() +
    snapbox::layer_mapbox(
      area = bbox,
      map_style = map_style
    )

  if (mask) {
    # Get mask layer with area cutout
    area_snapbox_map <- area_snapbox_map +
      layer_area_mask(
        area = area_cutout,
        bbox = bbox,
        diag_ratio = diag_ratio,
        crs = mapbox_crs,
        fill = "white",
        alpha = 0.4,
        color = NA
      ) +
      # Mark edges of area
      ggplot2::geom_sf(
        data = area_cutout,
        fill = NA,
        color = "white",
        linetype = "dashed"
      )
  }

  return(area_snapbox_map)
}
