#' Add a layer to a gpplot2 map with area streets, street names, or both
#'
#' Add a layer to a gpplot2 map with area streets, street names, or both.
#'
#' @param area sf object. Return
#' @inheritParams get_area_streets
#' @param hide Options include c("names", "streets", "none"). Defaults to "names"
#' @param name_location Options include c("area", "edge", "topright", or "bottomleft"). Defaults to NULL.
#' @param ... Other parameters to pass along to `ggplot2::geom_sf()` that maps the streets.
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
                               hide = c("names", "streets", "none"),
                               name_location = NULL,
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

  hide <- match.arg(hide)

  street_geom <- NULL
  street_name_geom <- NULL

  if (hide != "streets") {
    street_geom <- ggplot2::geom_sf(data = area_streets, color = "gray40", ...)
  }

  if (hide != "names") {
    name_location <- match.arg(name_location, c("area", "edge", "topleft", "topright", "bottomleft", "bottomright"))

    if (!(name_location %in% c("area", "edge"))) {
      area_streets <- sf::st_intersection(
        area_streets,
        clip_area(area = area, clip = name_location, flip = TRUE)
      )
    } else if (name_location == "edge") {
      area_streets <- sf::st_intersection(
        area_streets,
        clip_area(area = area, clip = name_location)
      )
    }

    street_name_geom <- ggplot2::geom_sf_label(
      data = area_streets,
      ggplot2::aes(label = fullname)
    )
  }

  return(list(street_geom, street_name_geom))
}
