data_dir <- function() {
  pkgconfig::get_config(
    "mapbaltimore.data_dir",
    rappdirs::user_cache_dir("mapbaltimore")
  )
}

#' Cache data for mapbaltimore package
#'
#' Cache data to `rappdirs::user_cache_dir("mapbaltimore")`
#'
#' @param data Data to cache.
#' @param filename File name to use for cached file. Defaults to name of data.
#'   If the data is an sf object make sure to include the file type, e.g.
#'   "data.gpkg", supported by `sf::write_sf()`. All other data is written to
#'   rda with `readr::write_rds()`.
#' @param overwrite Logical. Default `FALSE`. If `TRUE`, overwrite any existing
#'   cached files that use the same filename.
#' @details
#'  * Use `cache_msa_streets()` to download and cache street centerline data for
#'   all counties in the Baltimore metropolitan area.
#'  * Use  `cache_edge_of_pavement()` to download and cache edge of pavement
#'   data for Baltimore city.
#' @export
#' @importFrom rappdirs user_cache_dir
#' @importFrom sf st_write
cache_baltimore_data <- function(data = NULL,
                                 filename = NULL,
                                 overwrite = FALSE) {
  if (is.null(filename)) {
    filename <- deparse(substitute(data))
  }

  data_dir <- data_dir()

  if ((filename %in% data(package = "mapbaltimore")$results[, "Item"]) | (filename %in% list.files(system.file("extdata", package = "mapbaltimore")))) {
    cli_abort("This filename matches an existing dataset for {.pkg mapbaltimore}. Please provide a different name.")
  } else if (filename %in% list.files(data_dir)) {
    if (!overwrite) {
      resp <-
        cli_ask(
          text = c(
            "i" = "Data with this same filename already exists in {.path {data_dir}}",
            "*" = "Do you want to overwrite {.file {filename}}?"
          ),
          prompt = "? (Y/n)",
          .envir = rlang::caller_env()
        )

      overwrite <- tolower(resp) %in% tolower(c("", "Y", "Yes", "Yup", "Yep", "Yeah"))
    }

    if (overwrite) {
      cli_inform(c("v" = "Removing existing cached data."))
      file.remove(file.path(data_dir, filename))
    } else {
      cli_abort("{.file {filename}} was not cached.")
    }
  }

  cli_inform(c("v" = "Writing {.file {file.path(data_dir, filename)}}"))
  if ("sf" %in% class(data)) {
    data %>%
      sf::st_write(file.path(data_dir, filename), quiet = TRUE)
  } else {
    check_installed("readr")

    data %>%
      readr::write_rds(file.path(data_dir, filename))
  }
}

#' Cache street centerline data for counties in the Baltimore MSA
#'
#' @name cache_msa_streets
#' @rdname cache_baltimore_data
#' @param url URL
#' @param crs Coordinate reference system.
#' @export
#' @importFrom sf st_bbox st_transform
#' @importFrom glue glue
#' @importFrom purrr map_dfr
#' @importFrom janitor clean_names
#' @importFrom tibble tribble
#' @importFrom dplyr filter left_join
cache_msa_streets <- function(url = "https://geodata.md.gov/imap/rest/services/Transportation/MD_HighwayPerformanceMonitoringSystem/MapServer/2",
                              filename = "baltimore_msa_streets.gpkg",
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                              overwrite = FALSE) {
  check_installed("progress")
  cache_dir_path <- data_dir()

  cli_inform(
    c("v" = "Downloading data from Maryland iMap: {.url {url}}")
  )

  counties <- c("ANNE ARUNDEL", "BALTIMORE CITY", "BALTIMORE", "CARROLL", "HOWARD", "HARFORD", "QUEEN ANNE''S")

  pb <- progress::progress_bar$new(total = length(counties), force = TRUE)

  esri2sf_pb <- function(x) {
    county_sf <- esri2sf::esri2sf(
      url = url,
      bbox = sf::st_bbox(baltimore_msa_counties),
      where = as.character(glue("COUNTY_NAME LIKE '{x}'"))
    )
    cli_inform(c("v" = "{x}"))
    county_sf
  }

  baltimore_msa_streets <-
    purrr::list_rbind(
      purrr::map(
        counties,
        ~ esri2sf_pb(.x)
      )
    )

  baltimore_msa_streets <- sf::st_as_sf(tibble::as_tibble(baltimore_msa_streets))

  clean_msa_streets <- function(x) {
    x <- x %>%
      janitor::clean_names("snake") %>%
      sf::st_transform(crs)

    functional_class_list <- tibble::tribble(
      ~sha_class, ~functional_class, ~functional_class_desc,
      "INT", 1, "Interstate",
      "FWY", 2, "Principal Arterial - Other Freeways and Expressways",
      "PART", 3, "Principal Arterial - Other",
      "MART", 4, "Minor Arterial",
      "COLL", 5, "Major Collector",
      "COLL", 6, "Minor Collector",
      "LOC", 7, "Local"
    )

    x <- x %>%
      dplyr::filter(county_name %in% counties) %>%
      dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))
  }

  baltimore_msa_streets <- baltimore_msa_streets %>%
    clean_msa_streets()

  cache_baltimore_data(
    data = baltimore_msa_streets,
    filename = filename,
    overwrite = overwrite
  )

  remove(baltimore_msa_streets)

  cli_inform(
    c(
      "v" = "{.file {filename}} saved to {.path {cache_dir}}",
      "*" = "Use {.fn {get_area_streets}} with {.arg msa} set to {.code TRUE} to access the data."
    )
  )
}


#' Cache edge of pavement data for Baltimore City
#'
#' @name cache_edge_of_pavement
#' @rdname cache_baltimore_data
#' @importFrom sf st_transform
#' @importFrom dplyr select
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom esri2sf esri2sf
#' @importFrom sf st_transform
#' @importFrom dplyr select
cache_edge_of_pavement <- function(url = "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0",
                                   filename = "edge_of_pavement.gpkg",
                                   crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                                   overwrite = FALSE) {
  cache_dir <- data_dir()

  cli::cli_alert_success("Downloading data from Open Baltimore: {.url {url}}")

  edge_of_pavement <- esri2sf::esri2sf(
    url,
    progress = TRUE
  ) %>%
    sf::st_transform(crs) %>%
    dplyr::select(
      id = OBJECTID_1,
      type = SUBTYPE,
      geometry = geoms
    )

  cache_baltimore_data(
    data = edge_of_pavement,
    filename = filename,
    overwrite = overwrite
  )

  remove(edge_of_pavement)

  cli::cli_alert_success("{.file {filename}} saved to {.path {cache_dir}}")
  cli::cli_alert_info(
    'Use {.fn get_area_data} with {.code data = "edge_of_pavement"} to access the data.'
  )
}


#' Cache property data for Baltimore City
#'
#' @name cache_baltimore_property
#' @rdname cache_baltimore_data
#' @importFrom sf st_transform
#' @importFrom dplyr select
#' @export
#' @importFrom pkgconfig get_config
#' @importFrom cli cli_alert_success cli_alert_info
#' @importFrom getdata get_esri_data bind_block_col
#' @importFrom dplyr mutate if_else select rename left_join
#' @importFrom sfext rename_sf_col relocate_sf_col
#' @importFrom tidyselect any_of
cache_baltimore_property <- function(url = "https://geodata.baltimorecity.gov/egis/rest/services/Housing/dmxOwnership/MapServer/0",
                                     location = NULL,
                                     filename = "baltimore_property.gpkg",
                                     crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                                     overwrite = FALSE) {
  cache_dir <- data_dir()

  cli::cli_alert_success("Downloading data {.url {url}}")

  baltimore_property <- getdata::get_esri_data(
    url = url,
    location = location,
    clean_names = TRUE,
    crs = crs
  )

  baltimore_property <- dplyr::mutate(
    baltimore_property,
    vacant_lot = dplyr::if_else(!is.na(no_imprv), TRUE, FALSE),
    vacant_bldg = dplyr::if_else(!is.na(vbn_issued) & !vacant_lot, TRUE, FALSE)
  )

  baltimore_property <- baltimore_property %>%
    sfext::rename_sf_col() %>%
    sfext::relocate_sf_col() %>%
    dplyr::select(
      -tidyselect::any_of(c("shape_st_length", "shape_st_area"))
    ) %>%
    dplyr::rename(
      agency_code = respagcy,
      neighborhood = neighbor,
      sale_price = salepric,
      sale_date = saledate,
      bldg_num = bldg_no,
      street_dir_prefix = stdirpre,
      street_name = st_name,
      street_type = st_type,
      owner_abb = owner_abbr
    ) %>%
    dplyr::left_join(
      respagency_codes |>
        dplyr::select(
          agency_name = agency_name,
          agency_code = code,
          agency_abb
        ),
      by = "agency_code"
    ) %>%
    dplyr::mutate(
      owner_public = !is.na(owner_abb),
      owner_city = owner_abb %in% c("MCC", "DHCD", "HABC"),
      .after = owner_3
    ) %>%
    getdata::bind_block_col()

  cache_baltimore_data(
    data = baltimore_property,
    filename = filename,
    overwrite = overwrite
  )

  remove(baltimore_property)

  cli::cli_alert_success("{.file {filename}} saved to {.path {cache_dir}}")
  cli::cli_alert_info(
    'Use {.fn get_area_data} with {.code data = "baltimore_property"} to access the data.'
  )
}


# Copyright 2021 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# =================
#
# The following cache utility functions are adapted from the bcpmaps R package:
# https://github.com/bcgov/bcmaps

#' Show the files in the package cache
#'
#' @name show_cached_files
#' @rdname cache_baltimore_data
#' @return
#' `show_cached_files()` returns a tibble with the columns:
#'  - `file`, the name of the file,
#'  - `size_MB`, file size in MB,
#'  - `modified`, date and time last modified
#' @export
show_cached_files <- function() {
  tidy_files(list_cached_files())
}

#' @noRd
tidy_files <- function(files) {
  tbl <- file.info(files)
  tibble::tibble(
    file = stringr::str_extract(rownames(tbl), "(?<=mapbaltimore/).+"),
    MB = tbl$size / 1e6,
    modified = tbl$mtime
  )
}

#' @noRd
list_cached_files <- function() {
  list.files(data_dir(), full.names = TRUE)
}
