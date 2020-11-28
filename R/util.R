# print message on attaching if `sf` is not loaded
.onAttach <- function(libname, pkgname) {
  if (!isNamespaceLoaded("sf")) {
    packageStartupMessage("To work with the spatial data included in this package, you should also load the {sf} package with library(sf).")
  }
}

#' Return geography for selected area type and name.
#'
#' Get the geometry and name of a selected neighborhood, City Council district, police district,
#' Community Statistical Area, U.S. Census Block group or U.S. Census tract.
#'
#' @param area_type Character vector of length 1. Required. Supported values include c("neighborhood", "council", "police", "csa", "blockgroup", "tract")
#' @param area_name Character vector of any length. For U.S. Census geographies ("blockgroup", "tract"), provide selected geoid value or values instead of a name.
#' @param union  Defaults to FALSE. If TRUE and multiple area names are provided, the area geometry is combined with \code{sf::st_union} and the area names is coerced from a vector to a nested list.
#'
#' @export
#'
get_area <- function(area_type = c(
                       "neighborhood",
                       "council_district",
                       "police_district",
                       "csa",
                       "block_group",
                       "tract"
                     ),
                     area_name = NULL,
                     union = FALSE) {

  # TODO: Consider adding a combine parameter that allows for combination but not union

  area_type <- match.arg(area_type)

  if (area_type == "neighborhood") {
    area <- dplyr::filter(neighborhoods, name %in% area_name)
  } else if (area_type == "council_district") {
    area <- dplyr::filter(council_districts, name %in% area_name)
  } else if (area_type == "police_district") {
    area <- dplyr::filter(police_districts, name %in% area_name)
  } else if (area_type == "csa") {
    area <- dplyr::filter(csas, name %in% area_name)
  } else if (area_type == "block_group") {
    area <- dplyr::filter(baltimore_block_groups, geoid %in% area_name)
  } else if (area_type == "tract") {
    area <- dplyr::filter(baltimore_tracts, geoid %in% area_name)
  }

  if (length(area$geometry) == 0 && !is.null(area_name)) {
    stop(glue::glue("The provided area_name ('{area_name}') does not match any {area_type}s."))
  }

  if (union == TRUE && length(area_name) > 1) {
    areas <- tibble::tibble(
      name = paste0(area$name, collapse = " & "),
      area_list = list(area$name),
      area_count = length(area$name),
      geometry = sf::st_union(area)
    )

    areas <- sf::st_as_sf(areas)

    return(areas)
  } else {
    return(area)
  }
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
#' @param area_type Length 1 character vector. Required to match one of the supported area types (excluding U.S. Census types). This is the area type for the areas to return and is not required to be the same type as the provided area.
#' @param buffer_distance Numeric. Distance in meters for matching nearby areas. Defaults to 1 meter.
#'
#' @export
#'
get_nearby_areas <- function(area,
                             area_type = c(
                               "neighborhood",
                               "council_district",
                               "police_district",
                               "csa",
                               "block_group",
                               "tract"
                             ),
                             buffer_distance = 1) {
  area_type <- match.arg(area_type)

  buffer <- units::set_units(buffer_distance, m)

  # Check what type of nearby area to return
  if (area_type == "neighborhood") {
    area_type_to_return <- neighborhoods
  }
  else if (area_type == "council_district") {
    area_type_to_return <- council_districts
  }
  else if (area_type == "police_district") {
    area_type_to_return <- police_districts
  }
  else if (area_type == "csa") {
    area_type_to_return <- csas
  }

  # Select areas within 2 meters of the provided area
  nearby_areas <- sf::st_join(
    area_type_to_return,
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
                              buffer_distance = NULL) {
  if (is.null(buffer_distance)) {
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

    buffer_distance <- units::set_units(area_bbox_diagonal * 0.125, m)
  } else if (is.numeric(buffer_distance)) {
    # Set the units for the buffer distance if provided
    buffer_distance <- units::set_units(buffer_distance, m)
  } else {
    # Return error if the provided buffer distance is not numeric
    stop("The buffer_distance must be a numeric value representing the distance to buffer in meters.")
  }

  buffered_area <- sf::st_buffer(area, buffer_distance)

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
    stop("The area overlap must be a numeric value less than 1 and greater than 0. The overlap represents the share of the Census geography that must be located within the area to be included.")
  }

  geography_to_return <- sf::st_intersection(geography_citywide, dplyr::select(area, area_name = name)) %>%
    dplyr::select(-area_name) # Remove area name

  geography_to_return <- dplyr::mutate(geography_to_return,
    # Combine land and water area for the Census geography
    geoid_area = (aland + awater),
    # Calculate the Census geography area after intersection function was applied
    geoid_area_in_area = as.numeric(sf::st_area(geometry)),
    perc_geoid_in_area = geoid_area_in_area / geoid_area,
    perc_area_in_geoid = geoid_area_in_area / as.numeric(sf::st_area(area))
  )

  # Filter to areas with the specified percent area overlap or greater
  geography_to_return <- dplyr::filter(geography_to_return, perc_geoid_in_area >= overlap)

  # Switch area columns back to orignal names for block data
  if (geography == "block") {
    geography_to_return <- geography_to_return %>%
      dplyr::rename(aland10 = aland, awater10 = awater) %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid10, geometry),
        by = "geoid10"
      ) %>%
      sf::st_as_sf()
  } else {
    geography_to_return <- geography_to_return %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid, geometry),
        by = "geoid"
      ) %>%
      sf::st_as_sf()
  }


  return(geography_to_return)
}
