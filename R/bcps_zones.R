#' Map BCPS School Attendance zones for a local area
#'
#' Map showing BCPS school zones that overlap with a provided area or areas. If the area sf tibble includes multiple areas, a separate map is created for each area provided.
#'
#' @param area Name of the neighborhood in sentence case.
#'
#' @importFrom ggplot2 ggplot aes geom_sf
#' @examples
#'
#' \dontrun{
#' ## Map school attendance boundary zones for the Madison Park neighborhood
#' madisonpark <- get_area(area_type = "neighborhood", area_name = "Madison Park")
#' map_area_bcps_zones(area = madisonpark)
#' }
#'
#' \dontrun{
#' ## Map school attendance boundary zones for City Council District 2
#' district9 <- get_area(area_type = "council_district", area_name = "9")
#' map_area_bcps_zones(area = district9)
#' }
#' @export

map_area_bcps_zones <- function(area) {

  check_area(area)

  area_nested <- dplyr::nest_by(area,
    name,
    .keep = TRUE
  )

  area_nested$bcps_zone_data <- purrr::map(
    area_nested$data,
    ~ get_bcps_zones_for_area(.x)
  )

  bcps_zone_maps <- purrr::map2(
    area_nested$data,
    area_nested$bcps_zone_data,
    ~ map_bcps_zones_for_area(
      area = .x,
      area_bcps_zones = .y
    )
  )

  return(bcps_zone_maps)
}

get_bcps_zones_for_area <- function(area) {

  # Define a 1 meter buffer
  buffer_1m <- units::set_units(1, m)

  # Identify school zones that intersect area (excluding zones intersecting <= 1 meter)
  area_bcps_zones <- sf::st_join(bcps_zones,
    sf::st_buffer(area, -1 * buffer_1m),
    join = sf::st_intersects
  )

  # Filter to school zones that intersect neighborhood
  area_bcps_zones <- dplyr::filter(area_bcps_zones, !is.na(name))

  return(area_bcps_zones)
}

map_bcps_zones_for_area <- function(area,
                                    area_bcps_zones) {

  # Create map of BCPS school zones intersecting the neighborhood
  ggplot2::ggplot() +
    # Map bcps_zones codes
    ggplot2::geom_sf(
      data = area_bcps_zones,
      aes(fill = program_name),
      color = NA
    ) +
    # Map neighborhood boundary
    ggplot2::geom_sf(
      data = area,
      color = "gray20",
      fill = NA,
      linetype = 5
    ) +
    # TODO: Add school locations and/or building footprints
    # Label school zones
    ggrepel::geom_label_repel(
      data = area_bcps_zones,
      ggplot2::aes(
        label = program_name,
        fill = program_name,
        geometry = geometry
      ),
      stat = "sf_coordinates",
      colour = "white",
      size = grid::unit(4, "lines"),
      family = "Roboto Condensed",
      point.padding = NA,
      segment.color = "white",
      label.size = grid::unit(0.5, "lines"),
      label.padding = grid::unit(1, "lines"),
      label.r = grid::unit(0, "lines")
    ) +
    # Define color scale for school zones
    ggplot2::scale_colour_viridis_d() +
    # Add title
    ggplot2::labs(
      title = glue::glue("{area$name}: Baltimore City Public School Attendance Zones")
    ) +
    ggplot2::guides(fill = "none") +
    # Remove lat/lon axis text
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major = ggplot2::element_line(color = "transparent"),
      axis.title = ggplot2::element_text(color = "transparent"),
      axis.text = ggplot2::element_text(color = "transparent")
    )
}
