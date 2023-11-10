selected_crs <- 2804

# Import Police District boundaries

# FIXME: This URL previously served the legacy boundaries but has been replaced with the current boundaries
# Locate a new URL for the legacy boundaries so this code can still generate the older police_districts object
police_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7"

police_districts_legacy_source <- esri2sf::esri2sf(police_districts_path, crs = selected_crs)

police_districts_legacy_source %>%
  sf::st_make_valid() %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    number = objectid,
    name = dist_name,
    geometry = geoms
  ) %>%
  dplyr::arrange(number)

usethis::use_data(police_districts, overwrite = TRUE)

# Alternate URL
# "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7"
url <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/Police_District/FeatureServer/0"

police_districts_source <- esri2sf::esri2sf(url, crs = selected_crs)

police_districts_2023 <- police_districts_source |>
  janitor::clean_names("snake") |>
  dplyr::select(
    id = district_number,
    name = dist_name,
    name_abb = dist_abbr,
    geometry = geoms
  ) |>
  dplyr::arrange(id)

usethis::use_data(police_districts_2023, overwrite = TRUE)
