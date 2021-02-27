## code to prepare `real_property` dataset

# NOTE: There are data quality issues with the city real property data that are not fully resolved.
# 3887 of records from the city real property data have a duplicate account id.
# 0 records in the state real property data have a duplicate account id.
# The state metadata is joined to the city polygon data via the account id.

real_property_pts_local_path <- "~/Downloads/PLAN_ParcelPoints_MDP/BACI/BACI.shp"
real_property_pts <- sf::read_sf(real_property_pts_local_path)

real_property_pts <- real_property_pts %>%
  sf::st_transform(2804)

real_property_pts <- real_property_pts %>%
  dplyr::mutate(
    tradate = lubridate::ymd(tradate)
  ) %>%
  select(c(acctid, ct2010, bg2010, ooi, resityp, address, strtnum, strtdir, strtnam, strttyp, strtsfx, strtunt, addrtyp, city, zipcode, ownname1, ownname2, namekey, ownadd1, ownadd2, owncity, ownstate, ownerzip, ownzip2, premsnum, premsdir, premsnam, premstyp, premcity, premzip, premzip2, section, block, lot, map, grid, parcel, zoning, znchgdat, rzrealdat, ciuse, descciuse, exclass, descexcl, lu, desclu, acres, landarea, luom, width, depth, pfuw, pfus, pflw, pfsp, pfsu, pfic, pfih, recind, yearblt, sqftstrc, strugrad, descgrad, strucnst, desccnst, strustyl, descstyl, strubldg, descbldg, lastinsp, lastassd, assessor, transno1, tradate, considr1, mortgag1, nfmlndvl, nfmimpvl, bldg_story, bldg_units, resi2010, resi2000, resi1990, resiuths, aprtment, trailer, special, other, ptype, sdatwebadr, existing, mdpvdate, legal3, homqlcod, resident, nfmttlvl, sdatdate)) %>%
  select(-c(block, lot, section, assessor))

# real_property_pts_key <- real_property_pts %>%
#  dplyr::mutate(
#    descciuse_cat = stringr::str_extract(descciuse, "^[:upper:]+(?=[:space:])"),
#    descciuse_subcat = stringr::str_extract(descciuse,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
#    desccnst_cat = stringr::str_extract(desccnst, "^[:upper:]+(?=[:space:])"),
#    desccnst_subcat = stringr::str_extract(desccnst,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
#    descstyl_cat = stringr::str_extract(descstyl, "^[:upper:]+(?=[:space:])"),
#    descstyl_subcat = stringr::str_extract(descstyl,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
#    descbldg_cat = stringr::str_extract(descbldg, "^[:upper:]+(?=[:space:])"),
#    descbldg_subcat = stringr::str_extract(descbldg,"(?<=^[:upper:]{2,20}[:space:]{1}).+"),
#    descbldg_subcat = dplyr::if_else(descbldg_subcat == "RESTAURANT",
#                                     stringr::str_to_title(descbldg_subcat),
#                                     descbldg_subcat)
#  ) %>%
#  dplyr::select(acctid, ct2010, bg2010, address,
#                resityp,
#                descciuse, descciuse_cat, descciuse_subcat,
#                desclu,
#                desccnst, desccnst_cat, desccnst_subcat,
#                descstyl, descstyl_cat, descstyl_subcat,
#                descbldg, descbldg_cat, descbldg_subcat)

# usethis::use_data(real_property_pts, overwrite = TRUE)

# Set path to City of Baltimore Open GIS Data Real Property

# This data is a subset of the statewide data available from the Maryland State Department of Assessment and Taxation.
# NOTE: This data is updated on a rolling basis with sales up through two weeks prior to access.
# The last downloaded date should be included in the data.R file so the currency of the data is clear to users.
# https://data.baltimorecity.gov/datasets/real-property-information
# real_property_path <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/Realproperty/MapServer/0"
# real_property <- esri2sf::esri2sf(real_property_path)

# real_property_path <- "https://opendata.arcgis.com/datasets/3b7e32867c5b471683fd4294bfe29e37_0.geojson"
# download.file(real_property_path, "real_property.geojson")

# Import real_property data from downloaded 'real_property.geojson' file
real_property <- sf::read_sf("real_property.geojson")

real_property <- real_property %>%
  # Clean column names
  janitor::clean_names("snake") %>%
  # Transform to projected CRS
  sf::st_transform(2804)

real_property <- real_property %>%
  dplyr::mutate(
    dplyr::across(where(is.character), ~ stringr::str_trim(.x)), # Trim owner, ward, section, block, and lot columns
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
  tidyr::replace_na(list(no_imprv = "N", vacind = "N")) %>%
  naniar::replace_with_na(replace = list(saledate = "00000000"))
dplyr::mutate(
  # Set structure area to 0 when a property has no improvements
  structarea = dplyr::case_when(
    no_imprv == "Y" && structarea != 0 ~ 0,
    TRUE ~ structarea
  ),
  # Parse sale date
  saledate = lubridate::mdy(saledate)
)

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

real_property_merge <- real_property %>%
  dplyr::left_join(real_property_matched, by = "objectid") %>%
  dplyr::left_join(sf::st_drop_geometry(real_property_pts), by = "acctid") # %>%
#  dplyr::select(-check)

real_property <- real_property_merge

usethis::use_data(real_property, overwrite = TRUE)

# Filter real property data to unimproved properties and select limited subset of variables
unimproved_property <- real_property %>%
  dplyr::filter(no_imprv == "Y") %>%
  select(objectid, blocklot, block, lot, ward, section, fulladdr:zipcode, zonecode, neighborhood:tract)

# Write unimproved real property data to extdata folder
sf::write_sf(unimproved_property, "inst/extdata/unimproved_property.gpkg")
# usethis::use_data(unimproved_property, overwrite = TRUE)


# Baltimore MSA Streets ----

md_streets_path <- "https://geodata.md.gov/imap/rest/services/Transportation/MD_HighwayPerformanceMonitoringSystem/MapServer/2"

baltimore_msa_streets <- esri2sf::esri2sf(md_streets_path,
                                          bbox = sf::st_bbox(baltimore_msa_counties)
)

baltimore_msa_streets <- baltimore_msa_streets %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs)

baltimore_msa_streets <- baltimore_msa_streets %>%
  dplyr::filter(county_name %in% c("ANNE ARUNDEL", "BALTIMORE CITY", "BALTIMORE", "CARROLL", "HOWARD", "HARFORD", "QUEEN ANNE'S")) %>%
  dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))


usethis::use_data(baltimore_msa_streets, overwrite = TRUE)

## Edge of pavement (saved to local cache) ----

edge_of_pavement_path <- "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0"

edge_of_pavement_csa <- map_dfr(
  csas_nest$data,
  ~ esri2sf::esri2sf(edge_of_pavement_path, bbox = sf::st_bbox(.x))
)

edge_of_pavement <- edge_of_pavement_csa %>%
  distinct(GlobalID, .keep_all = TRUE) %>%
  select(
    id = OBJECTID_1,
    type = SUBTYPE,
    geometry = geoms
  )

edge_of_pavement <- edge_of_pavement %>%
  sf::st_transform(selected_crs)

sf::write_sf(edge_of_pavement, paste0(rappdirs::user_cache_dir("mapbaltimore"), "/edge_of_pavement.gpkg"))
