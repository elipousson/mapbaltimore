## Import U.S. Census 2019 boundary data using tigris

# Set state FIPS for Maryland
state_fips <- 24

# Set county FIPS for Baltimore City
county_fips <- 510

# Set name for Baltimore City
county_name <- "Baltimore City"

# Set projected CRS (NAD83(HARN) / Maryland, meters)
selected_crs <- 2804

library(magrittr)

# Download blocks
baltimore_blocks <- tigris::blocks(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(c(tractce10:name10, aland10:intptlon10))

usethis::use_data(baltimore_blocks, overwrite = TRUE)

# Download block groups
baltimore_block_groups <- tigris::block_groups(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(-c(statefp, countyfp, mtfcc, funcstat))

usethis::use_data(baltimore_block_groups, overwrite = TRUE)

# Download tracts
baltimore_tracts <- tigris::tracts(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(-c(statefp, countyfp, mtfcc, funcstat))

usethis::use_data(baltimore_tracts, overwrite = TRUE)

# Download PUMAs
md_pumas <- tigris::pumas(state = state_fips) %>%
  sf::st_transform(selected_crs)

baltimore_pumas <- md_pumas %>%
  filter(PUMACE10 %in% c("00801", "00802", "00803", "00804", "00805")) %>%
  janitor::clean_names("snake")

usethis::use_data(baltimore_pumas, overwrite = TRUE)

# Download generalized city boundary
baltimore_city <- tigris::county_subdivisions(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    name = namelsad,
    countyfp,
    geoid,
    aland,
    awater,
    intptlat,
    intptlon
  )

usethis::use_data(baltimore_city, overwrite = TRUE)

## Import detailed Baltimore City boundary from ArcGIS FeatureServer layer

maryland_counties_detailed_path <- "https://geodata.md.gov/imap/rest/services/Boundaries/MD_PhysicalBoundaries/FeatureServer/0"
maryland_counties_detailed <- esri2sf::esri2sf(maryland_counties_detailed_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake")

baltimore_city_detailed <- maryland_counties_detailed %>%
  dplyr::filter(county == county_name) %>%
  dplyr::select(
    name = county,
    countyfp = county_fip,
    geometry = geoms
  )

usethis::use_data(baltimore_city_detailed, overwrite = TRUE)

## Import Baltimore City Council Districts from ArcGIS MapServer layer

council_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/City_Council_Districts/MapServer/0"
council_districts <- esri2sf::esri2sf(council_districts_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    name = area_name,
    geometry = geoms
  ) %>%
  dplyr::arrange(name)

usethis::use_data(council_districts, overwrite = TRUE)

# Import legislative districts from ArcGIS FeatureServer layer

baltimore_city_legislative_districts <- c("40", "41", "43", "44A", "45", "46")

legislative_districts_path <- "https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1"
legislative_districts <- esri2sf::esri2sf(legislative_districts_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    name = district,
    geometry = geoms
  ) %>%
  # Filter to Baltimore City districts
  dplyr::filter(name %in% baltimore_city_legislative_districts) %>%
  dplyr::arrange(name)

usethis::use_data(legislative_districts, overwrite = TRUE)

planning_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0"
planning_districts <- esri2sf::esri2sf(planning_districts_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    name = area_name,
    abb = area_abbr,
    geometry = geoms
  ) %>%
  dplyr::arrange(name)

usethis::use_data(planning_districts, overwrite = TRUE)

# Import neighborhood boundaries from iMAP (derived from a data set previously available on Open Baltimore)
# https://opendata.maryland.gov/Society/MD-iMAP-Maryland-Baltimore-City-Neighborhoods/dbbp-8u4u
neighborhoods_path <- "https://opendata.arcgis.com/datasets/fc5d183b20a145009eae8f8b171eeb0d_0.geojson"

neighborhoods <- sf::read_sf(neighborhoods_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    name = label,
    geometry
  ) %>%
  dplyr::arrange(name)

usethis::use_data(neighborhoods, overwrite = TRUE)

# Import Community Statistical Area boundaries from Baltimore City hosted ArcGIS MapServer layer
csas_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/10"

csas <- esri2sf::esri2sf(csas_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    id = objectid,
    name = csa2010,
    geometry = geoms
  ) %>%
  dplyr::arrange(id)

usethis::use_data(csas, overwrite = TRUE)

# Import Police District boundaries from
police_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7"

police_districts <- esri2sf::esri2sf(police_districts_path) %>%
  sf::st_transform(selected_crs) %>%
  sf::st_make_valid() %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    number = objectid,
    name = dist_name,
    geometry = geoms
  ) %>%
  dplyr::arrange(number)

usethis::use_data(police_districts, overwrite = TRUE)

# Import Baltimore City Public School attendance zones from ArcGIS Feature Server layer
bcps_zones_path <- "https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/BCPSZones_2021/FeatureServer/0"

bcps_zones <- esri2sf::esri2sf(bcps_zones_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    program_name = prog_name,
    program_number = prog_no,
    zone_name,
    geometry = geoms
  ) %>%
  dplyr::arrange(program_number)

usethis::use_data(bcps_zones, overwrite = TRUE)

# Download ward maps from KML files from Baltimore City Archives
# https://msa.maryland.gov/bca/wards/index.html

wards_1797_1918_path <- # "/baltimore-city-ward-maps" # Replace with path to folder w/ KML files

wards_1797_1918 <- fs::dir_ls(path = wards_1797_1918_path) %>%
  tibble::tibble(filename = .) %>%
  dplyr::mutate(
    year = as.numeric(stringr::str_sub(filename, -8, -5)),
    data = purrr::map(
      filename,
      ~ sf::read_sf(.) %>%
        sf::st_zm() %>%
        sf::st_transform(selected_crs) %>%
        dplyr::select(
          name = Name,
          geometry
        ) %>%
        dplyr::mutate(number = as.numeric(stringr::str_extract(name, "[:digit:]+")))
    )
  ) %>%
  tidyr::unnest(data) %>%
  dplyr::select(-filename) %>%
  dplyr::arrange(year, number) %>%
  sf::st_as_sf()


usethis::use_data(wards_1797_1918, overwrite = TRUE)
