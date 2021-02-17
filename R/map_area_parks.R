#' Map area parks and open spaces
#'
#' Return a ggplot map showing parks in and around a selected area.
#'
#' @param area sf object. Required.
#' @param type layers to show on map ("parks" or "vacant lots"). Defaults to both.
#' @param label layers to label. Only "parks" is supported. Use any other value to exclude labels.
#' @inheritParams adjust_bbox
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#' @importFrom grid unit
#' @importFrom sf st_crop
#' @importFrom ggrepel geom_label_repel
#'
map_area_parks <- function(area,
                           type = c("parks", "vacant lots"),
                           label = c("parks"),
                           dist = NULL,
                           diag_ratio = 0.125,
                           asp = NULL) {
  area_adj_bbox <- adjust_bbox(
    area = area,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp
  )

  area_park_map <- ggplot2::ggplot()

  if ("vacant lots" %in% type) {
    area_unimproved_property <- get_area_data(
      bbox = area_adj_bbox,
      extdata = "unimproved_property",
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp
    )

    area_park_map <- area_park_map +
      ggplot2::geom_sf(
        data = area_unimproved_property,
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
      data = get_area_streets(
        bbox = area_adj_bbox,
        sha_class = c("COLL", "PART", "MART", "FWY", "INT"),
        dist = dist,
        diag_ratio = diag_ratio,
        asp = asp
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
      ggplot2::geom_sf(
        data = baltimore_water,
        fill = "darkblue",
        alpha = 0.4
      ) +
      ggrepel::geom_label_repel(
        data = sf::st_crop(parks, area_adj_bbox),
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
    set_map_limits(bbox = area_adj_bbox)

  return(area_park_map)
}
