#' Get zoning data a local area
#'
#' Get zoning codes for an area within the city.
#' The 2017 zoning data does not include any exemptions grants by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#' @param buffer Logical. Defaults to FALSE. Option to get zoning data for the area and a surrounding buffer (TRUE) or only the area (FALSE).
#' @param buffer_distance Numeric. If no value is provided, the buffer is set as 1/8 (0.125) the diagonal corner-to-corner distance across the bounding box.
#'
#' @importFrom ggplot2 ggplot aes geom_sf
#' @export
#'

get_zoning <- function(area,
                       buffer = FALSE,
                       buffer_distance = 0) {
  check_area(area)

  # Make zoning valid
  zoning <- sf::st_make_valid(zoning)

  # If buffer is TRUE and no buffer_distance is provided
  if ((buffer == TRUE) && (buffer_distance == 0)) {

    # Get bounding box
    area_bbox <- sf::st_bbox(area)

    # Calculate the diagonal distance of the area
    area_bbox_diagonal <- sf::st_distance(
      sf::st_point(c(area_bbox$xmin, area_bbox$ymin)),
      sf::st_point(c(area_bbox$xmax, area_bbox$ymax))
    )

    # Generate buffer proportional (1/8) to the diagonal distance
    buffer_meters <- units::set_units(area_bbox_diagonal * 0.125, m)
  } else if ((buffer == TRUE) && (buffer_distance != 0)) {
    buffer_meters <- units::set_units(buffer_distance, m)
  }

  if (buffer == TRUE) {
    # Crop real_property data to a buffered area
    area_zoning <- sf::st_crop(
      zoning,
      sf::st_buffer(area, buffer_meters)
    )
  } else if (buffer == FALSE) {
    area_zoning <- sf::st_crop(
      zoning,
      area
    )

    area_zoning <- area_zoning %>%
      dplyr::group_by(label) %>%
      dplyr::summarise(
        geometry = sf::st_union(geometry)
      )

    return(area_zoning)
  }
}

#' Map zoning for a local area
#'
#' Map zoning/zoning overlay codes for an area within the city.
#' The 2017 zoning data does not include any exemptions grants by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#'
#' @examples
#' \dontrun{
#' ## Map zoning code for Bayview neighborhood
#' bayview <- get_area(area_type = "neighborhood", area_name = "Bayview")
#' map_zoning(area = bayview)
#' }
#' @importFrom ggplot2 ggplot aes geom_sf
#' @export

map_zoning <- function(area) {

  check_area(area)

  # Nest area data
  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  # Get real property data for area or areas
  area_nested$zoning_data <- purrr::map(
    area_nested$data,
    ~ get_zoning(.x, buffer = TRUE)
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
                       color = 'gray20',
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
                                size = grid::unit(3, "lines"),
                                family = "Roboto Condensed"
                                ) +
      # Define color scale for zoning codes/labels
      ggplot2::scale_fill_viridis_d(option = "plasma", end = 0.8) +
      # Add title
      ggplot2::labs(
        title = glue::glue("{.x$name}: Zoning Code")
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_line(color = "transparent"),
        axis.title = ggplot2::element_text(color = "transparent"),
        axis.text = ggplot2::element_text(color = "transparent")
      )
  )

  if (length(area_zoning_map) == 1) {
    return(area_zoning_map[[1]])
  } else {
    return(area_zoning_map)
  }

}
