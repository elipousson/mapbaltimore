#' Get zoning data a local area
#'
#' Get zoning codes for an area within the city.
#' The 2017 zoning data does not include any exemptions granted by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#' @param category Zoning category to return. "all", "residential", "commercial", "industrial"
#' @inheritParams get_area_data
#'
#' @importFrom ggplot2 ggplot aes geom_sf
#' @export
#'
get_area_zoning <- function(area,
                            category = c("all", "residential", "commercial", "industrial"),
                            diag_ratio = 0.125,
                            dist = NULL,
                            trim = FALSE,
                            crs = 2804) {

  category <- match.arg(category)

  # Crop zoning data to a buffered area
  area_zoning <- get_area_data(data = zoning,
                               area = area,
                               diag_ratio, dist, trim, crs)

  residential_zoning <- c("Rowhouse and Multi-Family Residential Districts",
                          "Detached and Semi-Detached Residential Districts",
                          "Open-Space and Environmental Districts")
  commercial_zoning <- c("Commercial Districts")
  industrial_zoning <-  c("Industrial Districts" )

  if (category == "residential") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning %in% residential_zoning)
  } else if (category == "commercial") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning %in% commercial_zoning)
  } else if (category == "industrial") {
    area_zoning <- area_zoning %>%
      dplyr::filter(category_zoning %in% industrial_zoning)
  }

  # Union geometry by label
  #  area_zoning <- area_zoning %>%
  #    dplyr::group_by(label) %>%
  #   dplyr::summarise(
  #      geometry = sf::st_union(geometry)
  #    )

    return(area_zoning)
}

#' Map zoning for a local area
#'
#' Map zoning/zoning overlay codes for an area within the city.
#' The 2017 zoning data does not include any exemptions granted by the BMZA (Board of Municipal Zoning Appeals).
#'
#' @param area Required sf object with a 'name' column.
#' @param category "all", "residential", "commercial", or "industrial"
#' @param diag_ratio
#'
#' @examples
#' \dontrun{
#' ## Map zoning code for Bayview neighborhood
#' bayview <- get_area(type = "neighborhood", area_name = "Bayview")
#' map_zoning(area = bayview)
#' }
#' @importFrom ggplot2 ggplot aes geom_sf
#' @export

map_area_zoning <- function(area,
                       category = c("all", "residential", "commercial", "industrial"),
                       diag_ratio = 0.125) {

  check_area(area)

  category <- match.arg(category)

  # Nest area data
  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  # Get real property data for area or areas
  area_nested$zoning_data <- purrr::map(
    area_nested$data,
    ~ get_area_zoning(.x, diag_ratio = diag_ratio, category = category)
  )

  area_zoning_map <- purrr::map2(
    area_nested$data,
    area_nested$zoning_data,
    ~ # Create map of neighborhood zoning
      ggplot2::ggplot() +
      # Map zoning codes
      ggplot2::geom_sf(data = .y,
                       aes(fill = category_zoning),
                       color = "white",
                       size = 0.75) +
      # Map neighborhood boundary
      ggplot2::geom_sf(data = .x,
                       color = "white",
                       size = 1.2,
                       fill = NA) +
      ggplot2::geom_sf(data = .x,
                       color = "gray20",
                       fill = NA,
                       linetype = 5) +
      # TODO: Add some representation of overlay codes
      # Label zoning/overlay codes
      ggrepel::geom_label_repel(data = .y,
                                aes(label = label,
                                    fill = category_zoning,
                                    geometry = geometry),
                                stat = "sf_coordinates",
                                colour = "white",
                                segment.color = "white",
                                label.size = grid::unit(0.5, "lines"),
                                label.r = grid::unit(0.0, "lines"),
                                size = grid::unit(3, "lines")
                                ) +
      # Define color scale for zoning codes/labels
      ggplot2::scale_fill_viridis_d(end = 0.8) +
      # Add title
      ggplot2::labs(
        title = glue::glue("{.x$name}: Zoning Code")
      ) +
      ggplot2::guides(
        fill = ggplot2::guide_legend(
          title = "Zoning category",
          override.aes = ggplot2::aes(label = "")
        )
      )
  )

  if (length(area_zoning_map) == 1) {
    return(area_zoning_map[[1]])
  } else {
    return(area_zoning_map)
  }

}
