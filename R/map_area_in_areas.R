
#' Map area within selected overlapping areas
#'
#' Map an area or areas within selected overlapping areas.
#'
#' @param area sf object. Required
#' @param type Type of area to map. Supports the same types as the get_area function.
#' @param show_label Logical. Default FALSE. If TRUE, label areas with ggplot2::geom_sf_label()
#' @param show_area Logical. Default TRUE.
#' @param background ggplot layer. Default NULL. Passing a ggplot2 layer may be necessary to have an appropriate background for the congressional district maps.
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#'
map_area_in_areas <- function(area,
                              type = c(
                                "neighborhood",
                                "council district",
                                "legislative district",
                                "congressional district",
                                "planning district",
                                "police district",
                                "csa"
                              ),
                              show_area = TRUE,
                              show_label = FALSE,
                              background = NULL) {
  hide <- match.arg(hide)

  areas_in <- purrr::map_dfr(
    type,
    ~ get_area_data(
      data = eval(as.name(paste0(gsub(" ", "_", .x), "s"))),
      area = area,
      crop = FALSE,
      trim = FALSE,
      crs = 2804,
      dist = -2
    ) %>%
      dplyr::bind_cols(areas_in_type = stringr::str_to_title(.x))
  )

  areas_in_map <- ggplot2::ggplot()

  if (is.null(background)) {
    areas_in_map <- areas_in_map +
      ggplot2::geom_sf(data = parks, fill = "darkgreen", color = NA, alpha = 0.4) +
      ggplot2::geom_sf(
        data = suppressWarnings(get_area_streets(area = areas_in, sha_class = c("PART", "FWY", "INT"))),
        fill = NA,
        color = "gray60"
      )
  } else if (is.list(background)) {
    areas_in_map <- areas_in_map +
      background
  }

  areas_in_map <- areas_in_map +
    ggplot2::geom_sf(
      data = areas_in,
      ggplot2::aes(fill = name),
      color = NA,
      alpha = 0.6
    ) +
    ggplot2::guides(fill = "none")

  # Optionally add area to map
  if (show_area) {
    areas_in_map <- areas_in_map +
      ggplot2::geom_sf(
        data = area,
        fill = "white",
        alpha = 0.4,
        color = "gray30"
      )
  }

  # Facet map if multiple areas provided
  if (length(type) > 1) {
    areas_in_map <- areas_in_map + ggplot2::facet_wrap(~areas_in_type)
  } else {
    areas_in_map <- areas_in_map + ggplot2::labs(title = areas_in$areas_in_type)
  }

  if (show_label) {
    areas_in_map <- areas_in_map +
      ggplot2::geom_sf_label(
        data = areas_in,
        ggplot2::aes(
          label = name,
          fill = name
        ),
        color = "white"
      )
  }

  return(areas_in_map + set_map_limits(areas_in))
}
