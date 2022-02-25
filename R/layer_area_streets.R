#' Add a layer to a gpplot2 map with area streets, street names, or both
#'
#' Add a layer to a gpplot2 map with area streets, street names, or both.
#'
#' @param area sf object. Returns streets within this area (after adjustment by
#'   dist, diag_ratio, and asp parameters)
#' @inheritParams get_area_streets
#' @param show_streets Logical. Default TRUE. If FALSE, hides street center
#'   lines.
#' @param show_names Logical. Default FALSE. If TRUE, shows street names.
#' @param name_location Options include c("area", "edge", "top", "left",
#'   "bottom", "right", "topleft", "topright", "bottomleft", "bottomright").
#'   Defaults to NULL.
#' @param edge_dist Distance buffer to use for placing street names.
#' @param color Color of streets and/or text of street name labels.
#' @param size Size of the streets and/or street name labels.
#' @param ... Other parameters to pass along to `ggplot2::geom_sf()` that maps
#'   the streets.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#' @importFrom sf st_intersection
#'
layer_area_streets <- function(area = NULL,
                               street_type = NULL,
                               sha_class = NULL,
                               dist = NULL,
                               diag_ratio = NULL,
                               asp = NULL,
                               trim = FALSE,
                               msa = FALSE,
                               show_streets = TRUE,
                               show_names = FALSE,
                               name_location = NULL,
                               edge_dist = 10,
                               color = "gray40",
                               size = 1,
                               ...) {
  area_streets <- get_area_streets(
    area = area,
    street_type = street_type,
    sha_class = sha_class,
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    trim = trim,
    msa = msa
  )

  street_layer <- NULL
  street_name_layer <- NULL

  if (show_streets) {
    street_layer <- ggplot2::geom_sf(data = area_streets, color = color, size = size, ...)
  }

  if (show_names) {
    name_location <- match.arg(name_location, c("area", "edge", "top", "left", "bottom", "right", "topleft", "topright", "bottomleft", "bottomright"))

    if (!(name_location %in% c("area", "edge"))) {
      area_streets <- sf::st_intersection(
        area_streets,
        clip_area(area = area, clip = name_location, edge = FALSE, flip = TRUE)
      )
    } else if (name_location == "edge") {
      area_streets <- sf::st_intersection(
        area_streets,
        clip_area(area = area, clip = NULL, edge_dist = edge_dist)
      )
    }

    street_name_layer <- ggplot2::geom_sf_label(
      data = area_streets,
      ggplot2::aes(label = fullname),
      color = color,
      size = size
    )
  }

  # Combine layers and discard NULL layers
  layer_list <- list(street_layer, street_name_layer) %>%
    purrr::discard(is.null)

  return(layer_list)
}
