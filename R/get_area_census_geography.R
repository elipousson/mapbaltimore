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

  return_geography <- return_geography %>%
    dplyr::mutate(
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
