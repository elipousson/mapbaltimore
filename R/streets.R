#' Get selected area streets
#'
#' Get streets within an area or areas.
#'
#' @param area sf object with area of streets to return.
#' @param street_type selected street subtypes to include. By default, the returned data includes all subtypes except alleys ("STRALY").
#' Options include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR", "STRURD", "STCLN", "STRTN")
#' @param sha_class selected SHA classifications to include.
#' "all" selects all streets with an assigned SHA classification (around one-quarter of all street segments).
#' Additional options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @inheritParams get_area_data
#' @param trim Logical. Default `FALSE`. Trim streets to area using `sf::st_intersection()`.
#' @param msa Logical. Default `FALSE`. Get streets from cached `baltimore_msa_streets.gpkg` file using `cachedata` parameter of `get_area_data` function.
#' @param union Logical. Default `TRUE`. Union geometry based on `fullname` of streets.
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
get_area_streets <- function(area = NULL,
                             street_type = NULL,
                             sha_class = NULL,
                             bbox = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             asp = NULL,
                             trim = FALSE,
                             msa = FALSE,
                             union = TRUE) {
  if (!msa) {
    # Get streets in area
    area_streets <- get_area_data(
      data = streets,
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim
    )

    # Filter by selected street_type
    if (!is.null(street_type)) {
      area_streets <- area_streets %>%
        dplyr::filter(subtype %in% street_type)
    } else {
      area_streets <- area_streets %>%
        dplyr::filter(subtype != "STRALY")
    }
  } else {
    # Get streets in area that includes MSA
    area_streets <- get_area_data(
      area = area,
      cachedata = "baltimore_msa_streets",
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim
    )
  }

  # Limit to streets with selected SHA classifications
  if (!is.null(sha_class)) {
    sha_class <- stringr::str_to_upper(sha_class)

    if ("ALL" %in% sha_class) {
      area_streets <- area_streets %>%
        dplyr::filter(!is.na(sha_class))
    } else {
      selected_sha_class <- sha_class
      area_streets <- area_streets %>%
        dplyr::filter(sha_class %in% selected_sha_class)
    }
  }

  if (union) {
    area_streets <- area_streets %>%
      dplyr::mutate(fullname = stringr::str_trim(fullname)) %>%
      dplyr::group_by(fullname) %>%
      dplyr::summarise(geometry = sf::st_union(geometry))
  }

  return(area_streets)
}

#' Add a layer to a gpplot2 map with area streets, names, or both
#'
#'
#'
#' @param area sf object. Return
#' @inheritParams get_area_streets
#' @param hide Options include c("names", "streets", "none"). Defaults to "names"
#' @param name_location Options include c("area", "edge", "topright", or "bottomleft"). Defaults to NULL.
#'
#' @examples
#' highlandtown <- get_area(type = "neighborhood", area_name = "Highlandtown")
#' ggplot2::ggplot() + layer_area_streets(area = highlandtown)
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
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

  area_streets <- get_area_streets(area = area,
                   street_type = street_type,
                   sha_class = sha_class,
                   dist = dist,
                   diag_ratio = diag_ratio,
                   asp = asp,
                   trim = trim,
                   msa = msa)

  hide <- match.arg(hide)

  street_geom <- NULL
  street_name_geom <- NULL

  if (hide != "streets") {
    street_geom <- ggplot2::geom_sf(data = area_streets, color = "gray80")
  }

  if (hide != "names") {
    name_location <- match.arg(name_location, c("area","edge","topleft","topright","bottomleft","bottomright"))

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
      aes(label = fullname),
      ...)
  }

  return(list(street_geom, street_name_geom))
}

