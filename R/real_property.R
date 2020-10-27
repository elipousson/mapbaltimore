#' Get real property data for an area
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant, and unimproved.
#' Real property or parcel data is from the Maryland State Department of Assessment and Taxation and may include errors. Check the \code{mapbaltimore::real_property} data description for details.
#'
#' @param area Required sf class tibble. Must include a name column.
#' @param area_type Optional character vector for the type of area (e.g. "neighborhood", "block_group"). The name column for the provided \code{area} must match the names or geoid of the one or more areas of the provided type to return data.
#' If buffer is TRUE, the area_type is ignored and the \code{sf::st_crop} function is used.
#' @param buffer Logical. If TRUE, the returned real property data includes property within a default buffered distance (1/8th of the diagonal distance across the bounding box) or within the provided \code{buffer_distance}.
#' If FALSE, the returned real property data includes property cropped to the bounding box of the area.
#' @param buffer_distance A single numeric vector with the buffer distance in meters.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#'
get_real_property <- function(area,
                              area_type = c(
                                "neighborhood",
                                "council_district",
                                "police_district",
                                "csa",
                                "block_group",
                                "tract"
                              ),
                              buffer = FALSE,
                              buffer_distance = 0) {
  check_area(area)

  # If buffer is TRUE and no buffer_distance is provided
  if ((buffer == TRUE) && (buffer_distance == 0)) {

    # Get bounding box
    area_bbox <- sf::st_bbox(area)

    # Calculate the diagonal distance of the area
    area_bbox_diagonal <- sf::st_distance(
      sf::st_point(c(area_bbox$xmin, area_bbox$ymin)),
      sf::st_point(c(area_bbox$xmax, area_bbox$ymax))
    )

    # Generate buffer proportional (1/8) to the diagonal distance
    buffer_meters <- units::set_units(area_bbox_diagonal * 0.125, m)
  } else if ((buffer == TRUE) && (buffer_distance != 0)) {
    buffer_meters <- units::set_units(buffer_distance, m)
  }

  if (buffer == TRUE) {
    # Crop real_property data to a buffered area
    area_real_property <- sf::st_crop(
      real_property,
      sf::st_buffer(area, buffer_meters)
    )

    return(area_real_property)
  }

  if (exists(area_type) && (area_type %in% c("neighborhood", "council_district", "police_district", "csa", "block_group", "tract"))) {

    # Match area_type to available options
    # area_type <- match.arg(area_type)

    # Filter real_property data to matching name
    area_real_property <- dplyr::filter(
      real_property,
      .data[[area_type]] %in% area$name
    )

    return(area_real_property)
  } else if (exists(area_type)) {

    # Return error if any error type other than the supported types is provided
    stop("The area_type you provided is not supported.")
  } else if (buffer == FALSE) {
    area_real_property <- sf::st_crop(
      real_property,
      area
    )

    return(area_real_property)
  }
}

#' Map real property data to show tenure for neighborhood
#'
#' Map showing parcels described as principal residence, non-principal residence, vacant, and unimproved properties. If the area sf tibble includes multiple areas, a separate map is created for each area provided.
#' Parcel data is from the Maryland State Department of Assessment and Taxation.
#'
#' @param area sf class tibble. Object must include a name column.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
map_tenure <- function(area = NULL) {

 check_area(area)

  # Nest area data
  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  # Get real property data for area or areas
  area_nested$real_property_data <- purrr::map(
    area_nested$data,
    ~ get_real_property(.x, buffer = TRUE)
    )

  # Set ordered levels for status variable
  status_levels <- c(
    "Principal residence only",
    "Principal residence (and another use)",
    "Not a principal residence",
    "Vacant property",
    "Unimproved property"
  )

  # Create and level improvement, occupancy, and residency status variable
  area_nested$real_property_data <- purrr::map(
    area_nested$real_property_data,
    ~ dplyr::mutate(.x,
                    # Create status variable
                    status = dplyr::case_when(
                      no_imprv == "Y" ~ "Unimproved property",
                      vacind == "Y" ~ "Vacant property", # NOTE: Order is important to remove vacant properties before tenure classification
                      permhome == "H" ~ "Principal residence only",
                      permhome == "D" ~ "Principal residence (and another use)",
                      permhome == "N" ~ "Not a principal residence"
                    ),
                    # Relevel status variable
                    status = forcats::fct_relevel(status, status_levels)
    ))

  area_tenure_map <- purrr::map2(
    area_nested$data,
    area_nested$real_property_data,
    ~ # Create map of area real_property
      ggplot2::ggplot() +
      # Map real_property codes
      ggplot2::geom_sf(data = .y,
                       aes(fill = status),
                       color = NA) +
      # Define color scale for status variable
      ggplot2::scale_fill_viridis_d() +
      # Map neighborhood boundary
      ggplot2::geom_sf(data = .x,
                       color = 'gray20',
                       fill = NA,
                       linetype = 5) +
      # Add title, fill label, caption, and minimal theme
      ggplot2::labs(
        title = glue::glue("{.x$name}: Properties by improvement, occupancy, and residency status"),
        fill = "Property status",
        caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_line(color = "transparent"),
        axis.title = ggplot2::element_text(color = "transparent"),
        axis.text = ggplot2::element_text(color = "transparent")
      )
    )

  return(area_tenure_map)

}

#' Map real property data to show decade built
#'
#' Map showing parcels color coded by the decade of the year the primary structure was built. If the area sf tibble includes multiple areas, a separate map is created for each area provided.
#' Parcel data is from the Maryland State Department of Assessment and Taxation and may include errors.
#'
#' @param area sf class tibble. Object must include a name column.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
map_decade_built <- function(area = NULL) {

  check_area(area)

  # Nest area data
  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  # Get real property data for area or areas
  area_nested$real_property_data <- purrr::map(
    area_nested$data,
    ~ get_real_property(.x, buffer = TRUE)
  )

  # Create a decade built variable
  area_nested$real_property_data <- purrr::map(
    area_nested$real_property_data,
    ~ dplyr::mutate(.x,
                    # Create decade start variable
                    decade_built = as.factor(floor(year_build / 10) * 10)
                    )
    )
  # TODO: Replace 0 values with NA

  area_decade_built_map <- purrr::map2(
    area_nested$data,
    area_nested$real_property_data,
    ~ # Create map of area real_property
      ggplot2::ggplot() +
      # Map decade built
      ggplot2::geom_sf(data = .y,
                       aes(fill = decade_built),
                       color = NA) +
      # Define color scale for decade built variable
      ggplot2::scale_fill_viridis_d(na.value = "gray80") +
      # Map area boundary
      ggplot2::geom_sf(data = .x,
                       color = 'gray20',
                       fill = NA,
                       linetype = 5) +
      # Add title, fill label, caption, and minimal theme
      ggplot2::labs(
        title = glue::glue("{.x$name}: Properties by decade built"),
        fill = "Decade built",
        caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
      ) +
      ggplot2::theme_minimal() +
      ggplot2::theme(
        panel.grid.major = ggplot2::element_line(color = "transparent"),
        axis.title = ggplot2::element_text(color = "transparent"),
        axis.text = ggplot2::element_text(color = "transparent")
      )
  )

  return(area_decade_built_map)

}


