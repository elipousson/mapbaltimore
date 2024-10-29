#' Map MTA services
#'
#' `r lifecycle::badge("deprecated")`
#' Map MTA services. MTA bus lines are currently the only supported service.
#'
#' @param area sf object. Required.
#' @param mta_services Character vector. Default is "bus_lines" to use mta_bus_lines data.
#' @inheritParams adjust_bbox
#' @export
#' @importFrom grid unit
map_area_mta_services <- function(area,
                                  mta_services = "bus_lines",
                                  diag_ratio = 0.166,
                                  asp = NULL) {
  rlang::check_required("ggplot2")
  area_mta_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = get_area_streets(area, diag_ratio = diag_ratio, asp = asp),
      color = "gray80"
    ) +
    ggplot2::geom_sf(
      data = area,
      color = "gray30",
      size = 1.25,
      fill = NA,
      linetype = "dotted"
    )

  if (mta_services == "bus_lines") {
    area_mta_bus_lines <- get_area_data(
      data = mta_bus_lines,
      area = area,
      diag_ratio = diag_ratio,
      asp = asp
    )

    area_mta_map <- area_mta_map +
      ggplot2::geom_sf(
        data = area_mta_bus_lines,
        ggplot2::aes(color = route_number),
        alpha = 0.6,
        size = 2.25,
        linetype = "dotdash"
      ) +
      layer_area_streets(
        area = area,
        sha_class = c("PART", "MART", "FWY", "INT"),
        show_streets = FALSE,
        show_names = TRUE,
        diag_ratio = diag_ratio,
        name_location = "area"
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
          title = "MTA Bus Route",
          override.aes = ggplot2::aes(label = "")
        )
      )
  }

  return(area_mta_map)
}
