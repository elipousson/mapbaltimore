## code to prepare `real_property` dataset

real_property_pts_local_path <- "~/Downloads/PLAN_ParcelPoints_MDP/BACI/BACI.shp"
real_property_pts <- sf::read_sf(real_property_pts_local_path)

real_property_pts <- real_property_pts %>%
  sf::st_transform(2804)

real_property_pts_key <- real_property_pts %>%
  dplyr::select(acctid, resityp, descciuse, desclu, desccnst, descstyl, descbldg) %>%
  dplyr::mutate(
    descciuse_cat = stringr::str_extract(descciuse, "^[:upper:]+(?=[:space:])"),
    descciuse_subcat = stringr::str_extract(descciuse,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
    desccnst_cat = stringr::str_extract(desccnst, "^[:upper:]+(?=[:space:])"),
    desccnst_subcat = stringr::str_extract(desccnst,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
    descstyl_cat = stringr::str_extract(descstyl, "^[:upper:]+(?=[:space:])"),
    descstyl_subcat = stringr::str_extract(descstyl,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
    descbldg_cat = stringr::str_extract(descbldg, "^[:upper:]+(?=[:space:])"),
    descbldg_subcat = stringr::str_extract(descbldg,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
    descbldg_subcat = dplyr::if_else(descbldg_subcat == "RESTAURANT",
                                     stringr::str_to_title(descbldg_subcat),
                                     descbldg_subcat)
  ) %>%
  dplyr::select(acctid, ct2010, bg2010, address,
                resityp,
                descciuse, descciuse_cat, descciuse_subcat,
                desclu,
                desccnst, desccnst_cat, desccnst_subcat,
                descstyl, descstyl_cat, descstyl_subcat,
                descbldg, descbldg_cat, descbldg_subcat)

# usethis::use_data(real_property_pts, overwrite = TRUE)

# Set path to City of Baltimore Open GIS Data Real Property
# https://gis-baltimore.opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0
# This data is a subset of the statewide data available from the Maryland State Department of Assessment and Taxation.
# NOTE: This data is updated on a rolling basis with sales up through two weeks prior to access.
# The last downloaded date should be included in the data.R file so the currency of the data is clear to users.
# real_property_path <- "https://opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0.geojson"

download.file(real_property_path, "real_property.geojson")

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

real_property <- real_property %>%
  dplyr::mutate(
    ward = stringr::str_trim(ward),
    section = stringr::str_trim(section),
    block = stringr::str_trim(block),
    lot = stringr::str_trim(lot),
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
  ) %>%
  dplyr::left_join(sf::st_drop_geometry(real_property_pts_key), by = "acctid") %>%
  dplyr::select(-check)

usethis::use_data(real_property, overwrite = TRUE)
