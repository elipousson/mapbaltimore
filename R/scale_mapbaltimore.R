# Based on MTA graphics
mta_bus_colors <-
  c(
    "RD" = "#D71921",
    "BL" = "#0072BC",
    "GD" = "#8A7A38",
    "YW" = "#F6E700",
    "NV" = "#48626F",
    "PR" = "#851F83",
    "PK" = "#D70080",
    "GR" = "#008344",
    "OR" = "#E9741F",
    "LM" = "#6CA144",
    "BR" = "#6F4C2F",
    "SV" = "#9A9C9E",
    "22" = "#1A1110",
    "26" = "#1A1110",
    "30" = "#1A1110",
    "54" = "#1A1110",
    "80" = "#1A1110",
    "85" = "#1A1110"
  )

# Based on tol.iridescent (color-blind friendly)
hmt_cluster_group_colors <-
  c(
    "A" = "#F8F4CA",
    "B & C" = "#D4E8C5",
    "D & E" = "#A9D8DB",
    "F, G, & H" = "#81C4E7",
    "I & J" = "#88A3DC",
    "RM 1 & RM 2" = "#9B78AA",
    "Other Residential" = "#745064",
    "Non-Residential" = "#999999"
  )

# Based on tol.iridescent (not color-blind friendly)
hmt_cluster_colors <-
  c(
    "A" = "#FEFBE9",
    "B" = "#F7F4C7",
    "C" = "#E4EEB8",
    "D" = "#CEE6CA",
    "E" = "#B8DED6",
    "F" = "#A2D5DE",
    "G" = "#8BC9E4",
    "H" = "#7BBDE7",
    "I" = "#83ABE0",
    "J" = "#9494CE",
    "Rental Market 1" = "#9C7DB3",
    "Rental Market 2" = "#936790",
    "Subsidized Rental Market" = "#785268",
    "Mixed Market/Subsidized Rental Market" = "#46353A",
    "Non-Residential" = "#999999"
  )

mapbaltimore_palettes <-
  list(
    "bus" = mta_bus_colors,
    "mta_bus" = mta_bus_colors,
    "cluster" = hmt_cluster_colors,
    "hmt_2017" = hmt_cluster_colors,
    "hmt_cluster" = hmt_cluster_colors,
    "cluster_group" = hmt_cluster_group_colors,
    "hmt_cluster_group" = hmt_cluster_group_colors
  )


#' Scales for Baltimore data
#'
#' Custom palettes for two package datasets: `mta_bus_lines` and `hmt_2017`
#' (both for cluster and cluster group).
#'
#' @param palette Options include "mta_bus", "hmt_2017", "hmt_cluster",
#'   "cluster", "hmt_cluster_group", or "cluster_group", Default: `NULL`
#' @param na.value Defaults to "grey50"
#' @inheritParams  ggplot2::scale_discrete_manual
#' @inheritParams rlang::args_error_context
#' @examples
#' \dontrun{
#' if (interactive()) {
#'   library(ggplot2)
#'
#'   ggplot(data = dplyr::filter(mta_bus_lines, frequent)) +
#'     geom_sf(aes(color = route_abb), alpha = 0.5, size = 2) +
#'     scale_mapbaltimore(palette = "bus") +
#'     theme_minimal()
#'
#'   ggplot(data = hmt_2017) +
#'     geom_sf(aes(fill = cluster_group, color = cluster_group)) +
#'     scale_mapbaltimore(palette = "cluster_group") +
#'     theme_minimal()
#' }
#' }
#'
#' @export
#' @importFrom ggplot2 scale_discrete_manual
#' @importFrom rlang caller_env arg_match
scale_mapbaltimore <- function(palette = NULL,
                               values = NULL,
                               na.value = "grey50",
                               aesthetics = c("color", "fill"),
                               error_call = caller_env(),
                               ...) {
  if (is.null(values)) {
    palette <-
      rlang::arg_match(
        palette,
        names(mapbaltimore_palettes),
        error_call = error_call
      )

    values <- mapbaltimore_palettes[[palette]]
  }

  ggplot2::scale_discrete_manual(
    aesthetics = aesthetics,
    values = values,
    na.value = na.value,
    ...
  )
}

#' @name scale_color_mapbaltimore
#' @rdname scale_mapbaltimore
scale_color_mapbaltimore <- function(palette = NULL, na.value = "grey50", ...) {
  scale_mapbaltimore(
    palette = palette,
    na.value = na.value,
    aesthetics = "color",
    ...
  )
}

#' @name scale_fill_mapbaltimore
#' @rdname scale_mapbaltimore
#' @export
scale_fill_mapbaltimore <- function(palette = NULL, na.value = "grey50", ...) {
  scale_mapbaltimore(
    palette = palette,
    na.value = na.value,
    aesthetics = "fill",
    ...
  )
}
