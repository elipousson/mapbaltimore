#' Map BCPS programs and attendance zones for a local area
#'
#' Map showing BCPS school zones that overlap with a provided area or areas. If
#' the area sf tibble includes multiple areas, a separate map is created for
#' each area provided.
#'
#' @param area sf object
#' @examples
#' \dontrun{
#' ## Map school attendance boundary zones for the Madison Park neighborhood
#' madisonpark <- get_area(
#'   area_type = "neighborhood",
#'   area_name = "Madison Park"
#' )
#' map_area_bcps_programs(area = madisonpark)
#' }
#'
#' \dontrun{
#' ## Map school attendance boundary zones for City Council District 2
#' district9 <- get_area(
#'   type = "council district",
#'   area_name = "9"
#' )
#' map_area_bcps_programs(area = district9)
#' }
#' @export
#' @importFrom dplyr nest_by
#' @importFrom purrr map map2 pluck
map_area_bcps_programs <- function(area) {
  check_installed(c("ggplot2", "ggrepel"))

  area_nested <- dplyr::nest_by(area,
    name,
    .key = "area",
    .keep = TRUE
  )

  area_nested$bcps_programs <- purrr::map(
    area_nested$area,
    ~ get_area_bcps_programs(.x)
  )

  bcps_program_maps <- purrr::map2(
    area_nested$area,
    area_nested$bcps_programs,
    ~ ggplot2::ggplot() +
      # Map BCPS attendance zones
      ggplot2::geom_sf(
        data = .y$zones,
        ggplot2::aes(fill = program_name),
        color = NA
      ) +
      # Map BCPS school locations matched to zones
      ggplot2::geom_sf(
        data = .y$zoned_programs,
        ggplot2::aes(fill = program_name),
        shape = 21,
        size = 4,
        color = "white",
        stroke = 1.5
      ) +
      # Map BCPS locations in area (not zoned)
      ggplot2::geom_sf(
        data = .y$other_programs,
        shape = 21,
        size = 4,
        fill = "gray60",
        color = "white"
      ) +
      # Map neighborhood boundary
      ggplot2::geom_sf(
        data = .x,
        color = "white",
        fill = NA,
        alpha = 0.6,
        size = 1.8
      ) +
      # Map neighborhood boundary
      ggplot2::geom_sf(
        data = .x,
        color = "gray20",
        fill = NA,
        linetype = 5
      ) +
      # Label zoned schools
      ggrepel::geom_label_repel(
        data = .y$zoned_programs,
        ggplot2::aes(
          label = program_name,
          fill = program_name,
          geometry = geometry
        ),
        stat = "sf_coordinates",
        color = "white",
        size = 4,
        point.padding = 20,
        min.segment.length = 0.25,
        segment.color = "white",
        label.size = 0.5,
        label.padding = 0.5,
        label.r = 0.05
      ) +
      ggrepel::geom_label_repel(
        data = .y$other_programs,
        ggplot2::aes(
          label = program_name,
          geometry = geometry
        ),
        stat = "sf_coordinates",
        fill = "white",
        color = "gray30",
        size = 4,
        point.padding = 20,
        min.segment.length = 0.25,
        segment.color = "white",
        label.size = 0.5,
        label.padding = 0.5,
        label.r = 0.05
      ) +
      ggplot2::guides(
        fill = "none",
        color = "none"
      )
  )

  if (length(bcps_program_maps) == 1) {
    return(purrr::pluck(bcps_program_maps, 1))
  } else {
    return(bcps_program_maps)
  }
}
