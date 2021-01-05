#' Get zoning data a local area
#'
#' Get zoning codes for an area within the city.
#' The 2017 zoning data does not include any exemptions grants by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#' @param dist  If default (NULL), the returned real property data includes property within a default buffered distance (1/8th of the diagonal distance across the bounding box). If numeric, the function returns data cropped to area buffered by this distance in meters.
#'
#' @importFrom ggplot2 ggplot aes geom_sf
#' @export
#'

get_zoning <- function(area,
                       dist = NULL) {

  check_area(area)

  # Get buffered area
  buffered_area <- get_buffered_area(area, dist)

  # Crop zoning data to a buffered area
  area_zoning <- zoning %>%
    sf::st_crop(buffered_area)

  # Union geometry by label
  #  area_zoning <- area_zoning %>%
  #    dplyr::group_by(label) %>%
  #   dplyr::summarise(
  #      geometry = sf::st_union(geometry)
  #    )

    return(area_zoning)
}

#' Map zoning for a local area
#'
#' Map zoning/zoning overlay codes for an area within the city.
#' The 2017 zoning data does not include any exemptions granted by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#'
#' @examples
#' \dontrun{
#' ## Map zoning code for Bayview neighborhood
#' bayview <- get_area(type = "neighborhood", area_name = "Bayview")
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
    ~ get_zoning(.x)
  )

  set_map_theme() # Set theme

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
      ggplot2::scale_fill_viridis_d(end = 0.8) +
      # Add title
      ggplot2::labs(
        title = glue::glue("{.x$name}: Zoning Code")
      )
  )

  if (length(area_zoning_map) == 1) {
    return(area_zoning_map[[1]])
  } else {
    return(area_zoning_map)
  }

}
