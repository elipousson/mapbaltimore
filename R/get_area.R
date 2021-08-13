#' Get area of selected type
#'
#' Get a sf object with one or more neighborhoods, Baltimore City Council
#' districts, Maryland Legislative Districts, U.S. Congressional Districts,
#' Baltimore Planning Districts, Baltimore Police Districts, or Community
#' Statistical Areas, park districts, or Census blocks, block groups, or tracts.
#' Area type is required and can be used in combination with area name, area id
#' (not supported by all data sets), or location (as an address or sf object).
#' Name and id are not supported for U.S. Census geogrpahies. Use the location
#' parameter to return any areas of the selected type that intersect with the
#' specified location.
#'
#' @param type Required. Area type matching one of the boundary datasets
#'   included with mapbaltimore. Supported values include "neighborhood",
#'   "council district", "legislative district", "congressional district",
#'   "planning district", "police district", "csa", "park district". U.S. Census
#'   geographies including "block", "block group", and "tract" are supported
#'   when using the location parameter only.
#' @param area_name name or names matching id column in data of selected
#'   dataset. Character.
#' @param area_id identifier or identifiers matching id column of selected
#'   dataset. Not all supported datasets have an id column and the id may be an
#'   integer or character depending on the dataset.
#' @param location Location supports to types of values: an address that can be
#'   geocoded using \code{\link[tidygeocoder]{geo}} *or* an sf object that
#'   intersects with the selected area types. If using an sf object, the CRS for
#'   the object must be EPSG:2804.
#' @param union If TRUE and multiple area names are provided, the area geometry
#'   is combined with \code{\link[sf]{st_union}}. Defaults to FALSE.
#' @param union_name Optional name to use for a combined area when union is set.
#'   If union is TRUE and a union_name is not provided, the original area names
#'   are concatenated into a single string
#' @examples
#' \dontrun{
#' # Get the Harwood neighborhood by name
#' get_area(type = "neighborhood", area_name = "Harwood")
#'
#' # Get City Council District 12 and 14 by id
#' get_area(type = "council district", area_id = c(12, 14))
#'
#' # Get the east and southeast planning districts and combine them
#' get_area(type = "planning district", area_id = c("East", "Southeast"), union = TRUE, union_name = "East and Southeast Planning Districts")
#'
#' # Get legislative district where the Walters Art Museum is located
#' get_area(type = "legislative district", location = "600 N Charles St, Baltimore, MD 21201")
#'
#' # Get council district for the Edmondson Village neighborhood
#' get_area(type = "council district", location = get_area("neighborhood", "Edmondson Village"))
#'
#' # Get Census tract for Morgan Park neighborhood with address of former President's Residence
#' get_area(type = "tract", location = "2412 College Avenue, Baltimore, MD 21214")
#' }
#' @seealso
#' \code{\link[mapbaltimore]{neighborhoods}},\code{\link[mapbaltimore]{council_districts}},\code{\link[mapbaltimore]{legislative_districts}},\code{\link[mapbaltimore]{congressional_districts}},\code{\link[mapbaltimore]{planning_districts}},\code{\link[mapbaltimore]{police_districts}},\code{\link[mapbaltimore]{csas}},\code{\link[mapbaltimore]{park_districts}}
#' \code{\link[tidygeocoder]{geo}}
#' @rdname get_area
#' @export
#' @importFrom dplyr filter
#' @importFrom glue glue
#' @importFrom tidygeocoder geo
#' @importFrom sf st_as_sf st_transform st_filter st_union
#' @importFrom tibble tibble
get_area <- function(type = c(
                       "neighborhood",
                       "council district",
                       "legislative district",
                       "congressional district",
                       "planning district",
                       "police district",
                       "csa",
                       "park district",
                       "block",
                       "block group",
                       "tract"
                     ),
                     area_name = NULL,
                     area_id = NULL,
                     location = NULL,
                     union = FALSE,
                     union_name = NULL) {
  area_source <-
    switch(type,
      "neighborhood" = neighborhoods,
      "council district" = council_districts,
      "legislative district" = legislative_districts,
      "congressional district" = congressional_districts,
      "planning district" = planning_districts,
      "police district" = police_districts,
      "csa" = csas,
      "park district" = park_districts,
      "block" = baltimore_blocks,
      "block group" = baltimore_block_groups,
      "tract" = baltimore_tracts
    )

  if ((type %in% c("block", "block group", "tract")) && is.null(location)) {
    stop(glue::glue("A `location` parameter is required to return {type}s."))
  }

  if (is.character(area_name)) {
    area <- dplyr::filter(area_source, name %in% area_name)

    if (nrow(area) == 0) {
      stop(glue::glue("The provided area name ('{area_name}') does not match any {type}s."))
    }
  } else if (!is.null(area_id) && ("id" %in% names(area_source))) {
    area <- dplyr::filter(area_source, id %in% area_id)

    if (nrow(area) == 0) {
      stop(glue::glue("The provided area id ('{area_id}') does not match any {type}s."))
    }
  } else if (!is.null(location)) {
    if (is.character(location)) {
      location <- tidygeocoder::geo(
        address = location,
        lat = "latitude",
        long = "longitude",
        mode = "single"
      ) |>
        sf::st_as_sf(
          coords = c("longitude", "latitude"),
          crs = 4326
        ) |>
        sf::st_transform(2804)
    }

    area <- area_source |>
      sf::st_filter(location)

    if (nrow(area) == 0) {
      stop(glue::glue("The provided location does not intersect with any {type}s."))
    }
  } else {
    stop("get_area requires an valid area_name, area_id, or location parameter.")
  }

  if (union == TRUE) {
    area_union <- tibble::tibble(
      name = paste0(area$name, collapse = " & "),
      geometry = sf::st_union(area)
    )

    area <- sf::st_as_sf(area_union)

    if (!is.null(union_name)) {
      area$name <- union_name
    }
  }

  return(area)
}
