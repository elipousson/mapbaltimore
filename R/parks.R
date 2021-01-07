#' Map area parks and open spaces
#'
#' Return a ggplot map showing parks in and around a selected area.
#'
#' @param area sf object. Required.
#' @param diag_ratio ratio to set map extent based diagonal distance of area's bounding box. Passed to \code{\link{get_buffered_area}}.
#' @param type layers to show on map ("parks" or "vacant lots"). Defaults to both.
#' @param label layers to label. Only "parks" is supported. Use any other value to exclude labels.
#'
#' @export
#'

map_area_parks <- function(area,
                           diag_ratio = 0.125,
                           type = c("parks", "vacant lots"),
                           label = c("parks")) {

  area_buffered <- get_buffered_area(area,
    diag_ratio = diag_ratio
  )
  area_park_map <- ggplot2::ggplot()

  if ("vacant lots" %in% type) {
    area_park_map <- area_park_map +
      ggplot2::geom_sf(
        data = dplyr::filter(real_property, no_imprv == "Y"),
        fill = "darkgreen",
        color = NA,
        alpha = 0.6
      )
  }

  if ("parks" %in% type) {
    area_park_map <- area_park_map +
      ggplot2::geom_sf(
        data = parks,
        fill = "darkgreen",
        color = NA
      )
  }

  area_park_map <- area_park_map +
    ggplot2::geom_sf(
      data = get_area_streets(area_buffered,
        sha_class = c("COLL", "PART", "MART", "FWY", "INT")
      ),
      color = "gray70"
    ) +
    ggplot2::geom_sf(
      data = area,
      fill = NA,
      color = "white",
      size = 1.6
    ) +
    ggplot2::geom_sf(
      data = area,
      fill = "gray80",
      alpha = 0.2,
      color = "gray20",
      linetype = "dashed",
      size = 0.8
    )

  if ("parks" %in% label) {
    area_park_map <- area_park_map +
      ggrepel::geom_label_repel(
        data = sf::st_crop(parks, area_buffered),
        ggplot2::aes(
          label = name,
          geometry = geometry
        ),
        stat = "sf_coordinates",
        size = 4,
        fill = "white",
        color = "darkgreen",
        box.padding = grid::unit(2, "lines"),
        segment.colour = "gray10",
        force = 15,
        label.padding = grid::unit(0.75, "lines"),
        label.r = grid::unit(0.05, "lines")
      )
  }

  area_park_map <- area_park_map +
    ggplot2::geom_sf(data = baltimore_water,
                     color = "darkblue",
                     alpha = 0.4) +
    expand_limits_to_area(area_buffered) +
    ggplot2::labs(title = "Public Parks and Unimproved Lots")

  return(area_park_map)
}
