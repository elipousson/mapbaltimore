#' Map real property data to show tenure for neighborhood
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant, and unimproved.
#' Parcel data is from the Maryland State Department of Assessment and Taxation and may include errors.
#'
#' @param neighborhood_label Required. Name of the neighborhood in sentence case
#' @param neighborhood_color Optional. Color of the neighborhood boundary line
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'

map_tenure <- function(neighborhood_label,
                       neighborhood_color = 'gray20') {

  # TODO: Implement checks for one or more neighborhoods
  # TODO: Add options for mapping by CSA or arbitrary area
  # Select neighborhood based on provided label
  neighborhood <- neighborhoods[neighborhoods$label == neighborhood_label,]

  # Define a 25 meter buffer
  buffer <- units::set_units(25, m)

  # Crop real_property data to a 25 meter buffer area around the neighborhood
  neighborhood_real_property <- sf::st_crop(real_property, sf::st_buffer(neighborhood, buffer))


  # Create an status variable for improvements, vacancy, and owner-occupancy status
  neighborhood_real_property <- dplyr::mutate(neighborhood_real_property,
                                              status = dplyr::case_when(
                                                no_imprv == "Y" ~ "Unimproved property",
                                                vacind == "Y" ~ "Vacant property",
                                                permhome == "H" ~ "Principal residence only",
                                                permhome == "D" ~ "Principal residence (and another use)",
                                                permhome == "N" ~ "Not a principal residence"))


  neighborhood_real_property$status <- forcats::fct_relevel(neighborhood_real_property$status,
                                                            c("Principal residence only", "Principal residence (and another use)",
                                                              "Not a principal residence", "Vacant property", "Unimproved property"))
  # Create map of neighborhood real_property
  ggplot2::ggplot() +
    # Map real_property codes
    ggplot2::geom_sf(data = neighborhood_real_property,
                     aes(fill = status),
                     color = NA) +
    # Define color scale for status variable
    ggplot2::scale_fill_viridis_d() +
    # Map neighborhood boundary
    ggplot2::geom_sf(data = neighborhood,
                     color = neighborhood_color,
                     fill = NA,
                     linetype = 5) +
    # Add title, fill label, caption, and minimal theme
    ggplot2::labs(
      title = glue::glue("{neighborhood_label}: Properties by occupancy and tenure status"),
      fill = "Property status",
      caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
    ) +
    ggplot2::theme_minimal()

}
