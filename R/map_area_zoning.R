#' Map zoning for an area (not working)
#'
#' Map zoning/zoning overlay codes for an area within the city. The 2017 zoning
#' data does not include any exemptions granted by the BMZA (Board of Municipal
#' Zoning Appeals).
#'
#' @inheritParams get_area_zoning
#' @rdname map_area_zoning
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom dplyr nest_by
#' @importFrom purrr map map2 pluck
#' @importFrom ggplot2 ggplot geom_sf guides guide_legend aes
#' @importFrom ggrepel geom_label_repel
#' @importFrom grid unit
map_area_zoning <- function(area,
                            category = c("all", "residential", "commercial", "industrial"),
                            diag_ratio = 0.125,
                            asp = NULL,
                            crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {

  category <- match.arg(category)

  # Nest area data
  area_nested <-
    dplyr::nest_by(area,
                   name,
                   .keep = TRUE)

  # Get real property data for area or areas
  area_nested$zoning_data <- purrr::map(
    area_nested$data,
    ~ get_area_zoning(.x,
                      category = category,
                      diag_ratio = diag_ratio,
                      asp = asp,
                      crs = crs,
                      union = TRUE
                      )
  )

  area_zoning_map <- purrr::map2(
    area_nested$data,
    area_nested$zoning_data,
    ~ # Create map of neighborhood zoning
      ggplot2::ggplot() +
      # Map zoning codes
      ggplot2::geom_sf(data = .y,
                       aes(fill = category_zoning),
                       color = "white",
                       size = 0.75) +
      # Map neighborhood boundary
      ggplot2::geom_sf(data = .x,
                       color = "white",
                       size = 1.2,
                       fill = NA) +
      ggplot2::geom_sf(data = .x,
                       color = "gray20",
                       fill = NA,
                       linetype = 5) +
      # TODO: Add some representation of overlay codes
      # Label zoning/overlay codes
      ggrepel::geom_label_repel(data = .y,
                                aes(label = label,
                                    fill = category_zoning,
                                    geometry = geometry),
                                stat = "sf_coordinates",
                                colour = "white",
                                segment.color = "white",
                                label.size = grid::unit(0.5, "lines"),
                                label.r = grid::unit(0.0, "lines"),
                                size = grid::unit(3, "lines")
                                ) +
      # Define color scale for zoning codes/labels
      ggplot2::guides(
        fill = ggplot2::guide_legend(
          title = "Zoning category",
          override.aes = ggplot2::aes(label = "")
        )
      )
  )

  if (length(area_zoning_map) == 1) {
    return(purrr::pluck(area_zoning_map, 1))
  } else {
    return(area_zoning_map)
  }

}
