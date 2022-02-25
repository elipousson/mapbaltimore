#' Set default map theme
#'
#' Set a map theme using \code{\link[ggplot2]{theme_set}} and default for \code{geom_label}
#' using \code{\link[ggplot2]{update_geom_defaults}}.
#' Optionally hides axis text and labels.
#'
#' @param map_theme ggplot2 theme. Optional. Defaults to \code{\link[ggplot2]{theme_minimal}}
#' @param show_axis Logical. If TRUE, keep theme axis formatting. If FALSE, hide the panel grid, axis title, and axis text.
#' @export
#' @importFrom ggplot2 theme_set theme_minimal theme_update element_line element_text update_geom_defaults theme_get
set_map_theme <- function(map_theme = NULL,
                          show_axis = FALSE) {
  if (is.null(map_theme)) {
    # Set minimal theme
    ggplot2::theme_set(
      ggplot2::theme_minimal(base_size = 14)
    )
  } else {
    (
      ggplot2::theme_set(
        map_theme
      )
    )
  }

  if (!show_axis) {
    ggplot2::theme_update(
      # Remove lat/lon grid
      panel.grid.major = ggplot2::element_line(color = "transparent"),
      # Remove lat/lon axis text
      axis.title = ggplot2::element_text(color = "transparent"),
      # Remove numeric labels on lat/lon axis ticks
      axis.text = ggplot2::element_text(color = "transparent")
    )
  }

  # Match font family for label and label_repel to theme font family
  ggplot2::update_geom_defaults(
    "label",
    list(
      color = "grey20",
      family = ggplot2::theme_get()$text$family
    )
  )

  # Set fill and color for geom_sf to NA by default
  ggplot2::update_geom_defaults(
    "sf",
    list(
      color = NA,
      fill = NA
    )
  )
}
