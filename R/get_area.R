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
#' specified location. [get_baltimore_area()] has different parameter names
#' (more consistent with [getdata::get_location()]) and is now recommended over
#' [get_area()] to avoid a name conflict with the [sfext::get_area()] function.
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
#'   geocoded using [tidygeocoder::geo()] *or* an sf object that
#'   intersects with the selected area types. If using an sf object, the CRS for
#'   the object must be EPSG:2804.
#' @param union If TRUE and multiple area names are provided, the area geometry
#'   is combined with [sf::st_union()]. Defaults to `FALSE.`
#' @param area_label Label to use as name for area if union is `TRUE` or as
#'   additional label column if union is `FALSE`. If union is `TRUE` and
#'   `area_label` is not provided, the original area names are concatenated into
#'   a single string.
#' @example examples/get_area.R
#' @seealso
#' [neighborhoods],[council_districts],[legislative_districts],
#' [congressional_districts],[planning_districts],[police_districts],[csas],
#' [park_districts]
#' [tidygeocoder::geo()]
#' @rdname get_area
#' @export
#' @importFrom glue glue
#' @importFrom getdata get_location
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
                     area_label = NULL) {
  type <- type %||% "neighborhood"
  rlang::check_required(type)
  if (stringr::str_detect(type, "s$")) {
    type <- stringr::str_remove(type, "s$")
  }

  type <- stringr::str_replace(type, "_", " ")

  type <- arg_match(type)

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
    cli::cli_abort("A `location` parameter is required to return {type}s.")
  }

  getdata::get_location(
    type = area_source,
    name = area_name,
    name_col = "name",
    id = area_id,
    id_col = "id",
    location = location,
    union = union,
    label = area_label
  )
}

#' @rdname get_area
#' @name get_baltimore_area
#' @param name Passed to area_name by [get_baltimore_area()]
#' @param id Passed to area_id by [get_baltimore_area()]
#' @param label Passed to area_label by [get_baltimore_area()]
#' @export
get_baltimore_area <- function(
    type = NULL,
    name = NULL,
    id = NULL,
    location = NULL,
    union = FALSE,
    label = NULL) {
  get_area(
    type = type,
    area_name = name,
    area_id = id,
    location = location,
    union = union,
    area_label = label
  )
}

#' @rdname get_area
#' @name get_neighborhood
#' @param ... Additional parameters passed by [get_neighborhood()] to
#'   [get_area()]
#' @export
get_neighborhood <- function(name,
                             location = NULL,
                             union = FALSE,
                             ...) {
  get_area(
    type = "neighborhood",
    area_name = name,
    location = location,
    union = union,
    ...
  )
}
