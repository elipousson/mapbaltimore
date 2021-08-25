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
#' @export
#'
cache_baltimore_data <- function(data = NULL,
                                 filename = NULL,
                                 overwrite = FALSE) {

  cache_dir <- rappdirs::user_cache_dir("mapbaltimore")

  if (is.null(filename)) {
    filename <- deparse(substitute(v1))
  }

  if ((filename %in% data(package = "mapbaltimore")$results[, "Item"]) | (filename %in% list.files(system.file("extdata", package = "mapbaltimore")))) {
    stop("This filename matches an existing dataset for mapbaltimore. Please provide a different name.")
  } else if  (filename %in% list.files(cache_dir)) {
    if (!overwrite) {
      stop("Data matching this filename and dns is already located in the cache directory. Please provide a different filename or dns.")
    } else {
      warning("Removing existing cached data.")
      file.remove(file.path(cache_dir, filename))
    }
  }

  if ("sf" %in% class(data)) {
    data |>
      sf::st_write(file.path(cache_dir, filename))
  } else {
    data |>
      readr::write_rds(file.path(cache_dir, filename))
  }

}

#' Cache real property data for Baltimore City
#'
#' mapbaltimore works with several large datasets that exceed
#' the 100 MB file size limit for files on a GitHub repositories.
#' This function downloads the real property data from the city
#' ArcGIS Feature Servers using `esri2sf::esri2sf()` and saves the
#' data as geopackage files to the cache folder location returned by
#' `rappdirs::user_cache_dir("mapbaltimore")`. This datasets can then
#' be accessed using the `cachedata` parameter of the `get_area_data` function.
#'
#' @param slug Name to use for cached file. Default to "real_property"
#' @export
#' @importFrom rappdirs user_cache_dir
#' @importFrom sf read_sf st_transform
#' @importFrom lubridate mdy ymd
#' @importFrom naniar replace_with_na
#' @importFrom tidyr replace_na
#' @importFrom utils download.file
cache_real_property <- function(slug = "real_property",
                                crs = 2804,
                                overwrite = FALSE) {

  stop("This function is not currently supported.")
 cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(file.path(cache_dir_path, paste0(slug, ".gpkg")))) {
    return(
      warning(
        paste0(
          slug, ".gpkg is already present in the 'mapbaltimore' cache directory:\n",
          cache_dir_path,
          "\nUse overwrite = TRUE to replace this existing file."
        )
      )
    )
  }

  # message("Due to the large size of the real property data files,\ncaching this data takes several minutes.")

  # Download and process parcel data from city ----

  message("Importing 'Parcel' polygon data from Open Baltimore:\nhttps://data.baltimorecity.gov/datasets/baltimore::parcel-1/about")

  parcel_path <- "https://opendata.arcgis.com/datasets/85767997c73d4b9292415f2661466273_0.geojson"

  parcels <- sf::read_sf(parcel_path) %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake") %>%
    dplyr::select(property_id = pin, geometry)

  message("Importing 'Real Property Information' data from Open Baltimore:\nhttps://data.baltimorecity.gov/datasets/baltimore::real-property-information/about")

  real_property_info_path <- "https://opendata.arcgis.com/datasets/f6d90c82a6154e5a8d77708243934ad6_0.geojson"

  real_property_info <- sf::read_sf(real_property_info_path) %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake") %>%
    dplyr::rename(section = sect, coords = location) %>%
    dplyr::select(-c(esri_oid)) %>%
    dplyr::mutate(
      # Trim owner, ward, section, block, and lot columns
      dplyr::across(where(is.character), ~ stringr::str_trim(.x)),
      # Pad ward, section, block and lot to make acctid
      ward = stringr::str_pad(ward, width = 2, side = "left", pad = "0"),
      section = stringr::str_sub(section, start = 1, end = 2),
      block = dplyr::if_else(
        stringr::str_detect(block, "[:upper:]$"),
        stringr::str_pad(block, width = 5, side = "left", pad = "0"),
        stringr::str_pad(block, width = 4, side = "left", pad = "0")
      ),
      lot = dplyr::if_else(
        stringr::str_detect(lot, "[:upper:]"),
        stringr::str_pad(lot, width = 4, side = "left", pad = "0"),
        stringr::str_pad(lot, width = 3, side = "left", pad = "0")
      ),
      acctid = dplyr::if_else(
        stringr::str_detect(block, "[:upper:]$"),
        paste0("03", ward, section, block, lot),
        paste0("03", ward, section, block, " ", lot)
      ),
      acctid = stringr::str_trim(acctid)
    )

  # real_property_joined <-

  parcels <- parcels %>%
    dplyr::left_join(
      sf::st_drop_geometry(real_property_info),
      by = "property_id"
      )

  hcd_real_property_path <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxOwnership/MapServer/0"
  hcd_real_property <- esri2sf::esri2sf(hcd_real_property_path)

  hcd_real_property <- hcd_real_property %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake") %>%
    dplyr::mutate(
      # Trim owner, ward, section, block, and lot columns
      dplyr::across(where(is.character), ~ stringr::str_trim(.x)),
      block = dplyr::if_else(
        stringr::str_detect(block, "[:upper:]$"),
        stringr::str_pad(block, width = 5, side = "left", pad = "0"),
        stringr::str_pad(block, width = 4, side = "left", pad = "0")
      ),
      lot = dplyr::if_else(
        stringr::str_detect(lot, "[:upper:]"),
        stringr::str_pad(lot, width = 4, side = "left", pad = "0"),
        stringr::str_pad(lot, width = 3, side = "left", pad = "0")
      )
    )

  hcd_real_property <- hcd_real_property %>%
    select(
      block,
      lot,
      blocklot,
      full_address = fulladdr,
      bldg_number = bldg_no,
      fraction,
      span_number = span_num,
      street_dirpre = stdirpre,
      street_name = st_name,
      street_type = st_type,
      zip_code,
      zip_code_ext = extd_zip,
      permhome,
      no_imprv,
      dhcd_use = dhcduse1,
      resp_agency = respagcy,
      neighborhood_hcd = neighbor
    ) %>%
    sf::st_drop_geometry()

  hcd_real_property_joined <- parcels %>%
    left_join(sf::st_drop_geometry(hcd_real_property), by = c("block", "lot"))


  # Download and process point data from state ----
  message("Downloading 'Maryland Property Data - Parcel Points' (for Baltimore City) from Maryland iMap:\nhttps://data.imap.maryland.gov/datasets/maryland-property-data-parcel-points/data?where=jurscode%20%3D%20%27BACI%27")
  slug_suffix <- "_pts"
  file_name <- paste0(slug, slug_suffix, ".geojson")

  parcel_pts_path <- "https://opendata.arcgis.com/datasets/042c633a05df48fa8561f245fccdd750_0.geojson?where=jurscode%20%3D%20'BACI'"
  download.file(
    parcel_pts_path,
    file.path(cache_dir_path, file_name)
  )

  message("Importing data from Maryland iMap.")

  # path <- "PLAN_ParcelPoints_MDP/BACI/BACI.shp"
  parcel_pts <- sf::read_sf(file.path(cache_dir_path, file_name)) %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake")

  message("Cleaning data from Maryland iMap.")
  parcel_pts <- parcel_pts %>%
    dplyr::mutate(
      tradate = lubridate::ymd(tradate)
    ) %>%
    dplyr::select(-c(block, lot, section))

  # Join data and clean up left over files. ----

  # Join polygns from city to Maryland iMap point data
  message("Joining data from Open Baltimore and Maryland iMap.\nCity real property data with polygon boundaries are matched to state property information by tax account identification numbers.")
  real_property <- parcels %>%
    dplyr::left_join(sf::st_drop_geometry(parcel_pts), by = "acctid")

  real_property <- real_property %>%
    left_join(hcd_real_property, by = c("block", "lot"))

  # Write data to cache as geopackage file
  message("Writing combined real property data to cache as a geopackage file.\nData can now be accessed with the get_area_property() function.")
  real_property %>%
    sf::st_write(file.path(cache_dir_path, paste0(slug, ".gpkg")))

  # Remove downloaded GeoJSON file
  message("Removing cached GeoJSON file from Maryland iMap.")
  file.remove(paste0(cache_dir_path, slug, slug_suffix, ".geojson"))

  # Remove real property data from memory
  message("Removing imported data from memory.")
  remove(real_property_info)
  remove(parcels)
  remove(parcel_pts)
  remove(real_property)
}


#' Cache street centerline data for counties in the Baltimore MSA
#'
#' mapbaltimore works with several large datasets that exceed
#' the 100 MB file size limit for files on a GitHub repositories.
#' This function downloads the street centerline data from the state
#' ArcGIS Feature Servers using `esri2sf::esri2sf()` and saves the
#' data as geopackage files to the cache folder location returned by
#' `rappdirs::user_cache_dir("mapbaltimore")`. This datasets can then
#' be accessed using the `cachedata` parameter of the `get_area_data` function.
#'
#' @param slug Name to use for cached file. Default to "baltimore_msa_streets"
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_msa_streets <- function(slug = "baltimore_msa_streets",
                              crs = 2804,
                              overwrite = FALSE) {

 stop("This function is not currently supported.")
 cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(file.path(cache_dir_path, slug, ".gpkg"))) {
    return(
      warning(
        paste0(
          slug, ".gpkg is already present in the 'mapbaltimore' cache directory:\n",
          cache_dir_path,
          "\nUse overwrite = TRUE to replace this existing file."
        )
      )
    )
  }

  url <- "https://geodata.md.gov/imap/rest/services/Transportation/MD_HighwayPerformanceMonitoringSystem/MapServer/2"

  message(paste0("Downloading data from Maryland iMap:\n", url))
  baltimore_msa_streets <- esri2sf::esri2sf(
    url = url,
    bbox = sf::st_bbox(baltimore_msa_counties)
  )

  message("Cleaning data from Maryland iMap.")
  baltimore_msa_streets <- baltimore_msa_streets %>%
    janitor::clean_names("snake") %>%
    sf::st_transform(crs)

  msa_counties <- c("ANNE ARUNDEL", "BALTIMORE CITY", "BALTIMORE", "CARROLL", "HOWARD", "HARFORD", "QUEEN ANNE'S")


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

  baltimore_msa_streets <- baltimore_msa_streets %>%
    dplyr::filter(county_name %in% msa_counties) %>%
    dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))

  # Write data to cache as geopackage file
  message("Writing data to cache as a geopackage file.\nData can now be accessed with the get_area_streets(msa = TRUE) function.")
  baltimore_msa_streets %>%
    sf::st_write(paste0(cache_dir_path, slug, ".gpkg"))

  # Remove data from memory
  message("Removing imported data from memory.")
  remove(baltimore_msa_streets)
}


#' Cache edge of pavement data for Baltimore City
#'
#' mapbaltimore works with several large datasets that exceed
#' the 100 MB file size limit for files on a GitHub repositories.
#' This function downloads the edge of pavement data from the city
#' ArcGIS Feature Servers using `esri2sf::esri2sf()` and saves the
#' data as geopackage files to the cache folder location returned by
#' `rappdirs::user_cache_dir("mapbaltimore")`. This datasets can then
#' be accessed using the `cachedata` parameter of the `get_area_data` function.
#'
#' @param slug Name to use for cached file. Default to "edge_of_pavement"
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_edge_of_pavement <- function(slug = "edge_of_pavement",
                                   cache_dir_path = NULL,
                                   crs = 2804,
                                   overwrite = FALSE) {

  stop("This function is not currently supported.")

  # Set cache directory if NULL
  if (is.null(cache_dir_path)) {
    cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")

    if (Sys.info()["sysname"] == "Windows") {
      cache_dir_path <- paste0(cache_dir_path, "\\")
    } else {
      cache_dir_path <- paste0(cache_dir_path, "/")
    }
  }

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(paste0(cache_dir_path, slug, ".gpkg"))) {
    return(
      warning(
        paste0(
          slug, ".gpkg is already present in the 'mapbaltimore' cache directory:\n",
          cache_dir_path,
          "\nUse overwrite = TRUE to replace this existing file."
        )
      )
    )
  }

  csas_nest <- csas %>%
    dplyr::nest_by(name)

  edge_of_pavement_path <- "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0"

  message(paste0("Downloading data from Open Baltimore:\n", edge_of_pavement_path))

  edge_of_pavement <- purrr::map_dfr(
    csas_nest$data,
    ~ esri2sf::esri2sf(edge_of_pavement_path, bbox = sf::st_bbox(.x))
  ) %>%
    sf::st_transform(crs) %>%
    dplyr::distinct(GlobalID, .keep_all = TRUE) %>%
    dplyr::select(
      id = OBJECTID_1,
      type = SUBTYPE,
      geometry = geoms
    )

  # Write data to cache as geopackage file
  message(paste0("Writing data to cache as a geopackage file.\nData can now be accessed with the get_area_data(cachedata = '", slug, "') function."))

  edge_of_pavement %>%
    sf::st_write(paste0(cache_dir_path, slug, ".gpkg"))

  # Remove data from memory
  message("Removing imported data from memory.")
  remove(edge_of_pavement)
}
