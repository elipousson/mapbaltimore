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

  area_map_highlighted <- ggplot2::ggplot()

  if (highlight_name == "all") {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::facet_wrap(~name) +
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
      ggplot2::facet_wrap(
        ~name,
        ggplot2::label_value(width = 10, multi_line = TRUE)
      ) +
      ggplot2::theme(strip.text.x = ggplot2::element_text(size = 12)) +
      ggplot2::guides(fill = "none")
  }

  area_map_highlighted <- area_map_highlighted +
    ggplot2::geom_sf(
      data = sf::st_union(area),
      color = "gray30",
      fill = NA
    )

  return(area_map_highlighted)
}
