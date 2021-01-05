#' Maps an area in the context of the city
#'
#' Map showing the location of an area within the city.
#'
#' @param area Required sf object with a 'name' column.
#' @param area_label Optional character vector of any length. Replaces the name column in the provided area sf object as the label and in the title (if map_title is not provided).
#' @param map_title Optional character vector of length 1 to replace the default map title.
#' @importFrom ggplot2 ggplot aes geom_sf
#' @examples
#'
#' \dontrun{
#' ## Area with a defined label
#' district2 <- get_area(
#' type =  "council district",
#' name =  "2")
#'
#' map_area_in_city(
#' area = district2,
#' area_label = "Council District 2")
#' }
#'
#' \dontrun{
#' ## Multiple areas in a single map
#' selected_se_neighborhoods <- get_area(
#' type =  "neighborhood",
#' name =  c("Upper Fells Point", "Fells Point", "Canton"))
#'
#' map_area_in_city(area = selected_se_neighborhoods)
#' }
#'
#' \dontrun{
#' ## Area with a defined map title
#' canton_industrial <- get_area(
#' type =  "neighborhood",
#' name =  "Canton Industrial Area")
#'
#' map_area_in_city(
#' area = canton_industrial,
#' map_title = "Canton Industrial Area is the largest neighborhood areas in Baltimore")
#' }
#'
#' @export
#'
map_area_in_city <- function(area,
                             area_label = NULL,
                             map_title = NULL) {

  check_area(area)

  city_streets <- sf::st_union(dplyr::filter(streets, sha_class %in% c("FWY", "INT")))
  city_parks <- sf::st_union(parks)
  city_water <- sf::st_combine(baltimore_water)

  # Create city_map background with detailed physical boundary and parks
  city_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = baltimore_city,
                     fill = 'cadetblue3',
                     color = NA) +
    ggplot2::geom_sf(data = baltimore_city_detailed,
                     fill = 'linen',
                     color = NA) +
    ggplot2::geom_sf(data = city_parks,
                     fill = 'darkseagreen3',
                     color = NA) +
    ggplot2::geom_sf(data = city_water,
                     fill = 'cadetblue3',
                     color = 'cadetblue4',
                     alpha = 0.8) +
    ggplot2::geom_sf(data = city_streets,
                     color = 'slategray',
                     fill = NA,
                     alpha = 0.8,
                     size = 0.8) +
    ggplot2::geom_sf(data = baltimore_city_detailed,
                     color = 'gray25',
                     fill = NA,
                     size = 0.3)

  if (length(area$name) > 1) {
    # Add a discrete color scale if more than one area is provided
    area_map <- city_map +
      ggplot2::geom_sf(data = area,
                       ggplot2::aes(fill = name),
                       color = 'gray50',
                       alpha = 0.8,
                       size = 0.4)
      ggplot2::scale_fill_viridis_d()

  } else {
    # Set area fill to  'gray20' if one area is provided
    area_map <- city_map + ggplot2::geom_sf(data = area,
                                              ggplot2::aes(fill = name),
                                              color = 'gray50',
                                              fill = 'gray25',
                                              alpha = 0.8,
                                              size = 0.4)
  }

  # Replace area name with label if provided
  if (is.character(area_label)) {area$name <- area_label}

  label_location <- get_buffered_area(area, dist = 2) %>%
    sf::st_difference(area) %>%
    sf::st_point_on_surface()

  set_map_theme() # Set map theme

  area_map <- area_map +
    # Label area or areas
    ggrepel::geom_label_repel(data = label_location,
                              ggplot2::aes(label = name,
                                           geometry = geometry),
                              stat = "sf_coordinates",
                              size = 6,
                              fill = "gray25",
                              color = "white",
                              box.padding = grid::unit(2, "lines"),
                              family = "Roboto Condensed",
                              min.segment.length = 0,
                              segment.colour = "gray50",
                              force = 30,
                              label.padding = grid::unit(0.75, "lines"),
                              label.r = grid::unit(0.05, "lines")) +
    ggplot2::guides(fill = "none")

  if (!is.null(map_title)){
    # Use map title if map_title is provided
    area_map <- area_map + ggplot2::labs(
      title = map_title
    )
  } else if (length(area$name) == 1) {
    # Use area name if one area is provided
    area_map <- area_map + ggplot2::labs(
      title = glue::glue("{area$name} in Baltimore City, Maryland")
      )
  } else if (length(area$name) > 1) {
    # Use area names if more than one area is provided
    map_title <- paste0(area$name[1:length(area$name)-1], collapse = ", ")
    map_title <- glue::glue("{map_title} and {area$name[length(area$name)]} in Baltimore City, Maryland")

    area_map <- area_map + ggplot2::labs(
      title = map_title
    )
  }

  return(area_map)
}

#' Maps a highlighted area within the context of multiple areas
#'
#' Map highlighting the location of an area the context of multiple areas.
#'
#' @param area Required sf object with a 'name' column.
#' @param highlight_name Character vector. Required. Use "all" to create a grid of maps highlighting each area in the provided sf object or provide the name of one or more areas to highlight.
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#'
map_area_highlighted <- function(area,
                                 highlight_name = "all") {

  if (length(area$geometry) == 1) {
    warning("map_area_highlighted is designed to work with multiple areas")
  }

  area_map_highlighted <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = sf::st_union(area),
      color = "gray30",
      fill = NA
    )

  if (highlight_name == "all") {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::facet_wrap(~ name) +
      ggplot2::guides(fill = "none")
  } else if (is.character(highlight_name) && (length(highlight_name) == 1)) {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = dplyr::filter(area, name == highlight_name),
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::guides(fill = "none") +
      ggplot2::labs(title = highlight_name)
  } else if (is.character(highlight_name) && (length(highlight_name) > 1)) {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = dplyr::filter(area, name %in% highlight_name),
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::facet_wrap(~ name) +
      ggplot2::guides(fill = "none")
  }

  return(area_map_highlighted)
}

#' Maps an area or areas using the snapbox package
#'
#' Map an area or areas using the \code{\link{snapbox}} package.
#'
#' @param area Required sf object with a 'name' column.
#' @param map_style Required. \code{\link{stylebox}} function referencing mapbox map styles. Default is \code{\link{stylebox::mapbox_satellite_streets()}}
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#'
map_area_with_snapbox <- function(area,
                                  map_style = stylebox::mapbox_satellite_streets()) {
  ggplot2::ggplot() +
    snapbox::layer_mapbox(
      area = sf::st_bbox(sf::st_transform(get_buffered_area(area), 3857)),
      map_style = map_style
    ) +
    ggplot2::geom_sf(
      data = get_area_mask(area, crs = 3857),
      fill = "white",
      color = NA,
      alpha = 0.4
    ) +
    ggplot2::geom_sf(
      data = area,
      fill = NA,
      color = "white",
      linetype = 5
    )
}
