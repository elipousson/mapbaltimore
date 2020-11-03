#' Plot selected housing permits from Open Baltimore data portal
#' @description This function plots a basic chart of building permits issued by month, quarter, or year. Expected to use in combination with the \code{get_permits} function.
#' @param permits A data frame of building permit data.
#' @param area_label Required character vector used as label for map to describe the geographic area covered by the permit data.
#' @param plot_by Required character vector to select the period of time to aggregate permit count. Supports "month", "quarter", and "year"
#'
#' @export

plot_permits <- function(permits,
                         area_label,
                         plot_by = c("month", "quarter", "year")) {

  permit_plot <- permits %>%
    dplyr::mutate(
      issue_year = lubridate::year(issue_date),
      issue_month = lubridate::month(issue_date),
      issue_quarter = lubridate::quarter(issue_date, with_year = TRUE)
    )

  if (plot_by == "month") {
    permit_plot <- permit_plot %>%
      dplyr::group_by(issue_year, issue_month) %>%
      dplyr::summarise(
        permit_count = dplyr::n(),
        dem_count = sum(permit_type == "DEM"),
        use_count = sum(permit_type == "USE"),
        com_count = sum(permit_type == "COM"),
        mec_count = sum(permit_type == "MEC"),
        plm_count = sum(permit_type == "PLM"),
        ele_count = sum(permit_type == "ELE")
      ) %>%
      ggplot2::ggplot(
        ggplot2::aes(
          x = lubridate::ymd(paste0(issue_year, "-", issue_month, "-01")),
          y = permit_count
        )
      ) +
      ggplot2::labs(
        title = glue::glue("Building permits in {area_label}, {min(permit_plot$issue_year)} to {max(permit_plot$issue_year)}"),
        x = "Month",
        y = "Permits issued"
      )
  } else if (plot_by == "quarter") {
    permit_plot <- permit_plot %>%
      dplyr::group_by(issue_quarter) %>%
      dplyr::summarise(
        permit_count = dplyr::n(),
        dem_count = sum(permit_type == "DEM"),
        use_count = sum(permit_type == "USE"),
        com_count = sum(permit_type == "COM"),
        mec_count = sum(permit_type == "MEC"),
        plm_count = sum(permit_type == "PLM"),
        ele_count = sum(permit_type == "ELE")
      ) %>%
      ggplot2::ggplot(
        ggplot2::aes(
          x = lubridate::yq(issue_quarter),
          y = permit_count
        )
      ) +
      ggplot2::labs(
        title = glue::glue("Building permits in {area_label}, {min(permit_plot$issue_quarter)} to {max(permit_plot$issue_quarter)}"),
        x = "Quarter",
        y = "Permits issued"
      )
  } else if (plot_by == "year") {
    permit_plot <- permit_plot %>%
      ggplot2::ggplot(
        ggplot2::aes(issue_year)
      )
  }

  permit_plot <- permit_plot +
    ggplot2::geom_point(group = 1) +
    ggplot2::geom_line(group = 1)

  return(permit_plot)
}
