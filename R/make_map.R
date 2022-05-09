
#' Make maps with Baltimore data
#'
#' Make maps using different styles.
#'
#' @inheritParams make_location_map
#' @name make_map
#' @noRd
NULL

#' @name map_tree_map
#' @rdname make_map
map_tree_map <- function(location,
                         data = "trees",
                         filetype = "gpkg",
                         package = "mapbaltimore",
                         paper = "Letter",
                         dist = NULL,
                         diag_ratio = NULL,
                         unit = NULL,
                         asp = NULL,
                         mapping = ggplot2::aes(color = condition, size = dbh),
                         geom = "sf",
                         shape = 20,
                         alpha = 0.6,
                         basemap = TRUE,
                         bg_layer = NULL,
                         fg_layer = list(
                           ggplot2::scale_color_brewer(palette = "RdYlGn", direction = -1),
                           ggplot2::guides(size = "none")
                         ),
                         ...) {
  overedge::make_location_map(
    data = data,
    location = location,
    package = package,
    filetype = filetype,
    fn = ~ dplyr::mutate(
      .x,
      condition = forcats::fct_relevel(condition, c("Good", "Fair", "Poor", "Dead"))
    ),
    dist = dist,
    diag_ratio = diag_ratio,
    asp = asp,
    geom = geom,
    shape = shape,
    alpha = alpha,
    unit = unit,
    mapping = mapping,
    basemap = basemap,
    bg_layer = bg_layer,
    fg_layer = fg_layer,
    ...
  )
}


#' @name make_hmt_map
#' @rdname make_map
make_hmt_map <- function(location = NULL,
                         data = mapbaltimore::hmt_2017,
                         mapping = ggplot2::aes(fill = cluster),
                         paper = "Letter",
                         dist = NULL,
                         diag_ratio = NULL,
                         asp = NULL,
                         color = "white",
                         size = 0.4,
                         fg_layer = list(
                           ggplot2::scale_fill_viridis_d(option = "C"),
                           ggplot2::labs(fill = "HMT Cluster")
                         ),
                         basemap = TRUE,
                         ...) {
  make_location_map(
    location = location,
    data = data,
    diag_ratio = diag_ratio,
    asp = asp,
    mapping = mapping,
    color = color,
    size = size,
    geom = "sf",
    fg_layer = fg_layer,
    basemap = basemap,
    ...
  )
}

#' @name make_bcpss_map
#' @rdname make_map
make_bcpss_map <- function(location = NULL,
                           data = bcpss::bcps_es_zones_SY2021,
                           mapping = ggplot2::aes(fill = program_name_short),
                           paper = "Letter",
                           dist = NULL,
                           diag_ratio = NULL,
                           asp = NULL,
                           color = "white",
                           size = 0.9,
                           alpha = 0.75,
                           fg_layer =
                             list(
                               layer_location_data(
                                 location = NULL,
                                 data = bcpss::bcps_programs_SY2021,
                                 fill = "white",
                                 size = 3.75
                               ),
                               layer_location_data(
                                 data = bcpss::bcps_programs_SY2021,
                                 mapping = ggplot2::aes(fill = program_name_short),
                                 color = "white",
                                 shape = 21,
                                 size = 4
                               ),
                               layer_location_data(
                                 data = bcpss::bcps_programs_SY2021,
                                 mapping = ggplot2::aes(
                                   label = program_name_short,
                                   fill = program_name_short
                                 ),
                                 geom = "sf_label",
                                 color = "white",
                                 label.size = 0.75,
                                 label.padding = unit(0.5, "lines"),
                                 label.r = unit(0.25, "lines"),
                                 hjust = 0.5,
                                 vjust = 0.5,
                                 size = 6
                               ),
                               ggplot2::guides(
                                 fill = "none",
                                 color = "none"
                               )
                             ),
                           basemap = TRUE,
                           ...) {
  make_location_map(
    location = location,
    data = data,
    diag_ratio = diag_ratio,
    asp = asp,
    mapping = mapping,
    color = color,
    size = size,
    geom = "sf",
    fg_layer = fg_layer,
    basemap = basemap,
    ...
  )
}
