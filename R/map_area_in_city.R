#' Map area in the context of city boundaries
#'
#' Map showing the location of an area within the city.
#'
#' @param area sf object with a 'name' column. Required.
#' @param area_label area label to replace area name. Optional.
#' @importFrom ggplot2 ggplot aes geom_sf
#' @examples
#' \dontrun{
#' ## Area with a defined label
#' district2 <- get_area(
#'   type = "council district",
#'   area_id = "2"
#' )
#'
#' map_area_in_city(
#'   area = district2,
#'   area_label = "Baltimore's Second Council District"
#' )
#' }
#'
#' \dontrun{
#' ## Multiple areas in a single map
#' selected_se_neighborhoods <- get_area(
#'   type = "neighborhood",
#'   area_name = c("Upper Fells Point", "Fells Point", "Canton")
#' )
#'
#' map_area_in_city(
#'   area = selected_se_neighborhoods,
#'   area_label = "Southeast Baltimore neighborhoods"
#' )
#' }
#'
#' \dontrun{
#' ## Area with a defined map title
#' canton_industrial <- get_area(
#'   type = "neighborhood",
#'   area_name = "Canton Industrial Area"
#' )
#'
#' map_area_in_city(area = canton_industrial)
#' }
#'
#' @export
map_area_in_city <- function(area,
                             area_label = NULL) {
  rlang::check_installed("ggrepel")

  check_area(area)

  city_streets <- streets %>%
    dplyr::filter(sha_class %in% c("FWY", "INT")) %>%
    sf::st_union()

  city_water <- baltimore_water %>%
    sf::st_union() %>%
    sf::st_crop(baltimore_city)

  # Create city_map background with detailed physical boundary and parks
  city_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = baltimore_city_detailed,
      fill = "ivory2",
      color = NA
    ) +
    ggplot2::geom_sf(
      data = sf::st_union(parks),
      fill = "darkseagreen3",
      color = NA
    ) +
    ggplot2::geom_sf(
      data = city_water,
      fill = "skyblue4",
      color = "skyblue4",
      alpha = 0.8
    ) +
    ggplot2::geom_sf(
      data = city_streets,
      color = "slategray",
      fill = NA,
      alpha = 0.8,
      size = 0.6
    ) +
    ggplot2::geom_sf(
      data = baltimore_city,
      color = "white",
      fill = NA,
      size = 1.2
    ) +
    ggplot2::geom_sf(
      data = baltimore_city,
      color = "gray25",
      fill = NA,
      size = 0.4
    )

  if (length(area$name) > 1) {
    # Add a discrete color scale if more than one area is provided
    area_map <- city_map +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = "gray30",
        alpha = 0.8,
        size = 0.4
      ) +
      ggplot2::scale_fill_viridis_d()
  } else {
    # Set area fill to  "gray20" if one area is provided
    area_map <- city_map +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = "gray50",
        alpha = 0.8,
        size = 0.4
      )
  }

  # Replace area name with label if provided
  if (is.character(area_label)) {
    area$name <- area_label
  }

  label_location <- buffer_area(area, dist = 1) %>%
    sf::st_difference(area) %>%
    sf::st_point_on_surface()

  area_map <- area_map +
    # Label area or areas
    ggrepel::geom_label_repel(
      data = label_location,
      ggplot2::aes(
        label = name,
        geometry = geometry
      ),
      stat = "sf_coordinates",
      size = 6,
      fill = "gray25",
      color = "white",
      box.padding = grid::unit(2, "lines"),
      min.segment.length = 0,
      segment.colour = "gray50",
      force = 30,
      label.padding = grid::unit(0.75, "lines"),
      label.r = grid::unit(0.05, "lines")
    ) +
    ggplot2::guides(fill = "none")

  return(area_map)
}
