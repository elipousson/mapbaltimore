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

get_mapbaltimore_palette <- function(palette) {
  switch(palette,
    "mta_bus" = mta_bus_colors
  )
}

#' @title Scales for Baltimore data
#' @param palette "mta_bus" is only currently supported option, Default: NULL
#' @seealso
#'  \code{\link[ggplot2]{scale_manual}}
#' @rdname scale_mapbaltimore
#' @export
#' @importFrom ggplot2 scale_color_manual
scale_color_mapbaltimore <- function(palette = NULL) {
  palette <-
    get_mapbaltimore_palette(palette)

  ggplot2::scale_color_manual(
    values = palette,
    na.value = "grey50"
  )
}

#' @rdname scale_mapbaltimore
#' @export
#' @importFrom ggplot2 scale_color_manual
scale_fill_mapbaltimore <- function(palette = NULL) {
  palette <-
    get_mapbaltimore_palette(palette)

  ggplot2::scale_fill_manual(
    values = palette,
    na.value = "grey50"
  )
}
