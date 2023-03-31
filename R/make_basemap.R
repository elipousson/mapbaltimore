#' @title Make basemap for Baltimore
#' @description Load basemap layers *must* be run before make_basemap in order for the data to be accessible. TODO: check whether data is loaded and then run load data with preset parameters if data is not already accessible in the environment.
#' @param location sf or bbox object
#' @param label area label
#' @param dist distance to buffer area using units of CRS Default: 0
#' @inheritParams get_data_batch
#' @param show_location PARAM_DESCRIPTION, Default: `FALSE`
#' @param save PARAM_DESCRIPTION, Default: `FALSE`
#' @param crs Coordinate reference system, Default: 2804
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   area <-
#'     get_area(
#'       "neighborhood",
#'       "Central Park Heights"
#'     )
#'   label <- "Park Heights"
#'   load_basemap_layers(
#'     area = area,
#'     label = label,
#'     layers = c("streets", "parks", "mta_bus_stops")
#'   )
#'
#'   park_heights_basemap <-
#'     make_basemap(
#'       area = area,
#'       label = label,
#'       asp = 1
#'     )
#'
#'   park_heights_basemap
#' }
#' }
#' @seealso
#'  [janitor::make_clean_names()]
#' @rdname make_basemap
#' @noRd
#' @importFrom janitor make_clean_names
make_basemap <-
  function(location,
           label,
           dist = 0,
           diag_ratio = NULL,
           asp = NULL,
           show_area = FALSE,
           save = FALSE,
           crs = 2804) {
    # TODO: Remove this line if it is included in get_local_layer
    # label <- janitor::make_clean_names(label)
    check_installed(c("ggplot2", "maplayer"))

    basemap_bbox <-
      st_bbox_ext(
        x = location,
        asp = asp,
        dist = dist,
        diag_ratio = diag_ratio,
        crs = crs
      )

    water_layer <-
      maplayer::layer_location_data(
        layer = "baltimore_water",
        label = label,
        fill = "navyblue",
        alpha = 0.2,
        color = NA
      )

    unimproved_layer <-
      maplayer::layer_location_data(
        layer = "unimproved_property",
        label = label,
        fill = "brown",
        alpha = 0.4,
        color = NA
      )

    street_layer <-
      maplayer::layer_location_data(
        layer = "streets",
        label = label,
        color = "gray90",
        size = 0.5,
        fill = NA
      )


    pavement_layer <-
      maplayer::layer_location_data(
        layer = "edge_of_pavement",
        label = label,
        color = "gray40",
        fill = "gray90"
      )


    park_layer <-
      maplayer::layer_location_data(
        layer = "parks",
        label = label,
        fill = "green",
        color = NA
      )

    bus_stop_layer <-
      maplayer::layer_location_data(
        layer = "mta_bus_stops",
        label = label,
        geom = "icon",
        color = "black",
        icon = "bus",
        source = "mapbox/maki"
      )

    # TODO: Figure out a way for the user to determine the content and order of layers
    basemap <-
      ggplot2::ggplot() +
      water_layer +
      unimproved_layer +
      pavement_layer +
      # street_layer +
      park_layer +
      bus_stop_layer


    if (show_area) {
      # TODO: Add layer_show_area() function
    }

    if (save) {
      # TODO: Add save to PDF/PVG function with ggsave or ggsave_exif()
    }


    return(basemap)
  }
