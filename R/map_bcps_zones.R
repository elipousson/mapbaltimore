#' Map BCPS School Attendance zones for a local area
#'
#' Map showing the school zones that overlap with the selected neighborhood.
#'
#' @param neighborhood_label Name of the neighborhood in sentence case.
#' @param neighborhood_color Color of the neighborhood boundary line
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'


map_bcps_zones <- function(neighborhood_label,
                           neighborhood_color = 'gray20') {

  # Select neighborhood based on provided label
  neighborhood <- neighborhoods[neighborhoods$label == neighborhood_label,]

  # Define a 1 meter buffer
  buffer_1m <- units::set_units(1, m)

  # Identify school zones that intersect neighborhood (excluding zones intersect 1 meter or less)
  neighborhood_bcps_zones <- sf::st_join(bcps_zones,
                            sf::st_buffer(neighborhood, -1*buffer_1m),
                            join = sf::st_intersects)

  # Filter to school zones that intersect neighborhood
  neighborhood_bcps_zones <- dplyr::filter(neighborhood_bcps_zones, !is.na(label))

  # Create map of BCPS school zones intersecting the neighborhood
  ggplot2::ggplot() +
    # Map bcps_zones codes
    ggplot2::geom_sf(data = neighborhood_bcps_zones,
                     aes(fill = program_name),
                     color = NA) +
    # Map neighborhood boundary
    ggplot2::geom_sf(data = neighborhood,
                     color = neighborhood_color,
                     fill = NA,
                     linetype = 5) +
    # TODO: Add school locations and/or building footprints
    # Label school zones
    ggsflabel::geom_sf_label_repel(data = neighborhood_bcps_zones,
                                   ggplot2::aes(
                                     label = program_name,
                                     fill = program_name),
                                   colour = "white",
                                   size = 8,
                                   family = "Roboto Condensed",
                                   box.padding = grid::unit(4, "lines"),
                                   force = 8,
                                   segment.color = "darkslategrey",
                                   label.size = grid::unit(0.25, "lines"),
                                   label.padding = grid::unit(1, "lines"),
                                   label.r = grid::unit(0.0, "lines")) +
    # Define color scale for school zones
    ggplot2::scale_colour_viridis_d() +
    # Add title
    ggplot2::labs(
      title = glue::glue("{neighborhood_label}: Baltimore City Public School Attendance Zones")
    )

}
