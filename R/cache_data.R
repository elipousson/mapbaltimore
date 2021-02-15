#' Cache data for mapbaltimore package
#'
#' mapbaltimore works with several large datasets that exceed
#' the 100 MB file size limit for files on a GitHub repositories.
#' This function downloads three datasets from the city and state
#' ArcGIS Feature Servers using `esri2sf::esri2sf()` and save the
#' data as geopackage files to the cache folder location returned by
#' `rappdirs::user_cache_dir("mapbaltimore")`. These datasets can then
#' be accessed using the `cachedata` parameter of the `get_area_data` function.
#'
#' @param crs Coordinate reference system. Default 2804.
#' @param cache_dir_path Cache directory path. Default is NULL which sets path to `rappdirs::user_cache_dir("mapbaltimore")`
#' @param overwrite Logical. Default FALSE. If TRUE, overwrite any existing cached files that use the same filename.
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_mapbaltimore_data <- function(crs = 2804,
                                    cache_dir_path = NULL,
                                    overwrite = FALSE) {
  warning("cache_mapbaltimore_data downloads data from Baltimore City and Maryland ArcGIS FeatureServer locally for ease of use.
          This script takes a *long* time to complete!")

  # Set cache directory if NULL
  if (is.null(cache_dir_path)) {
    cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")
  }

  cache_real_property(
    cache_dir_path = cache_dir_path,
    crs = crs,
    overwrite = overwrite
  )

  cache_msa_streets(
    cache_dir_path = cache_dir_path,
    crs = crs,
    overwrite = overwrite
  )

  cache_edge_of_pavement(
    cache_dir_path = cache_dir_path,
    crs = crs,
    overwrite = overwrite
  )
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
#' @inheritParams cache_mapbaltimore_data
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_real_property <- function(slug = "real_property",
                                cache_dir_path = NULL,
                                crs = 2804,
                                overwrite = FALSE) {

  # Set cache directory if NULL
  if (is.null(cache_dir_path)) {
    cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")
  }

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(paste0(cache_dir_path, "/", slug, ".gpkg"))) {
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

  # Download and process polygon data from city ----

  # Set path to GeoJSON with filtered
  poly_geojson_path <- "https://opendata.arcgis.com/datasets/3b7e32867c5b471683fd4294bfe29e37_0.geojson"

  # Download data as GeoJSON
  message("Downloading 'Real Property Information' from Open Baltimore:\nhttps://data.baltimorecity.gov/datasets/real-property-information/data")
  download.file(
    poly_geojson_path,
    paste0(cache_dir_path, "/", slug, ".geojson")
  )

  # Import GeoJSON, transform CRS, and clean column names
  message("Importing data from Open Baltimore.")
  real_property <- sf::read_sf(paste0(cache_dir_path, "/", slug, ".geojson")) %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake")

  message("Cleaning data from Open Baltimore.")
  real_property <- real_property %>%
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
      acctid = stringr::str_trim(acctid),
      # Replace missing no_imprv and vacind values
      no_imprv = tidyr::replace_na(no_imprv, "N"),
      vacind = tidyr::replace_na(vacind, "N"),
      # Set structure area to 0 when a property has no improvements
      structarea = dplyr::case_when(
        no_imprv == "Y" && structarea > 0 ~ as.integer(0),
        TRUE ~ structarea
      )
    ) %>%
    # Replace missing sale dates with actual NA values
    naniar::replace_with_na(replace = list(saledate = "00000000")) %>%
    dplyr::mutate(
      # Parse sale date
      saledate = lubridate::mdy(saledate, quiet = TRYE)
    )

  # Download and process point data from state ----

  message("Downloading 'Maryland Property Data - Parcel Points' (for Baltimore City) from Maryland iMap:\nhttps://data.imap.maryland.gov/datasets/maryland-property-data-parcel-points/data?where=jurscode%20%3D%20%27BACI%27")
  slug_suffix <- "_pts"
  pts_geojson_path <- "https://opendata.arcgis.com/datasets/042c633a05df48fa8561f245fccdd750_0.geojson?where=jurscode%20%3D%20'BACI'"
  download.file(
    pts_geojson_path,
    paste0(cache_dir_path, "/", slug, slug_suffix, ".geojson")
  )

  message("Importing data from Maryland iMap.")
  real_property_pts <- sf::read_sf(paste0(cache_dir_path, "/", slug, slug_suffix, ".geojson")) %>%
    sf::st_transform(crs) %>%
    janitor::clean_names("snake")

  message("Cleaning data from Maryland iMap.")
  real_property_pts <- real_property_pts %>%
    dplyr::mutate(
      tradate = lubridate::ymd(tradate)
    ) %>%
    select(-c(block, lot, section, assessor))

  # Join data and clean up left over files. ----

  # Join polygns from city to Maryland iMap point data
  message("Joining data from Open Baltimore and Maryland iMap.\nCity real property data with polygon boundaries are matched to state property information by tax account identification numbers.")
  real_property <- real_property %>%
    dplyr::left_join(sf::st_drop_geometry(real_property_pts), by = "acctid")

  # Write data to cache as geopackage file
  message("Writing combined real property data to cache as a geopackage file.\nData can now be accessed with the get_area_property() function.")
  real_property %>%
    sf::st_write(paste0(cache_dir_path, "/", slug, ".gpkg"))

  # Remove downloaded GeoJSON file
  message("Removing cached GeoJSON files.")
  file.remove(paste0(cache_dir_path, "/", slug, ".geojson"))
  file.remove(paste0(cache_dir_path, "/", slug, slug_suffix, ".geojson"))

  # Remove real property data from memory
  message("Removing imported data from memory.")
  remove(real_property)
  remove(real_property_pts)
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
#' @inheritParams cache_mapbaltimore_data
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_msa_streets <- function(slug = "baltimore_msa_streets",
                              cache_dir_path = NULL,
                              crs = 2804,
                              overwrite = FALSE) {

  # Set cache directory if NULL
  if (is.null(cache_dir_path)) {
    cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")
  }

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(paste0(cache_dir_path, "/", slug, ".gpkg"))) {
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

  baltimore_msa_streets <- baltimore_msa_streets %>%
    dplyr::filter(county_name %in% msa_counties) %>%
    dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))

  # Write data to cache as geopackage file
  message("Writing data to cache as a geopackage file.\nData can now be accessed with the get_area_streets(msa = TRUE) function.")
  baltimore_msa_streets %>%
    sf::st_write(paste0(cache_dir_path, "/", slug, ".gpkg"))

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
#' @inheritParams cache_mapbaltimore_data
#' @importFrom rappdirs user_cache_dir
#' @export
#'
cache_edge_of_pavement <- function(slug = "edge_of_pavement",
                                   cache_dir_path = NULL,
                                   crs = 2804,
                                   overwrite = FALSE) {

  # Set cache directory if NULL
  if (is.null(cache_dir_path)) {
    cache_dir_path <- rappdirs::user_cache_dir("mapbaltimore")
  }

  # Require overwrite = TRUE to continue if file exists in cache dirctory
  if (!overwrite && file.exists(paste0(cache_dir_path, "/", slug, ".gpkg"))) {
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

  url <- "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0"

  message(paste0("Downloading data from Open Baltimore:\n", url))

  edge_of_pavement <- map_dfr(
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
    sf::st_write(paste0(cache_dir_path, "/", slug, ".gpkg"))

  # Remove data from memory
  message("Removing imported data from memory.")
  remove(edge_of_pavement)
}
