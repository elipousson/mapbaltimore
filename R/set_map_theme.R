#' Set default map theme
#'
#' Set a map theme using [ggplot2::theme_set()] and default for `geom_label`
#' using [ggplot2::update_geom_defaults()].
#' Optionally hides axis text and labels.
#'
#' @param map_theme ggplot2 theme. Optional. Defaults to [ggplot2::theme_minimal()]
#' @param show_axis Logical. If TRUE, keep theme axis formatting. If FALSE, hide the panel grid, axis title, and axis text.
#' @export
set_map_theme <- function(map_theme = NULL,
                          show_axis = FALSE) {
  check_installed("ggplot2")
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
