#' Map real property data for an area
#'
#' Map real property data by improvement, vacancy, principal residence status, and other characteristics.
#' This function is intended to replace map_tenure, map_vacancy, and (eventually) map_decade_built.
#' Real property or parcel data is from the Maryland State Department of Assessment and Taxation and may include outdated or inaccurate information.
#' Check the \code{mapbaltimore::real_property} data description for details.
#'
#' @param area Simple features object. Function currently supports only a single area at a time.
#' @param property Real property variable to map. Options include c("improved", "vacant", "principal residence", "value"). Currently supports only one variable at a time.
#' @inheritParams get_buffered_area
#' @param mask If TRUE, apply a white, 0.6 alpha mask over property located outside the provided area. Default FALSE.
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#'
map_area_property <- function(area,
                              property = c("improved", "vacant", "principal residence", "value"),
                              diag_ratio = 0.1,
                              dist = NULL,
                              trim = FALSE,
                              mask = FALSE) {
  property <- match.arg(property)

  if (length(area$geometry) == 1) {
    area_property <- get_area_data(
      data = real_property,
      area = area,
      diag_ratio = diag_ratio,
      dist = dist,
      trim = trim
    )
  } else if (length(area$geometry) > 1) {
    area <- area %>%
      dplyr::nest_by(name, .keep = TRUE)

    area_property <- purrr::map(
      area$data,
      ~ get_area_data(
        data = real_property,
        area = .x,
        diag_ratio = diag_ratio,
        dist = dist,
        trim = trim
      )
    )

    stop("Multiple areas are not currently supported by this function.")
  }

  # Set up ggplot2 plot
  area_property_map <- ggplot2::ggplot()

  if (property == "improved") {

    # Set ordered levels for status variable
    property_levels <- c(
      "Improved property",
      "Unimproved property"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        improvement = dplyr::case_when(
          no_imprv == "Y" ~ property_levels[[2]],
          TRUE ~ property_levels[[1]]
        ),
        improvement = forcats::fct_relevel(improvement, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = improvement),
        color = NA
      ) +
      ggplot2::labs(fill = "Category") +
      ggplot2::scale_fill_viridis_d()
  } else if (property == "vacant") {

    # Set ordered levels for status variable
    property_levels <- c(
      "Vacant property",
      "Occupied property"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        vacant = dplyr::case_when(
          vacind == "Y" ~ property_levels[[1]],
          TRUE ~ property_levels[[2]]
        ),
        vacant = forcats::fct_relevel(vacant, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = vacant),
        color = NA
      ) +
      ggplot2::labs(fill = "Vacancy category") +
      ggplot2::scale_fill_viridis_d()
  } else if (property == "principal residence") {

    # Set ordered levels for status variable
    property_levels <- c(
      "Principal residence only",
      "Principal residence (and another use)",
      "Not a principal residence"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        principal_residence = dplyr::case_when(
          permhome == "H" ~ property_levels[[1]],
          permhome == "D" ~ property_levels[[2]],
          permhome == "N" ~ property_levels[[3]]
        ),
        principal_residence = forcats::fct_relevel(principal_residence, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = principal_residence),
        color = NA
      ) +
      ggplot2::labs(fill = "Tenure category") +
      ggplot2::scale_fill_viridis_d()
  }

  if (property != "improved") {
    # Cover unimproved properties with light gray for all maps except improvement maps
    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = dplyr::filter(area_property, no_imprv == "Y"),
        fill = "gray80",
        color = NA
      )
  }

  if (mask) {
    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = get_area_mask(
          area = area,
          diag_ratio = diag_ratio,
          dist = dist
          ),
        fill = "white",
        alpha = 0.6
      )
  }

  return(area_property_map)
}

#' Get real property data for an area
#'
#' Map showing parcels described as owner occupied, non-owner occupied, vacant, and unimproved.
#' Real property or parcel data is from the Maryland State Department of Assessment and Taxation and may include errors. Check the \code{mapbaltimore::real_property} data description for details.
#'
#' @param area Required sf class tibble. Must include a name column.
#' @param buffer Optional. If default (NULL), the returned real property data includes property within a default buffered distance (1/8th of the diagonal distance across the bounding box). If numeric, the function returns data cropped to area buffered by this distance in meters.
#' @param filter Default FALSE. Must be TRUE to use the filter_by parameter.
#' @param filter_by Optional character vector for the type of area (e.g. "neighborhood", "block_group"). The name column for the provided \code{area} must match the names or geoid of the one or more areas of the provided type to return data.
#' If buffer is TRUE, the type is ignored and the \code{\link[sf]{st_crop}} function is used.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
#'
get_real_property <- function(area,
                              dist = NULL,
                              filter = FALSE,
                              filter_by = c(
                                "neighborhood",
                                "police district",
                                "council district",
                                "csa"
                              )
                            ) {
  check_area(area)

if (!filter) {
  buffered_area <- get_buffered_area(area, dist)

  # Crop real_property data to a buffered area
  area_real_property <- real_property %>%
    sf::st_crop(buffered_area)

  return(area_real_property)

} else {
  # Match type to available options
  filter_by <- match.arg(filter_by)

  # Replace space with underscore
  filter_by <- gsub(" ", "_", filter_by)

  # Filter real_property data to matching name
  area_real_property <- dplyr::filter(
    real_property,
    .data[[area_type]] %in% area$name
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
    ~ get_real_property(.x)
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

  set_map_theme() # Set map theme

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
                       color = "gray20",
                       fill = NA,
                       linetype = 5) +
      # Add title, fill label, caption
      ggplot2::labs(
        title = glue::glue("{.x$name}: Properties by improvement, occupancy, and residency status"),
        fill = "Property status",
        caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
      )
    )

  if (length(area_tenure_map) == 1) {
    return(purrr::pluck(area_tenure_map, 1))
  } else {
    return(area_tenure_map)
  }

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
    ~ get_real_property(.x)
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

  set_map_theme() # Set map theme

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
                       color = "gray20",
                       fill = NA,
                       linetype = 5) +
      # Add title, fill label and caption
      ggplot2::labs(
        title = glue::glue("{.x$name}: Properties by decade built"),
        fill = "Decade built",
        caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
      )
  )

  if (length(area_decade_built_map) == 1) {
    return(purrr::pluck(area_decade_built_map, 1))
  } else {
    return(area_decade_built_map)
  }

}


#' Map real property data to show vacant and improved properties in an area
#'
#' Map showing parcels described as principal residence, non-principal residence, vacant, and unimproved properties. If the area sf tibble includes multiple areas, a separate map is created for each area provided.
#' Parcel data is from the Maryland State Department of Assessment and Taxation.
#'
#' @param area sf class tibble. Object must include a name column.
#'
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf
#'
map_vacancy <- function(area = NULL) {

  check_area(area)

  # Nest area data
  area_nested <- dplyr::nest_by(area,
                                name,
                                .keep = TRUE)

  # Get real property data for area or areas
  area_nested$real_property_data <- purrr::map(
    area_nested$data,
    ~ get_real_property(.x)
  )

  # Set ordered levels for status variable
  status_levels <- c(
    "Unimproved property",
    "Vacant property"
  )

  # Create and level improvement, occupancy, and residency status variable
  area_nested$real_property_data <- purrr::map(
    area_nested$real_property_data,
    ~ dplyr::mutate(.x,
                    # Create status variable
                    status = dplyr::case_when(
                      no_imprv == "Y" ~ "Unimproved property",
                      vacind == "Y" ~ "Vacant property" # NOTE: Order is important to remove vacant properties before tenure classification
                      ),
                    # Relevel status variable
                    status = forcats::fct_relevel(status, status_levels)
    ))

  set_map_theme() # Set map theme

  area_vacancy_map <- purrr::map2(
    area_nested$data,
    area_nested$real_property_data,
    ~ # Create map of area real_property
      ggplot2::ggplot() +
      # Map real_property codes
      ggplot2::geom_sf(data = .y,
                       aes(fill = status),
                       color = NA) +
      # Define color scale for status variable
      ggplot2::scale_fill_viridis_d(na.value = "gray70") +
      # Map neighborhood boundary
      ggplot2::geom_sf(data = .x,
                       color = "gray20",
                       fill = NA,
                       linetype = 5) +
      # Add title, fill label, caption
      ggplot2::labs(
        title = glue::glue("{.x$name}: vacant properties"),
        fill = "Property status",
        caption = "Source: Maryland State Department of Assessments and Taxation (SDAT)"
      )
  )

  if (length(area_vacancy_map) == 1) {
    return(purrr::pluck(area_vacancy_map, 1))
  } else {
    return(area_vacancy_map)
  }

}
