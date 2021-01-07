#' Map MTA services
#'
#' Map MTA services. MTA bus lines are currently the only supported service.
#'
#' @param area sf object. Required.
#' @param mta_services Character vector. Default is "bus_lines" to use mta_bus_lines data.
#' @param diag_ratio Numeric. Passed to \code{get_buffered_area()} function
#'
#' @export
#'
map_area_mta_services <- function(area,
                                  mta_services = "bus_lines",
                                  diag_ratio = 0.166) {
  check_area(area)

  buffered_area <- get_buffered_area(area, diag_ratio)

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
        color = "none",
        fill = ggplot2::guide_legend(
          title = "MTA Bus route number",
          override.aes = ggplot2::aes(label = "")
        )
      )
  }

  return(area_mta_map)
}
