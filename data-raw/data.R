# Set state FIPS for Maryland
state_fips <- 24

# Set county FIPS for Baltimore City
county_fips <- 510

# Set name for Baltimore City
county_name <- "Baltimore City"

# Set projected CRS (NAD83(HARN) / Maryland, meters)
selected_crs <- 2804

# Nested CSAs are used to download larger datasets in portions
csas_nest <- csas %>%
  nest_by(name)


md_counties <- tigris::counties(state = state_fips)

baltimore_msa_counties <- md_counties %>%
  janitor::clean_names("snake") %>%
  dplyr::filter(name %in% c("Baltimore", "Anne Arundel", "Carroll", "Harford", "Howard", "Queen Anne's")) %>%
  sf::st_transform(selected_crs)

usethis::use_data(baltimore_msa_counties, overwrite = TRUE)

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
    id = area_name,
    geometry = geoms
  ) %>%
  dplyr::mutate(
    id = as.character(id),
    name = paste0("District ", id)
  )

usethis::use_data(council_districts, overwrite = TRUE)

## Baltimore City Legislative Districts ----

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
  dplyr::mutate(
    id = name,
    name = paste0("District ", name),
    label = paste0("Maryland House of Delegates ", name)
  ) %>%
  # Filter to Baltimore City districts
  dplyr::filter(id %in% baltimore_city_legislative_districts) %>%
  dplyr::arrange(id)

usethis::use_data(legislative_districts, overwrite = TRUE)

## U.S. Congressional Districts ----

# Import congressional districts

md_congressional_districts <- tigris::congressional_districts() %>%
  dplyr::filter(STATEFP == state_fips)

congressional_district_names <- tibble::tribble(
  ~CD116FP, ~label, ~name,
  "02", "Maryland's 2nd congressional district", "2nd District",
  "03", "Maryland's 3rd congressional district", "3rd District",
  "07", "Maryland's 7th congressional district", "7th District"
)

congressional_districts <- md_congressional_districts %>%
  sf::st_transform(selected_crs) %>%
  sf::st_join(baltimore_city) %>%
  dplyr::filter(!is.na(name)) %>%
  dplyr::select(-c(name:intptlon)) %>%
  dplyr::left_join(congressional_district_names, by = "CD116FP") %>%
  janitor::clean_names("snake")

usethis::use_data(congressional_districts, overwrite = TRUE)

planning_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0"
planning_districts <- esri2sf::esri2sf(planning_districts_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::mutate(
    name = paste0(area_name, " Planning District")
  ) %>%
  dplyr::select(
    id = area_name,
    name,
    abb = area_abbr,
    geometry = geoms
  ) %>%
  dplyr::arrange(id)

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

# Import Baltimore City Public School 2020-2021 attendance zones from ArcGIS Feature Server layer
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

# 2020-2021 program sites
bcps_programs_path <- "https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2021_Programs/FeatureServer/0"

bcps_programs <- esri2sf::esri2sf(bcps_programs_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    program_name = prog_short,
    program_number = prog_no,
    type = mgmnt_type,
    category = categorization,
    zone_name,
    geometry = geoms
  ) %>%
  dplyr::arrange(program_number)

usethis::use_data(bcps_programs, overwrite = TRUE)

# Download ward maps from KML files from Baltimore City Archives
# https://msa.maryland.gov/bca/wards/index.html

# wards_1797_1918_path <- "/baltimore-city-ward-maps" # Replace with path to folder w/ KML files

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

## Parks ----

# Set path to city parks hosted ArcGIS MapServer layer
parks_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2"

# Import parks data with esri2sf package
parks <- esri2sf::esri2sf(parks_path) %>%
  sf::st_transform(selected_crs) %>% # Transform to projected CRS
  sf::st_make_valid() %>% # Make valid to avoid "Ring Self-intersection" error
  janitor::clean_names("snake") %>% # Clean column names
  dplyr::select(name, id = park_id, address, name_alt, operator = bcrp, geometry = geoms) %>% # Select relevant columns
  dplyr::mutate(
    operator = dplyr::if_else(operator == "Y", "Baltimore City Department of Recreation and Parks", "Other"),
    area = units::set_units(sf::st_area(geometry), "acres")
  )

usethis::use_data(parks, overwrite = TRUE)


## Park districts ----

park_districts <- esri2sf::esri2sf("https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/AGOL_BCRP_MGMT_20181220/FeatureServer/3")

park_districts <- park_districts %>%
  dplyr::select(
    name = AREA_NAME,
    geometry = geoms
  )
sf::st_transform(selected_crs)

usethis::use_data(park_districts, overwrite = TRUE)

esri_sources[slug == "edge_of_pavement"]$source_url


# Water ----

baltimore_water_path <- "https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/7"

baltimore_water <- esri2sf::esri2sf(baltimore_water_path)

baltimore_water <- baltimore_water %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804) %>%
  dplyr::select(
    name,
    type,
    subtype,
    symbol,
    water,
    geometry = geoms
  )

usethis::use_data(baltimore_water, overwrite = TRUE)


##  Baltimore MIHP ----

# Import from iMap
# https://data.imap.maryland.gov/datasets/maryland-inventory-historic-properties-maryland-inventory-of-historic-properties/data
mihp_path <- "https://geodata.md.gov/imap/rest/services/Historic/MD_InventoryHistoricProperties/FeatureServer/0"

# Import baltimore_mihp data with esri2sf package
mihp <- esri2sf::esri2sf(mihp_path)

# Clean column names
mihp <- janitor::clean_names(mihp, "snake")

# Filter to properties in Baltimore City
baltimore_mihp <- dplyr::filter(mihp, county == "Baltimore City" | county == "BaltCity,BaltCo")

# Transform to projected CRS
baltimore_mihp <- sf::st_transform(baltimore_mihp, 2804)

# Rename columns
baltimore_mihp <- dplyr::rename(baltimore_mihp,
                                mihp_id = mihpid,
                                property_id = propertyid,
                                mihp_num = mihpno,
                                name = nam,
                                alternate_name = a,
                                full_address = fulladdr
)

# Remove unnecessary columns
baltimore_mihp <- dplyr::select(
  baltimore_mihp,
  -c(objectid, class)
)

usethis::use_data(baltimore_mihp, overwrite = TRUE)


## Import U.S. Census 2019 boundary data using tigris

# Download blocks ----
baltimore_blocks <- tigris::blocks(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(c(tractce10:name10, aland10:intptlon10))

usethis::use_data(baltimore_blocks, overwrite = TRUE)

# Download block groups ----
baltimore_block_groups <- tigris::block_groups(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(-c(statefp, countyfp, mtfcc, funcstat))

usethis::use_data(baltimore_block_groups, overwrite = TRUE)

# Download tracts ----
baltimore_tracts <- tigris::tracts(state = state_fips, county = county_fips) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(-c(statefp, countyfp, mtfcc, funcstat))

usethis::use_data(baltimore_tracts, overwrite = TRUE)

# Download PUMAs ----
md_pumas <- tigris::pumas(state = state_fips) %>%
  sf::st_transform(selected_crs)

baltimore_pumas <- md_pumas %>%
  dplyr::filter(PUMACE10 %in% c("00801", "00802", "00803", "00804", "00805")) %>%
  janitor::clean_names("snake")

usethis::use_data(baltimore_pumas, overwrite = TRUE)

# Weighted neighborhood-tract crosswalk ----

# Make a weighted dataframe of neighborhoods and tracts for use with the cwi package
# Based on https://github.com/CT-Data-Haven/cwi/blob/master/data-raw/make_neighborhood_shares.R

library(mapbaltimore)

# Make crosswalk dataframe for blocks and tracts
blocks_xwalk <- baltimore_blocks %>%
  sf::st_drop_geometry() %>%
  dplyr::left_join(sf::st_drop_geometry(baltimore_tracts), by = c("tractce10" = "tractce")) %>%
  dplyr::select(block = geoid10, tract = geoid, block_name = name10, tract_name = namelsad)

blocks_pop <- tidycensus::get_decennial(
  geography = "block",
  variables = "H013001", # Total households
  state = "24",
  county = "510",
  year = 2010,
  sumfile = "sf1",
  geometry = TRUE
) %>%
  janitor::clean_names()

# neighborhoods_tracts ----

neighborhoods_tracts <- blocks_pop %>%
  dplyr::left_join(blocks_xwalk, by = c("geoid" = "block")) %>%
  dplyr::select(geoid, tract, value, -name) %>%
  sf::st_transform(2804) %>%
  sf::st_join(neighborhoods, left = FALSE, largest = TRUE) %>%
  dplyr::filter(value > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, name) %>%
  dplyr::summarise(households = sum(value)) %>%
  dplyr::mutate(weight = round(households / sum(households), digits = 2)) %>%
  dplyr::ungroup() %>%
  dplyr::rename(geoid = tract) %>%
  dplyr::mutate(tract = stringr::str_sub(geoid, -6)) %>%
  dplyr::select(name, geoid, tract, weight)

usethis::use_data(neighborhoods_tracts, overwrite = TRUE)



# Set projected CRS (NAD83(HARN) / Maryland, meters)
selected_crs <- 2804

# NDC Projects ----

ndc_projects_path <- "https://services5.arcgis.com/o5xMIospaZLivipF/ArcGIS/rest/services/NDC_Projects_1968to2016/FeatureServer/0"

ndc_projects <- esri2sf::esri2sf(ndc_projects_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake")

ndc_projects <- ndc_projects %>%
  dplyr::select(
    ndc_office = office,
    ndc_program = program,
    project_id = ndc_id,
    project_name = proj_name,
    project_type = proj_type,
    project_status = proj_status,
    start_date = date_open,
    end_date = date_end,
    client_name = client_org,
    address = address,
    city = town,
    state = state,
    zip_code,
    geometry = geoms
  ) %>%
  naniar::replace_with_na(replace = list(start_date = "N/A")) %>%
  naniar::replace_with_na(replace = list(end_date = "N/A")) %>%
  naniar::replace_with_na(replace = list(zip_code = "0")) %>%
  dplyr::mutate(
    start_year = stringr::str_sub(start_date, start = -4),
    end_year = stringr::str_sub(end_date, start = -4)
  )

# TODO: The NDC project data is not included in the package documentation yet
usethis::use_data(ndc_projects, overwrite = TRUE)


# Explore Baltimore Heritage stories ----

explore_baltimore <- jsonlite::fromJSON("https://explore.baltimoreheritage.org/items/browse?output=mobile-json")

explore_baltimore <- explore_baltimore$items %>%
  dplyr::mutate(
    url = paste0("https://explore.baltimoreheritage.org/items/show/", id)
  )

explore_baltimore <- sf::st_as_sf(explore_baltimore,
                                  coords = c("longitude", "latitude"),
                                  agr = "constant",
                                  crs = 4269,
                                  stringsAsFactors = FALSE,
                                  remove = TRUE
)

explore_baltimore <- sf::st_transform(explore_baltimore, 2804)

usethis::use_data(explore_baltimore, overwrite = TRUE)


selected_crs <- 2804

## Housing Market Typology ----

hmt_2017_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/25"

hmt_2017 <- esri2sf::esri2sf(hmt_2017_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) # Transform to projected CRS

# https://planning.baltimorecity.gov/sites/default/files/FINAL_HMT2017_DataSeries_0518.pdf
hmt_2017 <- hmt_2017 %>%
  dplyr::select(
    geoid = bg, # all variables are derived from 2015 to 2017 data ()
    geoid_part = geo_i_dw_splt,
    cluster = mva17hrd_cd,
    median_sales_price = msp1517eo,
    sales_price_variation = vsp1517rsf, # Baltimore City real estate transactions 2015q3-2017q2
    num_sales = csp1517rsf, #
    num_foreclosure_filings = nfcl1517, # Baltimore City Circuit Court 2015q3-2017q2 foreclosure filings
    perc_foreclosure_sales = pct_fcl_sale, # Baltimore City Circuit Court 2015q3-2017q2 foreclosure filings
    perc_homeowners = phhooac6bg, # July 2017 data
    perc_permits_over10k = pct10k_prmt, # Baltimore Housing 2015q3-2017q2 Database
    vacant_lots_bldgs_per_acre_res = p_vl_vb_r_acr, # Baltimore Housing July 2017 Database
    units_per_acre_res = h_up_res_acre, # Baltimore Housing July 2017 Database
    geometry = geoms
  ) %>%
  dplyr::mutate(
    part = dplyr::case_when(
      stringr::str_detect(geoid_part, "[:alpha:]") ~ stringr::str_extract(geoid_part, "[:alpha:]")
    ),
    cluster = dplyr::case_when(
      cluster == "NonResidential" ~ "Non-Residential",
      cluster == "Mixed Market/Subsd Rental" ~ "Mixed Market/Subsidized Rental Market",
      TRUE ~ cluster
    ),
    perc_homeowners = dplyr::if_else(perc_homeowners != -9999, perc_homeowners / 100, 0),
    perc_foreclosure_sales = round(perc_foreclosure_sales, digits = 4),
    perc_permits_over10k = round(perc_permits_over10k, digits = 4),
    vacant_lots_bldgs_per_acre_res = round(vacant_lots_bldgs_per_acre_res, digits = 4)
  )

cluster_groups <- tibble::tribble(
  ~cluster, ~cluster_group,
  "A", "A",
  "B", "B & C",
  "C", "B & C",
  "D", "D & E",
  "E", "D & E",
  "F", "F, G, & H",
  "G", "F, G, & H",
  "H", "F, G, & H",
  "I", "I & J",
  "J", "I & J",
  "Rental Market 1", "RM 1 & RM 2",
  "Rental Market 2", "RM 1 & RM 2",
  "Subsidized Rental Market", "Other Residential",
  "Mixed Market/Subsidized Rental Market", "Other Residential",
  "Non-Residential", "Non-Residential"
)

hmt_2017 <- hmt_2017 %>%
  dplyr::left_join(cluster_groups, by = "cluster") %>%
  dplyr::relocate(cluster_group, .after = cluster) %>%
  dplyr::relocate(part, .after = geoid)


hmt_2017$cluster <- forcats::fct_relevel(hmt_2017$cluster, cluster_groups$cluster)
hmt_2017$cluster_group <- forcats::fct_relevel(hmt_2017$cluster_group, unique(cluster_groups$cluster_group))

usethis::use_data(hmt_2017, overwrite = TRUE)

adopted_plans_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/72"

adopted_plans <- esri2sf::esri2sf(adopted_plans_path) %>%
  janitor::clean_names("snake") %>%
  # Transform to projected CRS
  sf::st_transform(selected_crs)

adopted_plans <- adopted_plans %>%
  dplyr::select(plan_name = area_name, year_adopted = status, url, geometry = geoms) %>%
  dplyr::mutate(
    year_adopted = stringr::str_sub(year_adopted, start = -4),
    program = dplyr::case_when(
      stringr::str_detect(plan_name, "(SNAP)") ~ "Strategic Neighborhood Action Plan (SNAP)",
      stringr::str_detect(plan_name, "[:space:]TAP") ~ "Urban Land Institute Technical Assistance Panel (TAP)",
      stringr::str_detect(plan_name, "[:space:]INSPIRE") ~ "INSPIRE (Investing in Neighborhoods and Schools to Promote Improvement, Revitalization, and Excellence)"
    )
  ) %>%
  relocate(geometry, .after = program) %>%
  relocate(program, .after = year_adopted)

lincs_corridors_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/37"

lincs_corridors <- esri2sf::esri2sf(lincs_corridors_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::filter(objectid != 4)


lincs_corridors$plan_name <- c("Greenmount Avenue LINCS Plan", "Liberty Heights Avenue/Garrison Boulevard LINCS Plan", "East North Avenue LINCS Plan", "Pennsylvania Avenue/North Avenue LINCS Plan")
lincs_corridors$year_adopted <- c("2016", "2016", "2017", "2016")
lincs_corridors$program <- "LINCS (Leveraging Investments in Neighborhood Corridors)"
lincs_corridors$url <- c(
  "https://planning.baltimorecity.gov/greenmount-lincs",
  "http://planning.baltimorecity.gov/liberty-heights-lincs",
  "https://planning.baltimorecity.gov/lincs-east-north-avenue",
  "http://planning.baltimorecity.gov/penn-north-lincs"
)

lincs_corridors <- lincs_corridors %>%
  dplyr::select(-c(objectid, shape_st_length), plan_name, year_adopted, program, url, geometry = geoms)

adopted_plans <- dplyr::bind_rows(adopted_plans, lincs_corridors)

usethis::use_data(adopted_plans, overwrite = TRUE)

## Zoning ----

# Set path to Baltimore City Department of Planning Zoning hosted ArcGIS MapServer layer
zoning_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/20"

# Import zoning data with esri2sf package
zoning <- esri2sf::esri2sf(zoning_path)

# Clean column names
zoning <- janitor::clean_names(zoning, "snake")

# Transform to projected CRS
zoning <- sf::st_transform(zoning, 2804)

# Replace blank overlay values with NA
zoning$overlay[zoning$overlay %in% c(" ", "")] <- NA

# Select relevant columns
zoning <- dplyr::select(zoning,
                        zoning,
                        overlay,
                        label,
                        geometry = geoms
)

# Make valid to avoid "Ring Self-intersection" error when cropped
zoning <- sf::st_make_valid(zoning)

zoning_legend <- tibble::tribble(
  ~code, ~category, ~name,
  "AU", "Special Purpose Districts", "Adult Use Overlay Zoning District",
  "BSC", "Industrial Districts", "Bio-Science Campus Zoning District",
  "C-1", "Commercial Districts", "Neighborhood Business Zoning District",
  "C-1-E", "Commercial Districts", "Neighborhood Business and Entertainment Zoning District",
  "C-1-VC", "Commercial Districts", "Neighborhood Business Zoning District (Village Center)",
  "C-2", "Commercial Districts", "Community Commercial Zoning District",
  "C-3", "Commercial Districts", "General Commercial Zoning District",
  "C-4", "Commercial Districts", "Heavy Commercial Zoning District",
  "C-5", "Commercial Districts", "Downtown District",
  "CBCA", "Open-Space and Environmental Districts", "Chesapeake Bay Critical Area Overlay Zoning District",
  "D-MU", "Special Purpose Districts", "Detached Dwelling Mixed-Use Overlay District",
  "EC-1", "Special Purpose Districts", "Educational Campus Zoning District",
  "EC-2", "Special Purpose Districts", "Educational Campus Zoning District",
  "FP", "Open-Space and Environmental Districts", "Floodplain Overlay Zoning District",
  "H", "Special Purpose Districts", "Hospital Campus Zoning District",
  "I-1", "Industrial Districts", "Light Industrial Zoning District",
  "I-2", "Industrial Districts", "General Industrial Zoning District",
  "IMU-1", "Industrial Districts", "Industrial Mixed-Use Zoning District",
  "IMU-2", "Industrial Districts", "Industrial Mixed-Use Zoning District",
  "MI", "Industrial Districts", "Maritime Industrial Zoning District",
  "OIC", "Industrial Districts", "Office-Industrial Campus Zoning District",
  "OR-1", "Special Purpose Districts", "Office-Residential Zoning District",
  "OR-2", "Special Purpose Districts", "Office-Residential Zoning District",
  "OS", "Open-Space and Environmental Districts", "Open-Space Zoning District",
  "PC", "Special Purpose Districts", "Port Covington Zoning District",
  "R-1", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-1-A", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-1-B", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-1-C", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-1-D", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-1-E", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-2", "Detached and Semi-Detached Residential Districts", "Detached and Semi-Detached Residential Zoning District",
  "R-3", "Detached and Semi-Detached Residential Districts", "Detached Residential Zoning District",
  "R-4", "Detached and Semi-Detached Residential Districts", "Detached and Semi-Detached Residential Zoning District",
  "R-5", "Rowhouse and Multi-Family Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-6", "Rowhouse and Multi-Family Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-7", "Rowhouse and Multi-Family Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-8", "Rowhouse and Multi-Family Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-9", "Rowhouse and Multi-Family Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-10", "Detached and Semi-Detached Residential Districts", "Rowhouse and Multi-Family Residential Zoning District",
  "R-MU", "Special Purpose Districts", "Rowhouse Mixed-Use Overlay District",
  "T", "Special Purpose Districts", "Transportation Zoning District",
  "TOD-1", "Special Purpose Districts", "Transit-Oriented Development District",
  "TOD-2", "Special Purpose Districts", "Transit-Oriented Development District",
  "TOD-3", "Special Purpose Districts", "Transit-Oriented Development District",
  "TOD-4", "Special Purpose Districts", "Transit-Oriented Development District",
  "W-1", "Special Purpose Districts", "Waterfront Overlay Zoning District",
  "W-2", "Special Purpose Districts", "Waterfront Overlay Zoning District",
  "PC-1", "Special Purpose Districts", "Port Covington Zoning District",
  "PC-2", "Special Purpose Districts", "Port Covington Zoning District",
  "PC-3", "Special Purpose Districts", "Port Covington Zoning District",
  "PC-4", "Special Purpose Districts", "Port Covington Zoning District",
  "C-5-TO", "Commercial Districts", "Downtown District",
  "C-5-HS", "Commercial Districts", "Downtown District",
  "C-5-DC", "Commercial Districts", "Downtown District",
  "C-5-G", "Commercial Districts", "Downtown District",
  "C-5-HT", "Commercial Districts", "Downtown District",
  "C-5-IH", "Commercial Districts", "Downtown District",
  "C-5-DE", "Commercial Districts", "Downtown District"
)

zoning <- zoning %>%
  dplyr::left_join(zoning_legend, by = c("zoning" = "code")) %>%
  dplyr::left_join(zoning_legend, by = c("overlay" = "code"), suffix = c("_zoning", "_overlay"))

usethis::use_data(zoning, overwrite = TRUE)



## MTA Bus Lines ----

# Import Maryland Transit Administration bus line data (current as of July 12, 2020)
# https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1
mta_bus_lines <- sf::read_sf("https://opendata.arcgis.com/datasets/44253e8ca1a04c08b8666d212e04a900_10.geojson") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(-c(distribution_policy, objectid))

mta_bus_lines <- mta_bus_lines %>%
  dplyr::mutate(
    frequent = dplyr::case_when(
      stringr::str_detect(route_number, "^CityLink") ~ TRUE,
      route_number %in% c("22", "26", "80", "54", "30", "85") ~ TRUE,
      TRUE ~ FALSE
    )
  )

usethis::use_data(mta_bus_lines, overwrite = TRUE)

## MTA Bus Stops ----

mta_bus_stops <- sf::read_sf("https://opendata.arcgis.com/datasets/cf30fef14ac44aad92c135f6fc8adfbe_9.geojson")

mta_bus_stops <- janitor::clean_names(mta_bus_stops, "snake")

mta_bus_stops <- sf::st_transform(mta_bus_stops, 2804)

mta_bus_stops <- dplyr::select(mta_bus_stops, -c(distribution_policy, objectid))

usethis::use_data(mta_bus_stops, overwrite = TRUE)

## Streets ----

streets_path <- "https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/4"

streets <- esri2sf::esri2sf(streets_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804)

sha_class_label_list <- tibble::tribble(
  ~sha_class, ~sha_class_label, ~functional_class,
  "INT", "Interstate and Principal Arterial", 1,
  "FWY", "Freeway and Expressway", 2,
  "PART", "Other Principal Arterial Street", 3,
  "MART", "Minor Arterial Street", 4,
  "COLL", "Collector Street", 5,
  "LOC", "Local Street", 7
)


functional_class_list <- tibble::tribble(
  ~sha_class, ~functional_class, ~functional_class_desc,
  "INT", 1, "Interstate",
  "FWY", 2, "Principal Arterial – Other Freeways and Expressways",
  "PART", 3, "Principal Arterial – Other",
  "MART", 4, "Minor Arterial",
  "COLL", 5, "Major Collector",
  "COLL", 6, "Minor Collector",
  "LOC", 7, "Local"
)

subtype_label <- tibble::tribble(
  ~subtype, ~subtype_label,
  "STRALY", "Alley",
  "STRPRD", "Paved Road",
  "STRR", "Ramp",
  "STREX", "Limited Access",
  "STRFIC", "Fictitious Centerline Segment",
  "STRNDR", NA,
  "STRURD", "Unpaved Road",
  "STCLN", "County Street Centerline",
  "STRTN", "Tunnel"
)

streets <- streets %>%
  dplyr::select(-c(objectid_1:edit_date, flag:comments, shape_leng, place, zipcode:shape_st_length)) %>%
  dplyr::left_join(sha_class_label_list, by = "sha_class") %>%
  dplyr::relocate(sha_class_label, .after = sha_class) %>%
  dplyr::mutate(sha_class_label = forcats::fct_relevel(sha_class_label, sha_class_label_list$sha_class_label)) %>%
  dplyr::left_join(subtype_label, by = "subtype") %>%
  dplyr::relocate(subtype_label, .after = subtype) %>%
  dplyr::rename(geometry = geoms)

usethis::use_data(streets, overwrite = TRUE)
