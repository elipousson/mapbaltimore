## code to prepare `real_property` dataset

library(magrittr)

# Set path to City of Baltimore Open GIS Data Real Property
# https://gis-baltimore.opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0
# This data is a subset of the statewide data available from the Maryland State Department of Assessment and Taxation.
# NOTE: This data is updated on a rolling basis with sales up through two weeks prior to access.
# The last downloaded date should be included in the data.R file so the currency of the data is clear to users.
real_property_path <- "https://opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0.geojson"

# download.file(real_property_path, "real_property.geojson")

# Import real_property data from downloaded 'real_property.geojson' file
real_property <- sf::read_sf("real_property.geojson") %>%
  # Clean column names
  janitor::clean_names("snake") %>%
  # Transform to projected CRS
  sf::st_transform(2804)

# NOTE: All data from boundary_data must be loaded before this script is run.
real_property_matched <- real_property %>%
  sf::st_centroid() %>%
  dplyr::select(objectid) %>%
  # Join to neighborhoods
  sf::st_join(
    dplyr::select(neighborhoods, neighborhood = name),
    join = sf::st_within
  ) %>%
  # Join to city council districts
  sf::st_join(
    dplyr::select(council_districts, council_district = name),
    join = sf::st_within
  ) %>%
  # Join to police districts
  sf::st_join(
    dplyr::select(police_districts, police_district = name),
    join = sf::st_within
  ) %>%
  # Join to Community Statistical Areas
  sf::st_join(
    dplyr::select(csas, csa = name),
    join = sf::st_within
  ) %>%
  # Join to U.S. Census Block Group
  sf::st_join(
    dplyr::select(baltimore_block_groups, block_group = geoid),
    join = sf::st_within
  ) %>%
  # Join to U.S. Census Block Group
  sf::st_join(
    dplyr::select(baltimore_tracts, tract = geoid),
    join = sf::st_within
  ) %>%
  sf::st_drop_geometry()

real_property <- real_property %>%
  dplyr::left_join(real_property_matched, by = "objectid")

usethis::use_data(real_property, overwrite = TRUE)
