#' Map real property data to show tenure for neighborhood
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant, and unimproved.
#' Parcel data is from the Maryland State Department of Assessment and Taxation and may include errors.
#'
#' @param area sf class tibble. Object must include a name column.
#' @param area_type Character vector. Length 1 character vector passed to \code{get_area} function if area is not provided.
#' @param area_name Character vector. Passed to \code{get_area} function if area is not provided.
#' @param area_label Character vector. Must
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
map_tenure <- function(area = NULL,
                       area_type = NULL,
                       area_name = NULL,
                       area_label = NULL) {

 area <- check_area(area,
                    area_type,
                    area_name,
                    area_label)


  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  area_nested$real_property_data <- purrr::map(
    area_nested$data,
    ~ get_real_property_for_area(.x))

  tenure_maps <- purrr::map2(
    area_nested$data,
    area_nested$real_property_data,
    ~ map_real_property_for_area(area = .x,
                                 area_real_property = .y)
  )

  return(tenure_maps)

}

get_real_property_for_area <- function(area) {

  # Get bounding box
  area_bbox <- sf::st_bbox(area)

  # Calculate the diagonal distance of the area
  diagonal_distance <- sf::st_distance(
    sf::st_point(c(area_bbox$xmin, area_bbox$ymin)),
    sf::st_point(c(area_bbox$xmax, area_bbox$ymax))
  )

  # Generate buffer proportional to the diagonal distance
  buffer <- units::set_units(diagonal_distance * 0.125, m)

  # Crop real_property data to a buffered area
  area_real_property <- sf::st_crop(
    real_property,
    sf::st_buffer(area, buffer)
  )

  # Create an status variable for improvements, vacancy, and owner-occupancy status
  area_real_property <- dplyr::mutate(area_real_property,
                                      status = dplyr::case_when(
                                        no_imprv == "Y" ~ "Unimproved property",
                                        vacind == "Y" ~ "Vacant property", # NOTE: Order is important to remove vacant properties before tenure classification
                                        permhome == "H" ~ "Principal residence only",
                                        permhome == "D" ~ "Principal residence (and another use)",
                                        permhome == "N" ~ "Not a principal residence"
                                      )
  )

  # Set ordered levels for status
  status_levels <- c(
    "Principal residence only",
    "Principal residence (and another use)",
    "Not a principal residence",
    "Vacant property",
    "Unimproved property"
  )

  # Relevel status variable
  area_real_property$status <- forcats::fct_relevel(area_real_property$status, status_levels)

  return(area_real_property)
}

map_real_property_for_area <- function(area,
                                       area_real_property) {

  # Create map of area real_property
  ggplot2::ggplot() +
    # Map real_property codes
    ggplot2::geom_sf(data = area_real_property,
                     aes(fill = status),
                     color = NA) +
    # Define color scale for status variable
    ggplot2::scale_fill_viridis_d() +
    # Map neighborhood boundary
    ggplot2::geom_sf(data = area,
                     color = 'gray20',
                     fill = NA,
                     linetype = 5) +
    # Add title, fill label, caption, and minimal theme
    ggplot2::labs(
      title = glue::glue("{area$name}: Properties by improvement, occupancy, and residency status"),
      fill = "Property status",
      caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      panel.grid.major = element_line(color = "transparent"),
      axis.title = element_text(color = "transparent"),
      axis.text = element_text(color = "transparent")
    )

}

