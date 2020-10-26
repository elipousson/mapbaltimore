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
#' area_type = "council_district",
#' area_name = "2")
#'
#' map_area_in_city(
#' area = district2,
#' area_label = "Council District 2")
#' }
#'
#' \dontrun{
#' ## Multiple areas in a single map
#' selected_se_neighborhoods <- get_area(
#' area_type = "neighborhood",
#' area_name = c("Upper Fells Point", "Fells Point", "Canton"))
#'
#' map_area_in_city(area = selected_se_neighborhoods)
#' }
#'
#' \dontrun{
#' ## Area with a defined map title
#' canton_industrial <- get_area(
#' area_type = "neighborhood",
#' area_name = "Canton Industrial Area")
#'
#' map_area_in_city(
#' area = canton_industrial,
#' map_title = "Canton Industrial Area is the largest neighborhood areas in Baltimore")
#' }
#'
#' @export

map_area_in_city <- function(area,
                             area_label = NULL,
                             map_title = NULL) {

  check_area(area)

  city_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(data = baltimore_city_detailed,
                     color = 'gray50',
                     fill = NA) +
    ggplot2::geom_sf(data = sf::st_union(parks), fill = 'darkseagreen4', color = NA, alpha = 0.7)

  if (length(area$name) > 1) {
    area_map <- city_map +
      ggplot2::geom_sf(data = area,
                       aes(fill = name),
                       color = 'white',
                       alpha = 0.75) +
      ggplot2::scale_fill_viridis_d()
  } else {
    area_map <- city_map + ggplot2::geom_sf(data = area,
                                            fill = 'gray20',
                                            color = 'white',
                                            alpha = 0.75)
  }

  # Replace area name with label if provided
  if (is.character(area_label)) {area$name <- area_label}

  area_map <- area_map + # Area
    ggsflabel::geom_sf_label_repel(data = area,
                                   ggplot2::aes(label = name),
                                   color = 'white',
                                   fill = 'darkslategrey',
                                   size = 8,
                                   family = "Roboto Condensed",
                                   box.padding = grid::unit(8, "lines"),
                                   force = 10,
                                   segment.color = 'darkslategrey',
                                   label.size = 0.0,
                                   label.padding = grid::unit(1, "lines"),
                                   label.r = grid::unit(0.0, "lines")) +
    ggplot2::guides(fill = "none") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major = element_line(color = "transparent"),
      axis.title = element_text(color = "transparent"),
      axis.text = element_text(color = "transparent")
    )

  if (!is.null(map_title)){
    area_map <- area_map + ggplot2::labs(
      title = map_title
    )
  } else if (length(area$name) == 1) {
    area_map <- area_map + ggplot2::labs(
      title = glue::glue("{area$name} in Baltimore City, Maryland")
      )
  } else if (length(area$name) > 1) {

    map_title <- paste0(area$name[1:length(area$name)-1], collapse = ", ")

    map_title <- glue::glue("{map_title} and {area$name[length(area$name)]} in Baltimore City, Maryland")

    area_map <- area_map + ggplot2::labs(
      title = map_title
    )
  }

  return(area_map)
}
