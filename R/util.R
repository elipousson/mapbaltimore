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
#' Validate an area for a mapping function or call the \code{get_area} function.
#'
#' @param area sf object. Must have a name column unless an \code{area_label} is provided.
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
