#' Return geography for selected area type and name.
#'
#' Get the geometry and name of a selected neighborhood, City Council district, police district,
#' or Community Statistical Area.
#'
#' @param type Character vector of length 1. Required. Supported values include c("neighborhood", "council", "police", "csa")
#' @param name Character vector of any length.
#' @param union  Defaults to FALSE. If TRUE and multiple area names are provided, the area geometry is combined with \code{sf::st_union} and the area names is coerced from a vector to a nested list.
#'
#' @export
#'
get_area <- function(type = c(
                       "neighborhood",
                       "council district",
                       "police district",
                       "csa"
                     ),
                     area_name = NULL,
                     area_label = NULL,
                     union = FALSE) {

  type <- match.arg(type)
  type <- paste0(gsub(" ", "_", type), "s")

  area <- dplyr::filter(eval(as.name(type)), name %in% area_name)

  if (length(area$geometry) == 0 && !is.null(area_name)) {
    stop(glue::glue("The provided area name ('{area_name}') does not match any {type}s."))
  }

  if (!is.null(area_label)) {
    area$label <- area_label
  }

  if (union == TRUE && length(area_name) > 1) {
    areas <- tibble::tibble(
      name = paste0(area$name, collapse = " & "),
      area_list = list(area$name),
      area_count = length(area$name),
      geometry = sf::st_union(area)
    )

    area <- sf::st_as_sf(areas)
  }

  return(area)
}


#' Validate area provided to mapping or charting function.
#'
#' Validate an area for a mapping function or another mapbaltimore function.
#'
#' @param area sf object with a column named "name."
#'
#' @export
#'
check_area <- function(area) {

  # Check if area is an sf object
  if (!("sf" %in% class(area))) {
    stop("The area must be an sf class object.")
  } else if (!("name" %in% names(area))) {
    stop("The area must have a 'name' column.")
  }
}

#' Get nearby areas
#'
#' Return data for all areas of a specified type within a specified distance of another area
#'
#' @param area sf object. Must have a name column unless an \code{area_label} is provided.
#' @param type Length 1 character vector. Required to match one of the supported area types (excluding U.S. Census types). This is the area type for the areas to return and is not required to be the same type as the provided area.
#' @param buffer_distance Numeric. Distance in meters for matching nearby areas. Defaults to 1 meter.
#'
#' @export
#'
get_nearby_areas <- function(area,
                             type = c(
                               "neighborhood",
                               "council district",
                               "police district",
                               "csa"
                             ),
                             buffer = 1) {

  type <- match.arg(type)
  type <- paste0(gsub(" ", "_", type), "s")

  buffer <- units::set_units(buffer, m)

  # Check what type of nearby area to return
  return_type <- eval(as.name(type))

  # Select areas within 2 meters of the provided area
  nearby_areas <- sf::st_join(
    return_type,
    sf::st_buffer(
      dplyr::select(area, area_name = name),
      buffer
    ),
    by = "st_intersects"
  ) %>%
    dplyr::filter(
      # Filter to areas within 2 meters of the provided area
      area_name %in% area$name
    ) %>%
    dplyr::filter(
      # Remove area that was matched (only return nearby areas)
      # This is only necessary if multiple areas are provided
      !(name %in% area$name)
    ) %>%
    # Remove provided area name
    dplyr::select(-area_name)

  return(nearby_areas)
}

#' Get buffered area
#'
#' Return an sf object of an area with a buffer applied to it. If no buffer distance is provided, a default buffer is calculated of one-eighth the diagonal distance of the bounding box (corner to corner) for the area. The metadata for the provided area remains the same.
#'
#' @param area sf object.
#' @param buffer_distance Optional. A single numeric vector representing the buffer distance in meters.
#'
#' @export
#'
get_buffered_area <- function(area,
                              buffer = NULL) {
  if (is.null(buffer)) {
    # If no buffer distance is provided, use the diagonal distance of the bounding box to generate a proportional buffer distance
    area_bbox <- sf::st_bbox(area)

    area_bbox_diagonal <- sf::st_distance(
      sf::st_point(
        c(
          area_bbox$xmin,
          area_bbox$ymin
        )
      ),
      sf::st_point(
        c(
          area_bbox$xmax,
          area_bbox$ymax
        )
      )
    )

    buffer <- units::set_units(area_bbox_diagonal * 0.125, m)
  } else if (is.numeric(buffer)) {
    # Set the units for the buffer distance if provided
    buffer <- units::set_units(buffer, m)
  } else {
    # Return error if the provided buffer distance is not numeric
    stop("The buffer must be a numeric value representing the buffer distance in meters.")
  }

  buffered_area <- sf::st_buffer(area, buffer)

  return(buffered_area)
}

#' Get U.S. Census geography overlapping with an area.
#'
#' Return an sf object with the U.S. Census blocks, block groups, or tracts overlapping with an area. By default, at least 25% of the tract area or 30% of the block group area, or 50% of the block area must be within the provided area to be returned.
#' Returned sf object includes new columns with the combined land and water area of the Census geography, the Census geography area within the provided area, the percent of Census geography area within the provided area, and the percent of the provided area within the Census geography area.
#'
#' @param area sf object.
#' @param geography Character vector with type of U.S. Census
#' @param area_overlap Optional. A numeric value less than 1 and greater than 0 representing the physical area of the geography that should be within the provided area to return.
#'
#' @export
#'
get_area_census_geography <- function(area,
                                      geography = c("block", "block group", "tract"),
                                      area_overlap = NULL) {
  check_area(area)

  geography <- match.arg(geography)

  # Check what type of nearby area to return
  if (geography == "block") {
    overlap <- 0.5
    geography_citywide <- dplyr::rename(baltimore_blocks, aland = aland10, awater = awater10)
  } else if (geography == "block group") {
    overlap <- 0.3
    geography_citywide <- baltimore_block_groups
  } else if (geography == "tract") {
    overlap <- 0.25
    geography_citywide <- baltimore_tracts
  }

  if (!is.null(area_overlap) && is.numeric(area_overlap) && area_overlap < 1 && area_overlap > 0) {
    overlap <- area_overlap
  } else if (!is.null(area_overlap)) {
    stop("The area_overlap must be a numeric value less than 1 and greater than 0. The area_overlap represents the share of the Census geography that must be located within the area to be included.")
  }

  return_geography <- sf::st_intersection(geography_citywide, dplyr::select(area, name = name)) %>%
    dplyr::select(-name) # Remove area name

  return_geography <- dplyr::mutate(return_geography,
    # Combine land and water area for the Census geography
    geoid_area = (aland + awater),
    # Calculate the Census geography area after intersection function was applied
    geoid_area_in_area = as.numeric(sf::st_area(geometry)),
    perc_geoid_in_area = geoid_area_in_area / geoid_area,
    perc_area_in_geoid = geoid_area_in_area / as.numeric(sf::st_area(area))
  )

  # Filter to areas with the specified percent area overlap or greater
  return_geography <- dplyr::filter(return_geography, perc_geoid_in_area >= overlap)

  # Switch area columns back to orignal names for block data
  if (geography == "block") {
    return_geography <- return_geography %>%
      dplyr::rename(aland10 = aland, awater10 = awater) %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid10, geometry),
        by = "geoid10"
      ) %>%
      sf::st_as_sf()
  } else {
    return_geography <- return_geography %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid, geometry),
        by = "geoid"
      ) %>%
      sf::st_as_sf()
  }

  return(return_geography)
}

set_map_theme <- function() {
  ggplot2::theme_set(
    ggplot2::theme_minimal() # Set minimal theme
  )
  ggplot2::theme_update(
    panel.grid.major = ggplot2::element_blank(), # Remove lat/lon grid
    axis.title = ggplot2::element_blank(), # Remove lat/lon axis text
    axis.text = ggplot2::element_blank() # Remove numeric labels on lat/lon axis ticks
  )
}
