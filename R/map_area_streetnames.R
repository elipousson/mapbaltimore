#' Map area with street names labelled at selected locations
#'
#' Map streets within an area or areas with street name labels at selected locations.
#'
#' @param area sf class tibble. Object must include a name column.
#' @param label_location Character vector. Must be "area", "edge", "topright", or "bottomleft"
#' @param sha_class Logical. Option to label all streets (FALSE) or only State Highway Administration classified streets (TRUE). Default is TRUE.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'

map_area_streetnames <- function(area,
                                 label_location = c("area", "edge", "topright", "bottomleft"),
                                 sha_class = TRUE) {

  # Check area
  check_area(area)

  # Get area bbox
  area_bbox <- sf::st_bbox(area)

  # Calculate the diagonal distance of the area
  area_bbox_diagonal <- sf::st_distance(
    sf::st_point(c(area_bbox$xmin, area_bbox$ymin)),
    sf::st_point(c(area_bbox$xmax, area_bbox$ymax))
  )

  # Generate buffer proportional (1/8) to the diagonal distance
  buffer_diagonal <- units::set_units(area_bbox_diagonal * 0.125, m)

  # Set additional buffers (non-proportional)
  buffer_area <- units::set_units(1, m)
  buffer_edge <- units::set_units(6, m)
  buffer_edge_exclude <- units::set_units(3, m)

  # Crop to bounding rectangle porportional to diagonal distance
  area_streets_buffer <- streets %>%
    dplyr::filter(subtype != "STRALY") %>%
    sf::st_crop(sf::st_buffer(area, buffer_diagonal))

  # Intersect streets and area (buffered one meter to capture streets used as boundary lines)
  area_streets <- streets %>%
    dplyr::filter(subtype != "STRALY") %>%
    sf::st_intersection(sf::st_buffer(area, buffer_area))

  # Create a smaller bounding box based on buffer around area
  area_edge <- sf::st_buffer(area, buffer_edge)
  area_edge_bbox <- sf::st_bbox(area_edge)

  if (label_location == "area") {

    area_streets_label <- area_streets

  } else if (label_location == "edge") {

    edge_exclude_area <- sf::st_buffer(area, buffer_edge_exclude)

    area_streets_label <- area_streets_buffer %>%
      sf::st_intersection(area_edge) %>%
      sf::st_difference(edge_exclude_area)

  } else if (label_location == "topright") {

    bottomleft_bbox <- sf::st_sf(
      name = "bottomleft",
      geometry = sf::st_sfc(sf::st_convex_hull(
        x = c(
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymin)),
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymin))
        )
      ))
    ) %>%
      sf::st_set_crs(2804)

    bottomleft_exclude_area <- sf::st_union(
      sf::st_buffer(area, buffer_edge_exclude),
      bottomleft_bbox)

    area_streets_label <- area_streets_buffer %>%
      sf::st_intersection(area_edge) %>%
      sf::st_difference(bottomleft_exclude_area)

  } else if (label_location == "bottomleft") {

    topright_bbox <- sf::st_sf(
      name = "topright",
      geometry = sf::st_sfc(sf::st_convex_hull(
        x = c(
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymin))
        )
      ))
    ) %>%
      sf::st_set_crs(2804)

    topright_exclude_area <- sf::st_union(
      sf::st_buffer(area, buffer_edge_exclude),
      topright_bbox)

    area_streets_label <- area_streets_buffer %>%
      sf::st_intersection(area_edge) %>%
      sf::st_difference(topright_exclude_area)

  }

  # Limit to SHA classified streets if sha_class is TRUE
  if (sha_class == TRUE) {
    area_streets_label <- area_streets_label %>%
      dplyr::filter(!is.na(sha_class))
  }

  # Combine geometry of streets with the same name
  area_streets_label <- area_streets_label %>%
    dplyr::group_by(fullname) %>%
    dplyr::summarise(
      geometry = sf::st_union(geometry)
    )

  set_map_theme() # Set map theme

  area_streets_labelled <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = area_streets_buffer,
      size = 0.85,
      color = "gray50"
    ) +
    ggplot2::geom_sf(
      data = area_streets,
      size = 1.15,
      color = "gray70"
    ) +
    ggplot2::geom_sf(
      data = area,
      color = "black",
      fill = "yellow",
      linetype = 5,
      alpha = 0.3
    ) +
    ggrepel::geom_label_repel(
      data = area_streets_label,
      aes(label = fullname,
          geometry = geometry),
      stat = "sf_coordinates",
      size = grid::unit(3, "lines"),
      family = "Roboto Condensed",
      label.r = grid::unit(0, "lines"),
      point.padding = NA
    ) +
    ggplot2::expand_limits(
      x = area_bbox$xmin - area_bbox_diagonal * 0.15,
      y = area_bbox$ymin - area_bbox_diagonal * 0.15
    )

  return(area_streets_labelled)
}
