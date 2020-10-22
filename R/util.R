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
#' @param area_name Character vector of any length. Required if area_type is "neighborhood", "council", or "police"
#' @param area_geoid Character vector of any length. Required if area_type is "blockgroup" or "tract"
#' @param union  Defaults to FALSE. If TRUE and multiple areas are provided, the area geography will be combined into a single sf object.
#'
#' @export
#'
get_area <- function(area_type = c(
                       "neighborhood",
                       "council",
                       "police",
                       "csa",
                       "blockgroup",
                       "tract"
                     ),
                     area_name = NULL,
                     area_geoid = NULL,
                     union = FALSE) {

  # TODO: Consider adding a combine parameter that allows for combination but not union

  area_type <- match.arg(area_type)

  if (area_type == "neighborhood") {
    area <- dplyr::filter(neighborhoods, name %in% area_name)
  } else if (area_type == "council") {
    area <- dplyr::filter(council_districts, name %in% area_name)
  } else if (area_type == "police") {

    # area <- dplyr::filter(police_districts, name %in% area_name)
  } else if (area_type == "csa") {

    # area <- dplyr::filter(community_statistical_areas, name %in% area_name)
  } else if (area_type == "blockgroup") {
    area <- dplyr::filter(baltimore_block_groups, geoid %in% area_geoid)
  } else if (area_type == "tract") {
    area <- dplyr::filter(baltimore_tracts, geoid %in% area_geoid)
  }

  if (length(area$geometry) == 0 && !is.null(area_name)) {
    stop(glue::glue("'{area_name}' does not match of any '{area_type}' type areas."))
  }

  if (union == TRUE && length(area_name) > 1) {
    areas <- tibble(
      area_list = list(area$name),
      area_count = length(area$name),
      geometry = sf::st_union(area)
    )

    areas <- sf::st_as_sf(areas)

    return(areas)
  } else if (union == TRUE && length(area_geoid) > 1) {
    areas <- tibble(
      area_list = list(area$geoid),
      area_count = length(area$geoid),
      geometry = sf::st_union(area)
    )

    areas <- sf::st_as_sf(areas)

    return(areas)
  } else if (union == FALSE) {
    return(area)
  }
}


#' Validate area provided to mapping or charting function.
#'
#' Validate an area for a mapping function or call the \code{get_area} function.
#'
#' @param area sf object. Must have a name column unless an \code{area_label} is provided.
#' @param area_type Character vector of length 1. Required. Supported values include c("neighborhood", "council", "police", "csa", "blockgroup", "tract")
#' @param area_name Character vector of any length. Required if area_type is "neighborhood", "council", or "police"
#' @param area_label  Character vector with the same length as the sf object.
#'
#' @export
#'
check_area <- function(area = NULL,
                       area_type = NULL,
                       area_name = NULL,
                       area_label = NULL) {

  # If area is provided, check if area is an sf object
  if (!is.null(area) && !("sf" %in% class(area))) {
    stop("The area must be an sf class object.")
  }

  # Get area if area_type and area_name is provided
  if (is.null(area) && !is.null(area_type) && !is.null(area_name)) {
    area <- get_area(
      area_type = area_type,
      area_name = area_name
    )
  }

  # If area label is not provided, use the name column as the label
  # TODO: Decide the best way to handle labelling
  # if (is.null(area_label)) {
  #  area$label <- area$name
  # }

  # If area label is provided, check if area_label matches the length of the area object
  if (!is.null(area_label) && (length(area$geometry) == length(area_label))) {
    area$name <- area_label
  } else if (!is.null(area_label) && (length(area$geometry) != length(area_label))) {
    stop("The number of labels does not match the number of areas provided.")
  }

  return(area)
}
