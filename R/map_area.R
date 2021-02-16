#' Map area in the context of city boundaries
#'
#' Map showing the location of an area within the city.
#'
#' @param area sf object with a 'name' column. Required.
#' @param area_label area label to replace area name. Optional.
#' @importFrom ggplot2 ggplot aes geom_sf
#' @examples
#'
#' \dontrun{
#' ## Area with a defined label
#' district2 <- get_area(
#'   type = "council district",
#'   area_id = "2"
#' )
#'
#' map_area_in_city(
#'   area = district2,
#'   area_label = "Baltimore's Second Council District"
#' )
#' }
#'
#' \dontrun{
#' ## Multiple areas in a single map
#' selected_se_neighborhoods <- get_area(
#'   type = "neighborhood",
#'   area_name = c("Upper Fells Point", "Fells Point", "Canton")
#' )
#'
#' map_area_in_city(area = selected_se_neighborhoods,
#'                  area_label = "Southeast Baltimore neighborhoods")
#' }
#'
#' \dontrun{
#' ## Area with a defined map title
#' canton_industrial <- get_area(
#'   type = "neighborhood",
#'   area_name = "Canton Industrial Area"
#' )
#'
#' map_area_in_city(area = canton_industrial)
#' }
#'
#' @export
#'
map_area_in_city <- function(area,
                             area_label = NULL) {
  check_area(area)

  city_streets <- streets %>%
    dplyr::filter(sha_class %in% c("FWY", "INT")) %>%
    sf::st_union()

  city_water <- baltimore_water %>%
    sf::st_union() %>%
    sf::st_crop(baltimore_city)

  # Create city_map background with detailed physical boundary and parks
  city_map <- ggplot2::ggplot() +
    ggplot2::geom_sf(
      data = baltimore_city_detailed,
      fill = "ivory2",
      color = NA
    ) +
    ggplot2::geom_sf(
      data = sf::st_union(parks),
      fill = "darkseagreen3",
      color = NA
    ) +
    ggplot2::geom_sf(
      data = city_water,
      fill = "skyblue4",
      color = "skyblue4",
      alpha = 0.8
    ) +
    ggplot2::geom_sf(
      data = city_streets,
      color = "slategray",
      fill = NA,
      alpha = 0.8,
      size = 0.6
    ) +
    ggplot2::geom_sf(
      data = baltimore_city,
      color = "white",
      fill = NA,
      size = 1.2
    ) +
    ggplot2::geom_sf(
      data = baltimore_city,
      color = "gray25",
      fill = NA,
      size = 0.4
    )

  if (length(area$name) > 1) {
    # Add a discrete color scale if more than one area is provided
    area_map <- city_map +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = "gray30",
        alpha = 0.8,
        size = 0.4
      ) +
      ggplot2::scale_fill_viridis_d()
  } else {
    # Set area fill to  "gray20" if one area is provided
    area_map <- city_map +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = "gray50",
        alpha = 0.8,
        size = 0.4
      )
  }

  # Replace area name with label if provided
  if (is.character(area_label)) {
    area$name <- area_label
  }

  label_location <- get_buffered_area(area, dist = 1) %>%
    sf::st_difference(area) %>%
    sf::st_point_on_surface()

  area_map <- area_map +
    # Label area or areas
    ggrepel::geom_label_repel(
      data = label_location,
      ggplot2::aes(
        label = name,
        geometry = geometry
      ),
      stat = "sf_coordinates",
      size = 6,
      fill = "gray25",
      color = "white",
      box.padding = grid::unit(2, "lines"),
      min.segment.length = 0,
      segment.colour = "gray50",
      force = 30,
      label.padding = grid::unit(0.75, "lines"),
      label.r = grid::unit(0.05, "lines")
    ) +
    ggplot2::guides(fill = "none")

  return(area_map)
}

#' Maps a highlighted area within the context of multiple areas
#'
#' Map highlighting the location of an area the context of multiple areas.
#'
#' @param area Required sf object with a 'name' column.
#' @param highlight_name Character vector. Required. Use "all" to create a grid of maps highlighting each area in the provided sf object or provide the name of one or more areas to highlight.
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#'
map_area_highlighted <- function(area,
                                 highlight_name = "all") {
  if (length(area$geometry) == 1) {
    warning("map_area_highlighted is designed to work with multiple areas")
  }

  area_map_highlighted <- ggplot2::ggplot()

  if (highlight_name == "all") {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = area,
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::facet_wrap(~name) +
      ggplot2::guides(fill = "none")
  } else if (is.character(highlight_name) && (length(highlight_name) == 1)) {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = dplyr::filter(area, name == highlight_name),
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::guides(fill = "none") +
      ggplot2::labs(title = highlight_name)
  } else if (is.character(highlight_name) && (length(highlight_name) > 1)) {
    area_map_highlighted <- area_map_highlighted +
      ggplot2::geom_sf(
        data = dplyr::filter(area, name %in% highlight_name),
        ggplot2::aes(fill = name),
        color = NA
      ) +
      ggplot2::facet_wrap(~name,
                          ggplot2::label_value(width = 10, multi_line = TRUE)) +
      ggplot2::theme(strip.text.x = ggplot2::element_text(size = 12)) +
      ggplot2::guides(fill = "none")
  }

  area_map_highlighted <- area_map_highlighted +
    ggplot2::geom_sf(
      data = sf::st_union(area),
      color = "gray30",
      fill = NA
    )

  return(area_map_highlighted)
}

#' Map area using the snapbox package
#'
#' Map an area or areas using the \code{\link{snapbox}} package.
#'
#' @param area Required sf object with a 'name' column.
#' @param map_style Required. \code{\link{stylebox}} function referencing mapbox map styles. Default is \code{\link[stylebox]{mapbox_satellite_streets()}}
#' @inheritParams get_buffered_area
#' @param mask Logical. Default TRUE. If TRUE, apply a transparent (alpha = 0.4) white mask over the Mapbox map outside the area. Uses the layer_area_mask function.
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#' @export
#'
map_area_with_snapbox <- function(area,
                                  map_style = snapbox::mapbox_satellite_streets(),
                                  dist = NULL,
                                  diag_ratio = 0.125,
                                  mask = TRUE) {

  # Set appropriate CRS for Mapbox
  mapbox_crs <- 3857

  # Make cutout for mask
  area_cutout <- area

  # Get buffered area
  if (!is.null(dist) | !is.null(diag_ratio)) {
    area <- get_buffered_area(area, dist = dist, diag_ratio = diag_ratio)
  }

  # Get bbox for area
  bbox <- area %>%
    sf::st_transform(crs = mapbox_crs) %>%
    sf::st_bbox()

  # Get Mapbox map
  area_snapbox_map <- ggplot2::ggplot() +
    snapbox::layer_mapbox(
      area = bbox,
      map_style = map_style
    )

  if (mask) {
    # Get mask layer with area cutout
    area_snapbox_map <- area_snapbox_map +
      layer_area_mask(area = area_cutout,
                      bbox = bbox,
                      crs = mapbox_crs,
                      fill = "white",
                      color = NA,
                      alpha = 0.4)
  }

  # Mark edges of area
  area_snapbox_map  +
    ggplot2::geom_sf(
      data = area_cutout,
      fill = NA,
      color = "white",
      linetype = "dashed"
    )
}


#' Map area within selected overlapping areas
#'
#' Map an area or areas using the \code{\link{snapbox}} package.
#'
#' @param area sf object. Required
#' @param type Type of area to map. Supports the same types as the get_area function.
#' @param label Logical. Default FALSE. If TRUE, label areas with ggplot2::geom_sf_label()
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
                             label = FALSE,
                             background = NULL) {

  areas_in <- purrr::map_dfr(
    type,
    ~ get_area_data(
      data = eval(as.name(paste0(gsub(" ", "_", .x), "s"))),
      area = area,
      crop = FALSE,
      trim = FALSE,
      crs = 2804,
      dist = -1
    ) %>%
      dplyr::bind_cols(areas_in_type = stringr::str_to_title(.x))
  )

  areas_in_map <- ggplot2::ggplot()

  if (is.null(background)) {
    areas_in_map <- areas_in_map +
      ggplot2::geom_sf(data = parks, fill = "darkgreen", color = NA, alpha = 0.4) +
      ggplot2::geom_sf(data = suppressWarnings(get_area_streets(area = areas_in, sha_class = c("PART", "FWY", "INT"))),
                       fill = NA,
                       color = "gray60")

  } else if (is.list(background)) {
    areas_in_map <- areas_in_map +
      background
  }

  areas_in_map <- areas_in_map +
    ggplot2::geom_sf(data = areas_in,
                     ggplot2::aes(fill = name),
                     color = NA,
                     alpha = 0.6) +
    ggplot2::geom_sf(data = area,
                     fill = "white",
                     alpha = 0.4,
                     color = "gray30") +
    ggplot2::guides(fill = "none") +
    ggplot2::facet_wrap(~ areas_in_type) +
    set_map_limits(areas_in)

  if (label) {
    areas_in_map <- areas_in_map +
      ggplot2::geom_sf_label(data = areas_in,
                             ggplot2::aes(label = name,
                                          fill = name),
                             color = "white")
  }

  return(areas_in_map)
}

