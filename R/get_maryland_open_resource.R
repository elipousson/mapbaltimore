#' Get dataset from Maryland Open Data portal with optional SoQL parameters
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function was deprecated as the functionality is now available in by
#' [mapmaryland::get_md_open_data()] which wraps the more general
#' [getdata::get_open_data()] function.
#'
#' Get a selected dataset using Socrata Query Language (SoQL) parameters as a
#' tibble or sf object. Details on SoQL queries are found in the Socrata API
#' documentation <https://dev.socrata.com/docs/queries/>
#'
#' @param resource Socrata dataset identifier for selected dataset from
#'   Maryland's Open Data portal
#' @param select SODA $select parameter. Set of columns to be returned, similar
#'   to a SELECT in SQL. <https://dev.socrata.com/docs/queries/select.html>
#' @param where SODA $where parameter. Filters the rows to be returned, similar
#'   to WHERE. <https://dev.socrata.com/docs/queries/where.html>
#' @param query SODA $query parameter. A full SoQL query string, all as one
#'   parameter. <https://dev.socrata.com/docs/queries/query.html>
#' @param geometry If TRUE and latitude/longitude columns available, return a
#'   [sf()] object. Default FALSE.
#' @param area sf object used to generate bbox (only used if bbox is NULL).
#'   Required to use trim parameter. Default NULL.
#' @param bbox bbox object generate query for non-spatial resources with
#'   latitude and longitude columns. Default NULL.
#' @param longitude Name of column containing longitude data, Default:
#'   'longitude'
#' @param latitude Name of column containing latitude data, Default: 'latitude'
#' @param trim If area is provided, trim data to the area boundary rather than
#'   the bounding box, Default: FALSE. area must be provided if TRUE.
#' @param crs Coordinate reference system to return.
#' @examples
#' \dontrun{
#' ## Get Q2 2020 vehicle crash data for Cecil County, Maryland
#' get_maryland_open_resource(
#'   resource = "65du-s3qu",
#'   where = "(year = '2020') AND (quarter = 'Q2') AND county_desc like 'Cecil'"
#' )
#' }
#' @keywords internal
#'
#' @export
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
#' @importFrom sf st_intersection st_union
#'
get_maryland_open_resource <- function(resource = NULL,
                                       select = NULL,
                                       where = NULL,
                                       query = NULL,
                                       geometry = FALSE,
                                       area = NULL,
                                       bbox = NULL,
                                       longitude = "longitude",
                                       latitude = "latitude",
                                       trim = FALSE,
                                       key = Sys.getenv("MARYLAND_OPEN_DATA_API_KEY"),
                                       crs = pkgconfig::get_config("mapbaltimore.crs", 2804)) {
  lifecycle::deprecate_warn("0.1.2", "get_maryland_open_resource()", "mapmaryland::get_md_open_data()")
  check_installed("RSocrata")

  # Check for Maryland Open Data API key
  if (is.null(key) | key == "") {
    cli_abort(
      c("An Maryland Open Data API key is required.",
        "i" = "Provide the key to the {.fn maryland_open_data_api_key}
        function to use it throughout your session."
      )
    )
  }

  # Make parameter calls
  if (!is.null(select)) {
    select <- paste0("$select=", select)
  }

  if (!is.null(bbox) | !is.null(area)) {
    where <- paste0("$where=", paste0(c(where, where_bbox(area, bbox, longitude, latitude)), collapse = " AND "))
  } else if (!is.null(where)) {
    where <- paste0("$where=", where)
  }

  if (!is.null(query)) {
    query <- paste0("$query=", query)
  }


  # Assemble url from resource identifier, and select, where, and query parameters
  url <- paste0("https://opendata.maryland.gov/resource/", resource, ".json")
  if (!is.null(select) | !is.null(where) | !is.null(query)) {
    url <- paste0(url, "?", paste0(c(select, where, query), collapse = "&"))
  }

  # Download data from Maryland Open Data portal
  resource <- RSocrata::read.socrata(url = url, app_token = key) %>%
    tibble::as_tibble() %>%
    janitor::clean_names("snake")


  if (!geometry) {
    return(resource)
  }

  resource <- sfext::df_to_sf(
    x = resource,
    coords = c(longitude, latitude),
    crs = crs
  )

  if (trim && !is.null(area)) {
    resource <- sf::st_intersection(resource, sf::st_union(area))
  }

  resource
}

#' @noRd
#' @importFrom glue glue
#' @importFrom sf st_transform st_bbox
where_bbox <- function(area = NULL,
                       bbox = NULL,
                       longitude = "longitude",
                       latitude = "latitude",
                       crs = 4326) {
  if (is.null(bbox) && !is.null(area)) {
    bbox <- area %>%
      sf::st_transform(crs) %>%
      sf::st_bbox()
  }
  glue("(({longitude} >= {bbox$xmin[[1]]}) AND ({longitude} <= {bbox$xmax[[1]]}) AND {latitude} >= {bbox$ymin[[1]]}) AND ({latitude} <= {bbox$ymax[[1]]})")
}
