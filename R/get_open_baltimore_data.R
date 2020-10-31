#' Install an Open Baltimore API Key in Your \code{.Renviron} File for Repeated Use
#' @description This function will add your Open Baltimore API key to your \code{.Renviron} file so it can be called securely without being stored
#' in your code. After you have installed your key, it can be called any time by typing \code{Sys.getenv("OPEN_BALTIMORE_API_KEY")} and can be
#' used in package functions by simply typing OPEN_BALTIMORE_API_KEY If you do not have an \code{.Renviron} file, the function will create on for you.
#' If you already have an \code{.Renviron} file, the function will append the key to your existing file, while making a backup of your
#' original file for disaster recovery purposes.
#' @param key The API key provided to you from Open Baltimore formatted in quotes. A key be be created after signing up \url{https://data.baltimorecity.gov/signup}
#' @param install if TRUE, will install the key in your \code{.Renviron} file for use in future sessions.  Defaults to FALSE.
#' @param overwrite If this is set to TRUE, it will overwrite an existing OPEN_BALTIMORE_API_KEY that you already have in your \code{.Renviron} file.
#' @importFrom utils write.table read.table
#' @examples
#'
#' \dontrun{
#' OPEN_BALTIMORE_API_KEY("111111abc", install = TRUE)
#' # First time, reload your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("OPEN_BALTIMORE_API_KEY")
#' }
#'
#' \dontrun{
#' # If you need to overwrite an existing key:
#' OPEN_BALTIMORE_API_KEY("111111abc", overwrite = TRUE, install = TRUE)
#' # First time, relead your environment so you can use the key without restarting R.
#' readRenviron("~/.Renviron")
#' # You can check it with:
#' Sys.getenv("OPEN_BALTIMORE_API_KEY")
#' }
#' @export

open_baltimore_api_key <- function(key, overwrite = FALSE, install = FALSE) {
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
        newenv <- oldenv[-grep("OPEN_BALTIMORE_API_KEY", oldenv), ]
        write.table(newenv, renv,
          quote = FALSE, sep = "\n",
          col.names = FALSE, row.names = FALSE
        )
      }
      else {
        tv <- readLines(renv)
        if (any(grepl("OPEN_BALTIMORE_API_KEY", tv))) {
          stop("An OPEN_BALTIMORE_API_KEY already exists. You can overwrite it with the argument overwrite=TRUE", call. = FALSE)
        }
      }
    }

    keyconcat <- paste0("OPEN_BALTIMORE_API_KEY='", key, "'")
    # Append API key to .Renviron file
    write(keyconcat, renv, sep = "\n", append = TRUE)
    message('Your API key has been stored in your .Renviron and can be accessed by Sys.getenv("OPEN_BALTIMORE_API_KEY"). \nTo use now, restart R or run `readRenviron("~/.Renviron")`')
    return(key)
  } else {
    message("To install your API key for use in future sessions, run this function with `install = TRUE`.")
    Sys.setenv(OPEN_BALTIMORE_API_KEY = key)
  }
}

#' Get selected 311 Service Requests from Open Baltimore data portal
#' @description This function uses the RSocrata package to download 311 service requests from the Open Baltimore data portal.
#' Requests may be one or more service request types, by date, or by neighborhood, City Council District, or Police District.
#' Filtering by multiple criteria or for a limited period of time is recommended to avoid a long wait for a large data file to download.
#' @param area An sf object with a 'name' column. If area is provided, the function returns data within the bounding box of the provided area or areas.
#' @param request_type A string or character vector with multiple strings matching one or more of the possible \code{request_types}.
#' @param start_date The start date of the time period during which downloaded requests were created in the format "YYYY-MM-DD". An end date must be provided if a start date is provided.
#' @param end_date The end date of the time period during which downloaded requests were created in the format "YYYY-MM-DD".  An start date must be provided if an end date is provided.
#' @param filter_by A character string of the type of area to filter requests by. Supported area types include neighborhoods ("neighborhood"), City Council districts ("council_district"), and Police Districts ("police_district").
#' @param area_name A character string corresponding a neighborhood name or the number of a Council or Police District. Filtering by multiple areas or multiple area types is not currently supported.
#' @param geometry If TRUE the service requests are converted to an sf object with a projected CRS (2804). Requests with no coordinates are excluded if TRUE. Defaults to FALSE.
#' @examples
#'
#' \dontrun{
#' ## Get service requests for leaf removal and overgrown trees/shrubs in Council District 12 from September 2019
#' get_service_requests(
#'   request_type = c("SW-Leaf Removal", "HCD-Trees and Shrubs"),
#'   start_date = "2019-09-01",
#'   end_date = "2019-09-30",
#'   filter_by = "council_district",
#'   area_name = "12"
#' )
#' }
#'
#' \dontrun{
#' ## Get service requests for snow and ice on sidewalks from January 2020
#' get_service_requests(
#'   request_type = "HCD-Snow and Ice on Sidewalks",
#'   start_date = "2020-01-01",
#'   end_date = "2020-01-31"
#' )
#' }
#' @export


get_service_requests <- function(area,
                                 request_type = NULL,
                                 start_date = NULL,
                                 end_date = NULL,
                                 filter_by = c("neighborhood", "council_district", "police_district"),
                                 area_name = NULL,
                                 geometry = FALSE) {

  # Check for Open Baltimore API key
  if (Sys.getenv("OPEN_BALTIMORE_API_KEY") != "") {
    key <- Sys.getenv("OPEN_BALTIMORE_API_KEY")
  } else if (is.null(key)) {
    stop("An Open Baltimore API key is required. Obtain one by signing up for an account at https://data.baltimorecity.gov/signup, creating an API key, then providing the key to the `open_baltimore_api_key` function to use it throughout your session.")
  }

  # Check if area_name is provided if filter_by is provided
  if (!missing(filter_by) && is.null(area_name)) {
    stop("A valid area_name name must be provided to filter by neighborhood, council district, or police district using the filter_by parameter.")
  }

  # Check if sf object provided for area is valid then create a lat/long bounding box variable
  if (!missing(area)) {
    check_area(area)
    area_bbox <- sf::st_bbox(sf::st_transform(area, 4326))
  }

  # Create basic API call
  base <- "https://data.baltimorecity.gov/resource/" # Set base url for Open Baltimore
  resource <- "9agw-sxsr" # Set resource ID for 311 Customer Service Requests
  vars <- c("ServiceRequestNum", "CreatedDate", "StatusDate", "Agency", "SRType", "SRStatus", "LastActivity", "Outcome", "Address", "Neighborhood", "PoliceDistrict", "CouncilDistrict", "Longitude", "Latitude", "geolocation") # Define list of selected variables
  vars_list <- paste(vars, collapse = ",") # Collapse variable list into comma-separated string
  call <- glue::glue("{base}{resource}.json?$select={vars_list}")


  # Add additional parameters to API call
  if (!is.null(request_type) | !is.null(start_date) | !is.null(end_date) | !is.null(area_name) | !missing(area)) {
    call <- glue::glue("{call}&$where=")

    # Set extended call strings to NULL
    request_type_call <- NULL
    date_call <- NULL
    filter_by_area_name_call <- NULL
    area_bbox_call <- NULL


    # Add request type to call after check
    if (!is.null(request_type)) {
      # Check on the number of request types provided
      if (length(request_type) > 1) {
        request_type_call <- glue::glue("(SRType like '", stringr::str_c(request_type, sep = "", collapse = "' OR SRType like '"), "')")
      } else if (length(request_type) == 1) {
        request_type_call <- glue::glue("SRType like '{request_type}'")
      }
    }

    # Add start and end date to call after check
    if (!is.null(start_date) && !is.null(end_date)) {
      date_call <- glue::glue("CreatedDate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      end_date <- format(Sys.Date(), "%Y-%m-%d")
      date_call <- glue::glue("CreatedDate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      warning("The provided end date is ignored if a start date is not provided.")
    }

    # Add filter_by and area_name to call after check
    if (!is.null(area_name)) {

      # Validate filter_by argument and capitalize area_name
      filter_by <- match.arg(filter_by)
      area_name <- toupper(area_name)

      filter_by_area_name_call <- dplyr::case_when(
        filter_by == "neighborhood" ~ glue::glue("Neighborhood like '{area_name}'"),
        filter_by == "council_district" ~ glue::glue("CouncilDistrict = '{area_name}'"),
        filter_by == "police_district" ~ glue::glue("PoliceDistrict like '{area_name}'")
      )
    }


    # Add area bounding box call after check
    if (!missing(area)) {
      area_bbox_call <- glue::glue("within_box(geolocation, {area_bbox$ymax}, {area_bbox$xmax}, {area_bbox$ymin}, {area_bbox$xmin})")
    }

    # Combine parameter calls
    call <- glue::glue("{call}", paste0(c(request_type_call, date_call, filter_by_area_name_call, area_bbox_call), collapse = " AND "))
  }

  # Download data from Open Baltimore
  requests <- RSocrata::read.socrata(call, app_token = key)
  requests <- tibble::as_tibble(requests)
  requests <- janitor::clean_names(requests)

  requests <- dplyr::mutate(requests, # Clean variable names
    created_datetime = lubridate::ymd_hms(created_date),
    created_date = lubridate::date(created_date),
    status_datetime = lubridate::ymd_hms(status_date),
    longitude = as.numeric(longitude),
    latitude = as.numeric(latitude),
    year_created = lubridate::year(created_date),
    # Add hours and days to close columns to closed service requests
    hours_to_close = dplyr::case_when(
      sr_status == "Closed" ~ (lubridate::int_length(lubridate::interval(
        created_datetime,
        status_datetime
      ))) / 3600
    ),
    days_to_close = hours_to_close / 24
  )

  if (geometry == TRUE) {
    requests <- dplyr::filter(requests, !is.na(longitude))

    requests <- sf::st_as_sf(requests,
      coords = c("longitude", "latitude"),
      agr = "constant",
      crs = 4269,
      stringsAsFactors = FALSE,
      remove = TRUE
    )

    requests <- sf::st_transform(requests, 2804)
  }

  return(requests)
}

#' Get selected Environmental Control Board citations from Open Baltimore data portal
#' @description This function uses the RSocrata package to download citations from the Open Baltimore data portal.
#' Citations may be filtered by type, by date, or by neighborhood, City Council District, or Police District.
#' Filtering by multiple criteria or limiting the period of time covered is recommended to avoid a long wait for a large data file to download.
#' @param area An sf object with a 'name' column. If area is provided, the function returns data within the bounding box of the provided area or areas.
#' @param request_type Character vector matching one of the possible \code{violation_types}.
#' @param start_date The start date of the time period during which downloaded violations were cited in the format "YYYY-MM-DD". An end date must be provided if a start date is provided.
#' @param end_date The end date of the time period during which downloaded violations were cited in the format "YYYY-MM-DD".  An start date must be provided if an end date is provided.
#' @param filter_by A character vector with the type of area to filter citations by. Supported area types include neighborhoods ("neighborhood"), City Council districts ("council_district"), and Police Districts ("police_district").
#' @param area_name A character vector with a neighborhood name, Council district number, or Police district name. Filtering by multiple areas or multiple area types is not currently supported.
#' @param geometry If TRUE the service requests are converted to an sf object with a projected CRS (2804). Requests with no coordinates are excluded if TRUE. Defaults to FALSE.
#' @examples
#'
#' \dontrun{
#' ## Get all citations for the Northern Police District for 2018 and 2019
#' get_citations(
#'   filter_by = "police_district",
#'   area_name = "Northern",
#'   start_date = "2018-01-01",
#'   end_date = "2019-12-31"
#' )
#' }
#'
#' \dontrun{
#' ## Get housing citations in Hampden for high grass/weeds between April and October 2019
#' get_citations(
#'   violation_type = "HIGH GRASS AND WEEDS",
#'   filter_by = "neighborhood",
#'   area_name = "Hampden",
#'   start_date = "2019-04-01",
#'   end_date = "2019-10-31",
#'   geometry = TRUE
#' ) ## Return an sf object
#' }
#' @export

get_citations <- function(area,
                          violation_type = NULL,
                          start_date = NULL,
                          end_date = NULL,
                          filter_by = c("neighborhood", "council_district", "police_district"),
                          area_name = NULL,
                          geometry = FALSE) {

  # Check for Open Baltimore API key
  if (Sys.getenv("OPEN_BALTIMORE_API_KEY") != "") {
    key <- Sys.getenv("OPEN_BALTIMORE_API_KEY")
  } else if (is.null(key)) {
    stop("An Open Baltimore API key is required. Obtain one by signing up for an account at https://data.baltimorecity.gov/signup, creating an API key, then providing the key to the `open_baltimore_api_key` function to use it throughout your session.")
  }

  # Check if area_name is provided if filter_by is provided
  if (!missing(filter_by) && is.null(area_name)) {
    stop("A valid area name must be provided to filter by neighborhood, council district, or police district using the filter_by parameter.")
  }

  # Check if sf object provided for area is valid then create a lat/long bounding box variable
  if (!missing(area)) {
    check_area(area)
    area_bbox <- sf::st_bbox(sf::st_transform(area, 4326))
  }

  # Create basic API call
  base <- "https://data.baltimorecity.gov/resource/" # Set base url for Open Baltimore
  resource <- "ywty-nmtg" # Set resource ID for Environmental Citations
  vars <- c(
    "CitationNo",
    "ViolationLocation",
    "Description",
    "ViolationDate",
    "DueDate",
    "Agency",
    "ViolationCodeArticle",
    "ViolationCodeSection",
    "LienCode",
    "FineAmount",
    "Balance",
    "LastPaidAmount",
    "LastPaidDate",
    "TotalPaid",
    "CitationStatus",
    "HearingStatus",
    "Block",
    "Lot",
    "Neighborhood",
    "PoliceDistrict",
    "CouncilDistrict",
    "Location"
  ) # Define list of selected variables # Excluded variables are c("HearingRequestReceivedDate", "HearingDate", "HearTime")
  vars_list <- paste(vars, collapse = ",") # Collapse variable list into comma-separated string
  call <- glue::glue("{base}{resource}.json?$select={vars_list}")

  # Add additional parameters to API call
  if (!is.null(violation_type) | !is.null(start_date) | !is.null(end_date) | !is.null(area_name) | !missing(area)) {
    call <- glue::glue("{call}&$where=")

    # Set extended call strings to NULL
    violation_type_call <- NULL
    date_call <- NULL
    filter_by_area_name_call <- NULL
    area_bbox_call <- NULL

    # Add violation type call after check
    if (!is.null(violation_type)) {
      # Check on the number of violation types provided
      if (length(violation_type) > 1) {
        stop("This function currently supports only one violation type at a time and multiple violation types were provided.")
      } else if (length(violation_type) == 1) {
        violation_type_call <- glue::glue("starts_with(Description, '{violation_type}')")
      }
    }

    # Add start and end date to call after check
    if (!is.null(start_date) && !is.null(end_date)) {
      date_call <- glue::glue("ViolationDate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      end_date <- format(Sys.Date(), "%Y-%m-%d")
      date_call <- glue::glue("ViolationDate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      warning("The provided end date is ignored if a start date is not provided.")
    }

    # Add filter_by and area_name call after check
    if (!is.null(area_name)) {

      # Validate filter_by argument and capitalize area_name
      filter_by <- match.arg(filter_by)
      area_name <- toupper(area_name)

      filter_by_area_name_call <- dplyr::case_when(
        filter_by == "neighborhood" ~ glue::glue("starts_with(Neighborhood, '{area_name}')"),
        filter_by == "council_district" ~ glue::glue("starts_with(CouncilDistrict, '{area_name}')"),
        filter_by == "police_district" ~ glue::glue("starts_with(PoliceDistrict, '{area_name}')")
      )
    }

    # Add area bounding box call after check
    if (!missing(area)) {
      area_bbox_call <- glue::glue("within_box(location, {area_bbox$ymax}, {area_bbox$xmax}, {area_bbox$ymin}, {area_bbox$xmin})")
    }

    # Combine parameter calls
    call <- glue::glue("{call}", paste0(c(violation_type_call, date_call, filter_by_area_name_call, area_bbox_call), collapse = " AND "))
  }

  # Download data from Open Baltimore
  citations <- RSocrata::read.socrata(call, app_token = key)
  citations <- tibble::as_tibble(citations)
  citations <- janitor::clean_names(citations)

  citations <- dplyr::mutate(citations, # Clean variable names
    violation_date = lubridate::date(violation_date),
    due_date = lubridate::date(due_date),
    last_paid_date = lubridate::date(last_paid_date),
    year_violation = lubridate::year(violation_date)
  )

  if (geometry == TRUE) {
    citations <- tidyr::unnest_wider(citations, location_coordinates)
    citations <- dplyr::rename(citations,
      longitude = ...1,
      latitude = ...2
    )

    citations <- sf::st_as_sf(citations,
      coords = c("longitude", "latitude"),
      agr = "constant",
      crs = 4269,
      stringsAsFactors = FALSE,
      remove = TRUE
    )

    citations <- sf::st_transform(citations, 2804)
  }

  return(citations)
}


#' Get selected crime incidents from Open Baltimore data portal
#' @description This function uses the RSocrata package to download BPD Part 1 Victim-Based Crime Data from the Open Baltimore data portal.
#' Crime data may be filtered by crime type, by date, or by neighborhood or Police District. Unlike the \code{get_citations} and \code{get_service_requests} functions this function cannot filter by City Council district.
#' Filtering by multiple criteria or limiting the period of time covered is recommended to avoid a long wait for a large data file to download.
#' @param area An sf object with a 'name' column. If area is provided, the function returns data within the bounding box of the provided area or areas.
#' @param crime_type Character vector matching one of the possible crime types.
#' @param start_date The start date of the time period during which selected crimes occurred in the format "YYYY-MM-DD". An end date must be provided if a start date is provided.
#' @param end_date The end date of the time period during which selected crimes occurred in the format "YYYY-MM-DD".  An start date must be provided if an end date is provided.
#' @param filter_by A character vector with the type of area to filter crimes by. Supported area types include neighborhoods ("neighborhood"), City Council districts ("council_district"), and Police Districts ("police_district").
#' @param area_name A character vector with a the area name. Filtering by multiple areas or multiple area types is not currently supported.
#' @param geometry If TRUE the selected crime data is converted to an sf object with a projected CRS (2804). Requests with no coordinates are excluded if TRUE. Defaults to FALSE.
#' @examples
#'
#' \dontrun{
#' ## Get all reported Part 1 crimes for January 2020 in the Southwest Police District.
#' get_crimes(
#'   start_date = "2020-01-01",
#'   end_date = "2020-01-31",
#'   filter_by = "police_district",
#'   area_name = "SOUTHWEST"
#' )
#' }
#'
#' \dontrun{
#' ## Get all reported burglaries in 2019 in the Federal Hill neighborhood
#' get_crimes(
#'   crime_type = "BURGLARY",
#'   start_date = "2019-01-01",
#'   end_date = "2019-12-31",
#'   filter_by = "neighborhood",
#'   area_name = "FEDERAL HILL"
#' )
#' }
#' @export

get_crimes <- function(area,
                       crime_type = NULL,
                       start_date = NULL,
                       end_date = NULL,
                       filter_by = c("neighborhood", "police_district", "council_district"),
                       area_name = NULL,
                       geometry = FALSE) {

  # Check for Open Baltimore API key
  if (Sys.getenv("OPEN_BALTIMORE_API_KEY") != "") {
    key <- Sys.getenv("OPEN_BALTIMORE_API_KEY")
  } else if (is.null(key)) {
    stop("An Open Baltimore API key is required. Obtain one by signing up for an account at https://data.baltimorecity.gov/signup, creating an API key, then providing the key to the `open_baltimore_api_key` function to use it throughout your session.")
  }

  # Check if area_name is provided if filter_by is provided
  if (!missing(filter_by) && is.null(area_name)) {
    stop("A valid area name must be provided to filter by neighborhood, council district, or police district using the filter_by parameter.")
  }

  # Create basic API call
  base <- "https://data.baltimorecity.gov/resource/" # Set base url for Open Baltimore
  resource <- "wsfq-mvij" # Set resource ID for BPD Part 1 Victim-Based Crime Data
  vars <- c("crimedate", "crimetime", "crimecode", "location", "description", "inside_outside", "weapon", "premise", "post", "district", "neighborhood", "longitude", "latitude") # Define list of selected variables
  vars_list <- paste(vars, collapse = ",") # Collapse variable list into comma-separated string
  call <- glue::glue("{base}{resource}.json?$select={vars_list}")


  # Add additional parameters to API call
  if (!is.null(crime_type) | !is.null(start_date) | !is.null(end_date) | !is.null(area_name)) {
    call <- glue::glue("{call}&$where=")

    # Set extended call strings to NULL
    crime_type_call <- NULL
    date_call <- NULL
    filter_by_area_name_call <- NULL
    area_bbox_call <- NULL

    # Add violation type to call after check
    if (!is.null(crime_type)) {
      # Check on the number of violation types provided
      if (length(crime_type) > 1) {
        stop("This function currently supports only one crime type at a time and multiple crime types were provided.")
      } else if (length(crime_type) == 1) {
        crime_type_call <- glue::glue("Description like '{crime_type}'")
      }
    }

    # Add start and end date to call after check
    if (!is.null(start_date) && !is.null(end_date)) {
      date_call <- glue::glue("crimedate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      end_date <- format(Sys.Date(), "%Y-%m-%d")
      date_call <- glue::glue("crimedate between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      warning("The provided end date is ignored if a start date is not provided.")
    }

    # Add filter_by and area_name to call after check
    if (!is.null(area_name)) {

      # Validate filter_by argument and capitalize area_name
      filter_by <- match.arg(filter_by)
      area_name <- toupper(area_name)

      filter_by_area_name_call <- dplyr::case_when(
        filter_by == "neighborhood" ~ glue::glue("Neighborhood like '{area_name}'"),
        filter_by == "police_district" ~ glue::glue("District like '{area_name}'")
      )
    }

    # Combine parameter calls
    call <- glue::glue("{call}", paste0(c(crime_type_call, date_call, filter_by_area_name_call), collapse = " AND "))
  }

  # Download data from Open Baltimore
  crimes <- RSocrata::read.socrata(call, app_token = key)
  crimes <- tibble::as_tibble(crimes)
  crimes <- janitor::clean_names(crimes)

  crimes <- dplyr::mutate(crimes, # Clean variables
    crimedate = lubridate::date(crimedate),
    crimetime = hms::as_hms(crimetime),
    year_crime = lubridate::year(crimedate)
  )

  crimes <- dplyr::rename(crimes, # Clean variable names
    crime_date = crimedate,
    crime_time = crimetime,
    address = location,
    crime_type = description,
    police_post = post,
    police_district = district # Add year
  )

  if (geometry == TRUE) {
    crimes <- sf::st_as_sf(crimes,
      coords = c("longitude", "latitude"),
      agr = "constant",
      crs = 4269,
      stringsAsFactors = FALSE,
      remove = TRUE
    )

    crimes <- sf::st_transform(crimes, 2804)
  }

  return(crimes)
}



#' Get selected housing permits from Open Baltimore data portal
#' @description This function uses the RSocrata package to download Housing Permits from the Open Baltimore data portal.
#' Requests may be filtered by permit type, by date, or by neighborhood, Council District, or Police District.
#' @param area An sf object with a 'name' column. If area is provided, the function returns data within the bounding box of the provided area or areas.
#' @param request_type Character vector matching one of the possible permits types ("USE", "DEM", "COM").
#' @param start_date The start date of the time period during which permits were issued in the format "YYYY-MM-DD". An end date must be provided if a start date is provided.
#' @param end_date The end date of the time period during which permits were issued in the format "YYYY-MM-DD".  An start date must be provided if an end date is provided.
#' @param filter_by A character vector with the type of area to filter permits by. Supported area types include neighborhoods ("neighborhood"), City Council districts ("council_district"), and Police Districts ("police_district").
#' @param area_name A character vector with a neighborhood name or Police district name. Filtering by multiple areas or multiple area types is not currently supported.
#' @param geometry If TRUE the returned permit data is converted to an sf object with a projected CRS (2804). Permits with no coordinates are excluded if TRUE. Defaults to FALSE.
#' @examples
#'
#' \dontrun{
#' ## Get all demolition permits for Council District 9 between 2015 and 2019
#' get_permits(
#'   permit_type = "DEM",
#'   start_date = "2015-01-01",
#'   end_date = "2019-12-31",
#'   filter_by = "council_district",
#'   area_name = "9"
#' )
#' }
#'
#' \dontrun{
#' ## Get all housing permits for the Mount Washington neighborhood from Dec. 2019 to Jan. 2020
#' get_permits(
#'   start_date = "2019-12-01",
#'   end_date = "2020-01-31",
#'   filter_by = "neighborhood",
#'   area_name = "MOUNT WASHINGTON"
#' )
#' }
#' @export

get_permits <- function(
                        area,
                        permit_type = NULL,
                        start_date = NULL,
                        end_date = NULL,
                        filter_by = c("neighborhood", "police_district", "council_district"),
                        area_name = NULL,
                        geometry = FALSE) {

  # Check for Open Baltimore API key
  if (Sys.getenv("OPEN_BALTIMORE_API_KEY") != "") {
    key <- Sys.getenv("OPEN_BALTIMORE_API_KEY")
  } else if (is.null(key)) {
    stop("An Open Baltimore API key is required. Obtain one by signing up for an account at https://data.baltimorecity.gov/signup, creating an API key, then providing the key to the `open_baltimore_api_key` function to use it throughout your session.")
  }

  # Check if area is provided if filter_by is provided
  if (!missing(filter_by) && is.null(area_name)) {
    stop("A valid area name must be provided to filter by neighborhood, council district, or police district using the filter_by parameter.")
  }

  # Check if sf object provided for area is valid then create a lat/long bounding box variable
  if (!missing(area)) {
    check_area(area)
    area_bbox <- sf::st_bbox(sf::st_transform(area, 4326))
  }

  # Create basic API call
  base <- "https://data.baltimorecity.gov/resource/" # Set base url for Open Baltimore
  resource <- "fesm-tgxf" # Set resource ID for Housing Permits
  vars <- c(
    "permitid",
    "casenum",
    "block",
    "lot",
    "propertyaddress",
    "permitnum",
    "dateissue",
    "permitdescription",
    "cost_est",
    "dateexpire",
    "prop_use",
    "existing_use",
    "neighborhood",
    "policedistrict",
    "councildistrict",
    "location"
  ) # Define list of selected variables
  vars_list <- paste(vars, collapse = ",") # Collapse variable list into comma-separated string
  call <- glue::glue("{base}{resource}.json?$select={vars_list}")


  # Add additional parameters to API call
  if (!is.null(permit_type) | !is.null(start_date) | !is.null(end_date) | !is.null(area_name) | !missing(area)) {
    call <- glue::glue("{call}&$where=")

    # Set extended call strings to NULL
    permit_type_call <- NULL
    date_call <- NULL
    filter_by_area_name_call <- NULL
    area_bbox_call <- NULL

    # Add permit type to call after check
    if (!is.null(permit_type)) {
      # Check on the number of violation types provided
      if (length(permit_type) > 1) {
        stop("This function currently supports only one permit type at a time and multiple permit types were provided.")
      } else if (length(permit_type) == 1) {
        permit_type_call <- glue::glue("starts_with(permitnum, '{permit_type}')")
      }
    }

    # Add start and end date to call after check
    if (!is.null(start_date) && !is.null(end_date)) {
      date_call <- glue::glue("dateissue between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      end_date <- format(Sys.Date(), "%Y-%m-%d")
      date_call <- glue::glue("dateissue between '{start_date}' and '{end_date}'")
    } else if (!is.null(start_date) && is.null(end_date)) {
      warning("The provided end date is ignored if a start date is not provided.")
    }

    # Add filter_by and area_name to call after check
    if (!is.null(area_name)) {

      # Validate filter_by argument and capitalize area_name
      filter_by <- match.arg(filter_by)
      area_name <- toupper(area_name)

      filter_by_area_name_call <- dplyr::case_when(
        filter_by == "neighborhood" ~ glue::glue("starts_with(neighborhood, '{area_name}')"),
        filter_by == "police_district" ~ glue::glue("starts_with(policedistrict, '{area_name}')"),
        filter_by == "council_district" ~ glue::glue("starts_with(councildistrict, '{area_name}')")
      )
    }

    # Add area bounding box call after check
    if (!missing(area)) {
      area_bbox_call <- glue::glue("within_box(location, {area_bbox$ymax}, {area_bbox$xmax}, {area_bbox$ymin}, {area_bbox$xmin})")
    }

    # Combine parameter calls
    call <- glue::glue("{call}", paste0(c(permit_type_call, date_call, filter_by_area_name_call, area_bbox_call), collapse = " AND "))
  }

  # Download data from Open Baltimore
  permits <- RSocrata::read.socrata(call, app_token = key)
  permits <- tibble::as_tibble(permits)
  permits <- janitor::clean_names(permits)

  permits <- dplyr::mutate(permits, # Clean variables
    dateissue = lubridate::date(dateissue),
    cost_est = as.numeric(cost_est),
    dateexpire = lubridate::date(dateexpire),
    issue_year = lubridate::year(dateissue),
    permit_type = stringr::str_sub(permitnum, start = 1, end = 3),
    location_latitude = as.numeric(location_latitude),
    location_longitude = as.numeric(location_longitude)
  )

  permits <- dplyr::select(permits, # Clean variable names
    permit_id = permitid,
    permit_num = permitnum,
    case_num = casenum,
    permit_type,
    issue_date = dateissue,
    issue_year,
    address = propertyaddress,
    block,
    lot,
    expire_date = dateexpire,
    cost_estimate = cost_est,
    proposed_use = prop_use,
    existing_use,
    description = permitdescription,
    neighborhood,
    police_district = policedistrict,
    council_district = councildistrict,
    latitude = location_latitude,
    longitude = location_longitude
  )

  if (geometry == TRUE) {
    permits <- sf::st_as_sf(dplyr::filter(permits, !is.na(latitude)),
      coords = c("longitude", "latitude"),
      agr = "constant",
      crs = 4269,
      stringsAsFactors = FALSE,
      remove = TRUE
    )

    permits <- sf::st_transform(permits, 2804)
  }

  return(permits)
}
