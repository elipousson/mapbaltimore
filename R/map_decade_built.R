#' Map real property data to show decade built
#'
#' Map showing parcels described by decade built.
#' Parcel data is from the Maryland State Department of Assessment and Taxation and may include errors.
#'
#' @param neighborhood_label Required. Name of the neighborhood in sentence case
#' @param neighborhood_color Optional. Color of the neighborhood boundary line
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'

map_decade_built <- function(neighborhood_label,
                             neighborhood_color = 'gray20') {

  # Select neighborhood based on provided label
  neighborhood <- neighborhoods[neighborhoods$label == neighborhood_label,]

  # Define a 25 meter buffer
  buffer <- units::set_units(25, m)

  # Crop real_property data to a 25 meter buffer area around the neighborhood
  neighborhood_real_property <- sf::st_crop(real_property, sf::st_buffer(neighborhood, buffer))

  neighborhood_real_property <- dplyr::mutate(neighborhood_real_property,
                                              decade_start = floor(year_build / 10) * 10)

  # Replace 0 value decade start with NA
  neighborhood_real_property[neighborhood_real_property$decade_start == 0,"decade_start"] <- NA

  # Create map of neighborhood real_property
  ggplot2::ggplot() +
    # Map real_property codes
    ggplot2::geom_sf(data = neighborhood_real_property,
                     aes(fill = decade_start),
                     color = NA) +
    # Define color scale for status variable
    ggplot2::scale_fill_viridis_c(na.value = "gray80") +
    # Map neighborhood boundary
    ggplot2::geom_sf(data = neighborhood,
                     color = neighborhood_color,
                     fill = NA,
                     linetype = 5) +
    # Add title
    ggplot2::labs(
      title = glue::glue("{neighborhood_label}: Properties by decade of construction"),
      fill = "Decade start year",
      caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
    ) +
    # TODO: Figure out a better way to handle themes in this package
    ggplot2::theme_minimal()

}
