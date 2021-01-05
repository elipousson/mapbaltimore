#' Map MTA services
#'
#' Map MTA services. MTA bus lines are currently the only supported service.
#'
#' @param area sf object. Required.
#' @param mta_services Character vector. Default is "bus_lines"
#'
#' @export
#'
map_area_mta_services <- function(area,
                                  mta_services = "bus_lines") {
  check_area(area)

  buffered_area <- get_buffered_area(area, diag_ratio = 0.166)

  # set_map_theme()

  area_mta_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = get_area_streets(buffered_area),
      color = "gray70"
    ) +
    ggplot2::geom_sf(
      data = area,
      color = "gray30",
      size = 1.5,
      fill = NA,
      linetype = "dashed"
    )

  if (mta_services == "bus_lines") {
    area_mta_bus_lines <- mta_bus_lines %>%
      sf::st_crop(buffered_area)
    # area_mta_bus_stops <- mta_bus_stops %>%
    #   sf::st_crop(buffered_area)

    area_mta_map <- area_mta_map +
      ggplot2::geom_sf(
        data = area_mta_bus_lines,
        ggplot2::aes(color = route_number),
        alpha = 0.6,
        size = 2.25,
        linetype = "dotdash"
      ) +
      label_area_streets(buffered_area,
        sha_class = c("MART", "FWY", "INT")
      ) +
      ggplot2::geom_sf_label(
        data = area_mta_bus_lines,
        ggplot2::aes(
          label = route_number,
          fill = route_number
        ),
        size = grid::unit(4, "lines"),
        label.r = grid::unit(0.2, "lines"),
        label.padding = grid::unit(0.6, "lines"),
        color = "white"
      ) +
      ggplot2::guides(
        label = "none",
        color = "none"
      )
  }

  return(area_mta_map)
}
