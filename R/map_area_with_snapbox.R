#' Map area using the snapbox package
#'
#' Map an area or areas using the \code{\link{snapbox}} package.
#'
#' @param area Required sf object with a 'name' column.
#' @param map_style Required. \code{\link{stylebox}} function referencing mapbox map styles. Default is \code{\link[stylebox]{mapbox_satellite_streets()}}
#' @inheritParams adjust_bbox
#' @param show_mask Logical. Default TRUE. If TRUE, apply a transparent (alpha = 0.4) white mask over the Mapbox map outside the area. Uses the layer_area_mask function.
#' @export
#' @importFrom snapbox layer_mapbox mapbox_satellite_streets
#' @importFrom sf st_transform st_bbox
#' @importFrom ggplot2 ggplot geom_sf
map_area_with_snapbox <- function(area,
                                  map_style = snapbox::mapbox_satellite_streets(),
                                  diag_ratio = 0.125,
                                  dist = NULL,
                                  asp = NULL,
                                  show_mask = TRUE,
                                  ...) {

  # Set appropriate CRS for Mapbox
  crs_mapbox <- 3857

  # Get adjusted bounding box if any adjustment variables provided
  bbox <- adjust_bbox(
      area = area,
      diag_ratio = diag_ratio,
      dist = dist,
      asp = asp,
      crs = crs_mapbox
    )

  if (Sys.getenv("MAPBOX_PUBLIC_TOKEN") == "") {
    stop("A Mapbox access token is required to use the `map_area_with_snapbox` function. Use `mapboxapi::mb_access_token` to install a token to your local environment.")
  }

  # Get Mapbox map
  area_snapbox_map <- ggplot2::ggplot() +
    snapbox::layer_mapbox(
      area = bbox,
      map_style = map_style,
      mapbox_api_access_token = Sys.getenv("MAPBOX_PUBLIC_TOKEN")
    )

  if (show_mask) {
    # Get mask layer with area cutout
    area_snapbox_map <- area_snapbox_map +
      layer_area_mask(
        area = area,
        bbox = bbox,
        diag_ratio = diag_ratio,
        crs = crs_mapbox,
        fill = "white",
        alpha = 0.4,
        color = NA,
        ...
      ) +
      # Mark edges of area
      ggplot2::geom_sf(
        data = area,
        fill = NA,
        color = "white",
        linetype = "dashed"
      )
  }

  return(area_snapbox_map)
}
