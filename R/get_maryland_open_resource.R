#' Get dataset from Maryland Open Data portal with optional SoQL parameters
#' @description Get a selected dataset using Socrata Query Language (SoQL) parameters as a tibble or sf object.
#' Details on SoQL queries are found in the Socrata API documentation \url{https://dev.socrata.com/docs/queries/}
#' @param resource Socrata dataset identifier for selected dataset from Maryland's Open Data portal
#' @param select SODA $select parameter. Set of columns to be returned, similar to a SELECT in SQL. \url{https://dev.socrata.com/docs/queries/select.html}
#' @param where SODA $where parameter. Filters the rows to be returned, similar to WHERE. \url{https://dev.socrata.com/docs/queries/where.html}
#' @param query SODA $query parameter. A full SoQL query string, all as one parameter. \url{https://dev.socrata.com/docs/queries/query.html}
#' @param geometry If TRUE and latitude/longitude columns available, return a \code{\link{sf}} object. Default FALSE.
#' @param crs Coordinate reference system to return.
#' @examples
#'
#' \dontrun{
#' ## Get Q2 2020 vehicle crash data for Cecil County, Maryland
#' get_maryland_open_resource(
#'   resource = "65du-s3qu",
#'   where = "(year = '2020') AND (quarter = 'Q2') AND county_desc like 'Cecil'"
#' )
#' }
#' @export
#' @importFrom RSocrata read.socrata
#' @importFrom tibble as_tibble
#' @importFrom janitor clean_names
#' @importFrom dplyr filter
#' @importFrom sf st_as_sf st_transform
#'
get_maryland_open_resource <- function(resource = NULL,
                                       select = NULL,
                                       where = NULL,
                                       query = NULL,
                                       geometry = FALSE,
                                       crs = 2804) {

  # Check for Maryland Open Data API key
  if (Sys.getenv("MARYLAND_OPEN_DATA_API_KEY") != "") {
    key <- Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")
  } else if (is.null(key)) {
    stop("An Maryland Open Data API key is required. Povide the key to the `maryland_open_data_api_key` function to use it throughout your session.")
  }

  # Make parameter calls
  if (!is.null(select)) {
    select <- paste0("$select=", select)
  }

  if (!is.null(where)) {
    where <- paste0("$where=", where)
  }

  if (!is.null(query)) {
    query <- paste0("$query=", query)
  }

  # Set base resource url for Maryland Open Data portal
  base <- "https://opendata.maryland.gov/resource/"

  # Assemble call from base url, resource identifier, and select, where, and query parameters
  call <- paste0(base, resource, ".json")
  if (!is.null(select) | !is.null(where) | !is.null(query)) {
    call <- paste0(call, "?", paste0(c(select, where, query), collapse = "&"))
  }

  # Download data from Maryland Open Data portal
  resource <- RSocrata::read.socrata(call, app_token = key)
  resource <- tibble::as_tibble(resource)
  resource <- janitor::clean_names(resource)

  if (("longitude" %in% names(resource)) && geometry == TRUE) {

    # Check that lat/lon are numeric
    if (!is.numeric(resource$longitude)) {
      resource$longitude <- as.numeric(resource$longitude)
      resource$latitude <- as.numeric(resource$latitude)
    }

    # Exclude rows with missing coordinates
    resource <- dplyr::filter(resource, !is.na(longitude))

    # Convert resource to sf object
    resource_sf <- sf::st_as_sf(resource,
      coords = c("longitude", "latitude"),
      agr = "constant",
      crs = 4269, # https://epsg.io/4269
      stringsAsFactors = FALSE,
      remove = TRUE
    )

    # Set CRS
    resource <- sf::st_transform(resource_sf, crs) # https://epsg.io/2804
  } else if (geometry == TRUE) {
    warning("geometry is TRUE but this dataset does not appear to contain latitude and longitude columns.")
  }

  return(resource)
}
