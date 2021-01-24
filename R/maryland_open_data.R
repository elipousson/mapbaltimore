#' Install a Maryland Open Data Portal API Key in Your \code{.Renviron} File for Repeated Use
#' @description This function will add your Maryland Open Data Portal API key to your \code{.Renviron} file so it can be called securely without being stored
#' in your code. After you have installed your key, it can be called any time by typing \code{Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")} and can be
#' used in package functions by simply typing MARYLAND_OPEN_DATA_API_KEY If you do not have an \code{.Renviron} file, the function will create on for you.
#' If you already have an \code{.Renviron} file, the function will append the key to your existing file, while making a backup of your
#' original file for disaster recovery purposes.
#' @param key The API key provided to you from Maryland Open Data Portal formatted in quotes. A key be be created after signing up \url{https://imap.maryland.gov/Pages/open-data-portal-signup.aspx}
#' @param install if TRUE, will install the key in your \code{.Renviron} file for use in future sessions.  Defaults to FALSE.
#' @param overwrite If this is set to TRUE, it will overwrite an existing MARYLAND_OPEN_DATA_API_KEY that you already have in your \code{.Renviron} file.
#' @importFrom utils write.table read.table
#' @examples
#'
#' \dontrun{
#' MARYLAND_OPEN_DATA_API_KEY("111111abc", install = TRUE)
#' # First time, reload your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")
#' }
#'
#' \dontrun{
#' # If you need to overwrite an existing key:
#' MARYLAND_OPEN_DATA_API_KEY("111111abc", overwrite = TRUE, install = TRUE)
#' # First time, relead your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("MARYLAND_OPEN_DATA_API_KEY")
#' }
#' @export

maryland_open_data_api_key <- function(key, overwrite = FALSE, install = FALSE) {
  if (install) {
    home <- Sys.getenv("HOME")
    renv <- file.path(home, ".Renviron")
    if (file.exists(renv)) {
      # Backup original .Renviron before doing anything else here.
      file.copy(renv, file.path(home, ".Renviron_backup"))
    }
    if (!file.exists(renv)) {
      file.create(renv)
    }
    else {
      if (isTRUE(overwrite)) {
        message("Your original .Renviron will be backed up and stored in your R HOME directory if needed.")
        oldenv <- read.table(renv, stringsAsFactors = FALSE)
        newenv <- oldenv[-grep("MARYLAND_OPEN_DATA_API_KEY", oldenv), ]
        write.table(newenv, renv,
          quote = FALSE, sep = "\n",
          col.names = FALSE, row.names = FALSE
        )
      }
      else {
        tv <- readLines(renv)
        if (any(grepl("MARYLAND_OPEN_DATA_API_KEY", tv))) {
          stop("An MARYLAND_OPEN_DATA_API_KEY already exists. You can overwrite it with the argument overwrite=TRUE", call. = FALSE)
        }
      }
    }

    keyconcat <- paste0("MARYLAND_OPEN_DATA_API_KEY='", key, "'")
    # Append API key to .Renviron file
    write(keyconcat, renv, sep = "\n", append = TRUE)
    message('Your API key has been stored in your .Renviron and can be accessed by Sys.getenv("MARYLAND_OPEN_DATA_API_KEY"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
    return(key)
  } else {
    message("To install your API key for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(MARYLAND_OPEN_DATA_API_KEY = key)
  }
}

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


#' Get vehicle crashes for area in Baltimore from Maryland Open Data portal
#' @description Get vehicle crashes for selected area in Baltimore City.
#' @param area \code{\link{sf}} object.
#' @param start_year earliest year of crash data to return.
#' @param end_year latest year of crash data to return. If \code{end_year} is not provided, only a single year is returned.
#' @param geometry If TRUE, return a sf object. Default FALSE.
#' @param trim If TRUE, data trimmed to area with \code{\link[sf]{st_intersection()}}. Default FALSE.
#' @export
get_area_crashes <- function(area,
                             start_year = 2020,
                             end_year = NULL,
                             geometry = FALSE,
                             trim = FALSE) {


  area_bbox <- sf::st_bbox(sf::st_transform(area, 4326))

  where_bbox <- glue::glue("(latitude >= {area_bbox$ymin[[1]]}) AND (latitude <= {area_bbox$ymax[[1]]}) AND (longitude >= {area_bbox$xmin[[1]]}) AND (longitude <= {area_bbox$xmax[[1]]})")

  # Get resource
  crashes <- purrr::map_dfr(
    c(start_year:end_year),
    ~ get_maryland_open_resource(
      resource = "65du-s3qu",
      where = glue::glue(
        "(year = '{.x}') AND (county_desc like 'Baltimore City') AND {where_bbox}"
        ),
      geometry = geometry)
    )

  if (trim && geometry) {
    crashes <- sf::st_intersection(crashes, sf::st_union(area))
  }

  return(crashes)

}
