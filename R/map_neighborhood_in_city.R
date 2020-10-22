#' Maps a neighborhood in the context of the city
#'
#' Map showing the location of the neighborhood within the city.
#'
#' @param neighborhood_label ...
#' @param neighborhood_color ...
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf

map_neighborhood_in_city <- function(neighborhood_label,
                                     neighborhood_color = 'gray20') {

  neighborhood <- neighborhoods[neighborhoods$name == neighborhood_label,]

  ggplot2::ggplot() +
    ggplot2::geom_sf(data = baltimore_city,
                     color = 'gray50',
                     fill = NA) +
    ggplot2::geom_sf(data = sf::st_union(parks), fill = 'darkseagreen4', color = NA, alpha = 0.7) +
    ggplot2::geom_sf(data = neighborhood,
                     fill = 'gray20',
                     color = neighborhood_color) + # Neighborhood
    ggsflabel::geom_sf_label_repel(data = neighborhood,
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
    # Add title, fill label, caption, and minimal theme
    ggplot2::labs(
      title = glue::glue("{neighborhood_label}: Location in Baltimore City, Maryland")
    )
}
