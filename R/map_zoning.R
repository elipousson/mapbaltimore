#' Map zoning for a local area
#'
#' Map showing the zoning codes for a neighborhood within the city.
#' The 2017 zoning data does not include any exemptions grants by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param neighborhood_label Name of the neighborhood in sentence case.
#' @param neighborhood_color Color of the neighborhood boundary line
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'


map_zoning <- function(neighborhood_label,
                       neighborhood_color = 'gray20') {

  # Select neighborhood based on provided label
  neighborhood <- neighborhoods[neighborhoods$name == neighborhood_label,]

  # Define a 150 meter buffer
  buffer_150m <- units::set_units(150, m)

  # Crop zoning data to a 150 meter buffer area around the neighborhood

  zoning <- sf::st_make_valid(zoning)
  neighborhood_zoning <- sf::st_crop(zoning, sf::st_buffer(neighborhood, buffer_150m))

  # Create map of neighborhood zoning
  ggplot2::ggplot() +
    # Map zoning codes
    ggplot2::geom_sf(data = neighborhood_zoning,
                     aes(fill = zoning),
                     color = NA) +
    # Map neighborhood boundary
    ggplot2::geom_sf(data = neighborhood,
                     color = neighborhood_color,
                     fill = NA,
                     linetype = 5) +
    # TODO: Add some representation of overlay codes
    # Label zoning/overlay codes
    ggsflabel::geom_sf_label_repel(data = neighborhood_zoning,
                                   ggplot2::aes(
                                     label = label,
                                     fill = zoning),
                                   colour = "white",
                                   size = 8,
                                   family = "Roboto Condensed",
                                   box.padding = grid::unit(4, "lines"),
                                   force = 8,
                                   segment.color = "darkslategrey",
                                   label.size = grid::unit(0.25, "lines"),
                                   label.padding = grid::unit(1, "lines"),
                                   label.r = grid::unit(0.0, "lines")) +
    # Define color scale for zoning codes/labels
    ggplot2::scale_colour_viridis_d() +
    # Add title
    ggplot2::labs(
      title = glue::glue("{neighborhood_label}: Zoning Code")
    )

}
