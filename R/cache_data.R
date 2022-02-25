data_dir <- function() {
  pkgconfig::get_config("mapbaltimore.data_dir", rappdirs::user_cache_dir("mapbaltimore"))
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
#' @param overwrite Logical. Default FALSE. If TRUE, overwrite any existing cached files that use the same filename.
#' @importFrom rappdirs user_cache_dir
#' @importFrom usethis ui_oops ui_done ui_value
#' @importFrom sf st_write
#' @importFrom readr write_rds
#' @details
#'  * Use `cache_msa_streets()` to download and cache street centerline data for all counties in the Baltimore metropolitan area.
#'  * Use  `cache_edge_of_pavement()` to download and cache edge of pavement data for Baltimore city.
#' @export
#'
cache_baltimore_data <- function(data = NULL,
                                 filename = NULL,
                                 overwrite = FALSE) {
  if (is.null(filename)) {
    filename <- deparse(substitute(data))
  }

  data_dir <- data_dir()

  if ((filename %in% data(package = "mapbaltimore")$results[, "Item"]) | (filename %in% list.files(system.file("extdata", package = "mapbaltimore")))) {
    ui_stop("This filename matches an existing dataset for mapbaltimore. Please provide a different name.")
  } else if (filename %in% list.files(data_dir)) {
    if (!overwrite) {
      overwrite <- ui_yeah(
        "Data with this same filename already exists in {ui_value(data_dir)}
        Do you want to overwrite {ui_value(filename)}?"
      )
    }

    if (overwrite) {
      ui_done("Removing existing cached data.")
      file.remove(file.path(data_dir, filename))
    } else {
      ui_stop("{ui_path(filename)} was not cached.")
    }
  }

  ui_done("Writing {ui_value(file.path(data_dir, filename))}")
  if ("sf" %in% class(data)) {
    data |>
      sf::st_write(file.path(data_dir, filename), quiet = TRUE)
  } else {
    data |>
      readr::write_rds(file.path(data_dir, filename))
  }
}

#' Cache street centerline data for counties in the Baltimore MSA
#'
#' @rdname cache_baltimore_data
#' @importFrom progress progress_bar
#' @importFrom esri2sf esri2sf
#' @importFrom sf st_bbox st_transform
#' @importFrom glue glue
#' @importFrom purrr map_dfr
#' @importFrom janitor clean_names
#' @importFrom tibble tribble
#' @importFrom dplyr filter left_join
#' @importFrom usethis ui_done ui_path ui_field ui_code ui_todo
#' @export
cache_msa_streets <- function(url = "https://geodata.md.gov/imap/rest/services/Transportation/MD_HighwayPerformanceMonitoringSystem/MapServer/2",
                              filename = "baltimore_msa_streets.gpkg",
                              crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                              overwrite = FALSE) {
  cache_dir_path <- data_dir()

  ui_done(
    "Downloading data from Maryland iMap: {ui_path(url)}"
  )

  counties <- c("ANNE ARUNDEL", "BALTIMORE CITY", "BALTIMORE", "CARROLL", "HOWARD", "HARFORD", "QUEEN ANNE''S")

  pb <- progress::progress_bar$new(total = length(counties), force = TRUE)

  esri2sf_pb <- function(x) {
    county_sf <- esri2sf::esri2sf(
      url = url,
      bbox = sf::st_bbox(baltimore_msa_counties),
      where = as.character(glue::glue("COUNTY_NAME LIKE '{x}'"))
    )
    ui_done("{x}")
    county_sf
  }

  baltimore_msa_streets <-
    purrr::map_dfr(
      counties,
      ~ esri2sf_pb(.x)
    )

  clean_msa_streets <- function(x) {
    x <- x |>
      janitor::clean_names("snake") |>
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

    x <- x |>
      dplyr::filter(county_name %in% counties) |>
      dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))
  }

  baltimore_msa_streets <- baltimore_msa_streets |>
    clean_msa_streets()

  cache_baltimore_data(
    data = baltimore_msa_streets,
    filename = filename,
    overwrite = overwrite
  )

  remove(baltimore_msa_streets)

  ui_done("{ui_field(filename)} saved to {ui_path(cache_dir)}")

  ui_todo("Use {ui_code('get_area_streets()')} with {ui_field('msa')} set to {ui_field('TRUE')} to access the data.")
}


#' Cache edge of pavement data for Baltimore City
#'
#' @rdname cache_baltimore_data
#' @importFrom esri2sf esri2sf
#' @importFrom sf st_transform
#' @importFrom dplyr select
#' @export
#'
cache_edge_of_pavement <- function(url = "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0",
                                   filename = "edge_of_pavement.gpkg",
                                   crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                                   overwrite = FALSE) {
  cache_dir <- data_dir()

  ui_done("Downloading data from Open Baltimore: {ui_path(url)}")

  edge_of_pavement <-
    esri2sf::esri2sf(
      url,
      progress = TRUE
    ) |>
    sf::st_transform(crs) |>
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

  ui_done("{ui_field(filename)} saved to {ui_path(cache_dir)}")

  ui_todo("Use {ui_code('get_area_data()')} with {ui_field('data')} set to {ui_field('\"edge_of_pavement\"')} to access the data.")
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
#' @rdname cache_baltimore_data
#'
#' @return
#' `show_cached_files()` returns a tibble with the columns:
#'  - `file`, the name of the file,
#'  - `size_MB`, file size in MB,
#'  - `modified`, date and time last modified
#' @export
show_cached_files <- function() {
  tidy_files(list_cached_files())
}

tidy_files <- function(files) {
  tbl <- file.info(files)
  tibble::tibble(
    file = stringr::str_extract(rownames(tbl), "(?<=mapbaltimore/).+"),
    MB = tbl$size / 1e6,
    modified = tbl$mtime
  )
}

list_cached_files <- function() {
  list.files(data_dir(), full.names = TRUE)
}
