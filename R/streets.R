#' Get area streets
#'
#' Get streets within an area or areas.
#'
#' @param area sf object with area of streets to return.
#' @param street_type selected street subtypes to include. Includes all subtypes except alleys ("STRALY") by default.
#' Options include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR", "STRURD", "STCLN", "STRTN")
#' @param sha_class selected SHA classifications to include.
#' "all" selects all streets with an assigned SHA classification (around one-quarter of all street segments).
#' Additional options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @inheritParams get_buffered_area
#' @param trim Logical. Default FALSE. Trim streets to area using sf::st_intersection().
#' @param msa Logical. Default FALSE. Get streets from cached baltimore_msa_streets.gpkg file.
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
get_area_streets <- function(area,
                             street_type = NULL,
                             sha_class = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             trim = FALSE,
                             msa = FALSE) {

  if (!msa) {
    # Get streets in area
    area_streets <- get_area_data(data = streets,
                                  area = area,
                                  diag_ratio = diag_ratio,
                                  dist = dist,
                                  trim = trim)

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
    area_streets <- get_area_data(area = area,
                                  extdata = "baltimore_msa_streets",
                                  diag_ratio = diag_ratio,
                                  dist = dist,
                                  trim = trim)
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

  return(area_streets)
}


#' Label area street names at selected locations
#'
#' Label street names at selected locations.
#'
#' @param area sf object. Labels returned for streets in or around area bounding box.
#' @param geom Character vector matching name of geom returned with labels. "label" for "ggplot::geom_label" or "label_repel" for "ggrepel::geom_label_repel" are supported.
#' @param sha_class Character vector. "all" selects all streets with an assigned SHA classification. Options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @param label_location Options include "area", "edge", "topright", or "bottomleft". Defaults to "area"
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
label_area_streets <- function(area,
                               geom = c("label", "label_repel"),
                               sha_class = NULL,
                               label_location = c("area", "edge", "topright", "bottomleft")) {

  geom <- match.arg(geom)
  label_location <- match.arg(label_location)

  # Get area bbox
  area_bbox <- sf::st_bbox(area)

  # Calculate the diagonal distance of the area
  area_bbox_diagonal <- sf::st_distance(
    sf::st_point(c(area_bbox$xmin, area_bbox$ymin)),
    sf::st_point(c(area_bbox$xmax, area_bbox$ymax))
  )

  # Intersect streets and area (buffered one meter to capture streets used as boundary lines)
  buffer_dist <- 1
  area_streets <- get_area_streets(get_buffered_area(area, dist = buffer_dist), sha_class = sha_class)

  edge_dist <- 6
  area_edge <- get_buffered_area(area, dist = edge_dist)
  area_edge_streets <- get_area_streets(area_edge, sha_class = sha_class)
  area_edge_bbox <- sf::st_bbox(area_edge)

  edge_exclude_dist <- 3
  area_edge_exclude <- get_buffered_area(area, dist = edge_exclude_dist)

  if (label_location == "area") {
    area_streets_label <- area_streets
  } else if (label_location == "edge") {
    area_edges <- sf::st_difference(area_edge, area_edge_exclude)

    area_streets_label <- area_edge_streets %>%
      sf::st_intersection(area_edges)
  } else if (label_location == "topright") {
    bottomleft_bbox <- sf::st_sf(
      name = "bottomleft",
      geometry = sf::st_sfc(sf::st_convex_hull(
        x = c(
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymin)),
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymin))
        )
      ))
    ) %>%
      sf::st_set_crs(2804)

    bottomleft_exclude_area <- sf::st_union(area_edge_exclude, bottomleft_bbox)

    area_streets_label <- area_edge_streets %>%
      sf::st_difference(bottomleft_exclude_area)
  } else if (label_location == "bottomleft") {
    topright_bbox <- sf::st_sf(
      name = "topright",
      geometry = sf::st_sfc(sf::st_convex_hull(
        x = c(
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmin, area_edge_bbox$ymax)),
          sf::st_point(c(area_edge_bbox$xmax, area_edge_bbox$ymin))
        )
      ))
    ) %>%
      sf::st_set_crs(2804)

    topright_exclude_area <- sf::st_union(area_edge_exclude, topright_bbox)

    area_streets_label <- area_edge_streets %>%
      sf::st_difference(topright_exclude_area)
  }

  # Combine geometry of streets with the same name
  area_streets_label <- area_streets_label %>%
    dplyr::group_by(fullname) %>%
    dplyr::summarise(
      geometry = sf::st_union(geometry)
    )


  if (geom == "label") {
    street_labels <- ggplot2::geom_sf_label(
      data = area_streets_label,
      ggplot2::aes(label = fullname),
      size = grid::unit(3, "lines"),
      label.r = grid::unit(0, "lines")
    )
  } else if (geom == "label_repel") {
    street_labels <- ggrepel::geom_label_repel(
      data = area_streets_label,
      ggplot2::aes(
        label = fullname,
        geometry = geometry
      ),
      stat = "sf_coordinates",
      size = grid::unit(3, "lines"),
      label.r = grid::unit(0, "lines"),
      point.padding = NA
    )
  }

  return(street_labels)
}
