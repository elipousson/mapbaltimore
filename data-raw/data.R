library(dplyr)
library(sfext)
library(getdata)
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
  dplyr::nest_by(name)

balt_tbl_labs <-
  googlesheets4::read_sheet("https://docs.google.com/spreadsheets/d/1FXEJlhccnhoQmSO2WydBidXIw-f2lpomURDGy9KBgJw/edit?usp=sharing")

usethis::use_data(balt_tbl_labs, overwrite = TRUE)

md_counties <- getdata::get_tigris_data(type = "counties", state = state_fips, crs = selected_crs, cb = FALSE)

baltimore_msa_counties <- md_counties %>%
  dplyr::filter(name %in% c("Baltimore", "Anne Arundel", "Carroll", "Harford", "Howard", "Queen Anne's"))

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

baltimore_bbox <- sfext::as_bbox(baltimore_city, 4326)

usethis::use_data(baltimore_bbox, overwrite = TRUE)


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

# 2022
legislative_districts <-
  getdata::get_esri_data(
    url = "https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries_2022/FeatureServer/1",
    location = mapbaltimore::baltimore_city,
    crs = 2804
  )

legislative_districts <-
  legislative_districts %>%
  sfext::st_filter_ext(mapbaltimore::baltimore_city %>%
    sfext::st_buffer_ext(dist = -1000, unit = "m")) %>%
  rename_sf_col() %>%
  select(id = district) %>%
  mutate(
    name = paste0("District ", id),
    label = paste0("Maryland House of Delegates ", name)
  ) %>%
  arrange(id)

use_data(legislative_districts, overwrite = TRUE)

# 2012
baltimore_city_legislative_districts <- c("40", "41", "43", "44A", "45", "46")

legislative_districts_2012_path <- "https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1"
legislative_districts_2012 <- esri2sf::esri2sf(legislative_districts_2012_path) %>%
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

usethis::use_data(legislative_districts_2012, overwrite = TRUE)

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

planning_districts_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Housing/dmxBoundaries3/MapServer/9"
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

planning_districts <- planning_districts %>%
  sf::st_make_valid() %>%
  st_trim(mapbaltimore::baltimore_city) %>%
  sf::st_cast("MULTIPOLYGON")

usethis::use_data(planning_districts, overwrite = TRUE)

# Import neighborhood boundaries from iMAP (derived from a data set previously available on Open Baltimore)
# https://opendata.maryland.gov/Society/MD-iMAP-Maryland-Baltimore-City-Neighborhoods/dbbp-8u4u
neighborhoods_path <- "https://opendata.arcgis.com/datasets/fc5d183b20a145009eae8f8b171eeb0d_0.geojson"

neighborhoods <- sf::read_sf(neighborhoods_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::rename(name = label) %>%
  dplyr::mutate(
    acres = as.numeric(units::set_units(sf::st_area(geometry), "acres")),
    type = dplyr::case_when(
      (stringr::str_detect(name, "Industrial") | name == "Jones Falls Area" | name == "Dundalk Marine Terminal") ~ "Industrial area",
      stringr::str_detect(name, "Business Park") ~ "Business park",
      name %in% c("University Of Maryland", "Morgan State University") ~ "Institutional area",
      # NOTE: This classifies Montebello as a park but is more accurately described as a reservoir
      name %in% c(
        "Gwynns Falls/Leakin Park", "Druid Hill Park", "Patterson Park", "Clifton Park", "Carroll Park",
        "Montebello", "Greenmount Cemetery", "Herring Run Park", "Lower Herring Run Park"
      ) ~ "Park/open space",
      TRUE ~ "Residential"
    )
  ) %>%
  dplyr::select(
    name,
    type,
    acres,
    geometry
  ) %>%
  dplyr::arrange(name)

osm_nhoods <-
  get_area_osm_data(
    area = baltimore_city,
    key = "place",
    value = "neighbourhood",
    return_type = "osm_multipolygons"
  ) %>%
  sf::st_drop_geometry() %>%
  dplyr::select(name, osm_id, wikidata)

osm_nhoods <- osm_nhoods %>%
  dplyr::mutate(
    name =
      dplyr::case_when(
        name == "Fell's Point" ~ "Fells Point",
        name == "Upper Fell's Point" ~ "Upper Fells Point",
        name == "Four by Four" ~ "Four By Four",
        name == "Butchers Hill" ~ "Butcher's Hill",
        name == "Old Town" ~ "Oldtown",
        name == "Coldstream-Homestead-Montebello" ~ "Coldstream Homestead Montebello",
        name == "Gwynn's Falls" ~ "Gwynns Falls",
        name == "Patterson Park" ~ "Patterson Park Neighborhood",
        TRUE ~ name
      )
  ) %>%
  naniar::replace_with_na(list(wikidata = ""))

neighborhoods <- neighborhoods %>%
  dplyr::left_join(osm_nhoods, by = "name") %>%
  dplyr::relocate(geometry, .after = "wikidata")

usethis::use_data(neighborhoods, overwrite = TRUE)

# Import Community Statistical Area boundaries from University of Baltimore BNIA-JFI ArcGIS FeatureServer layer
csas_path <- "https://services1.arcgis.com/mVFRs7NF4iFitgbY/arcgis/rest/services/Community_Statistical_Areas_(CSAs)__Reference_Boundaries/FeatureServer/0"

csas <- esri2sf::esri2sf(csas_path) %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::mutate(
    neigh = strsplit(neigh, ","),
    tracts = strsplit(tracts, ","),
  ) %>%
  dplyr::select(
    id = fid,
    name = community,
    # Exclude list of neighborhoods and tracts. See xwalk files from baltimoredata package
    # neighborhoods = neigh,
    # tracts,
    url = link,
    geometry = geoms
  ) %>%
  dplyr::mutate(
    # Internally inconsistent naming for CSAs retained to maintain consistency with official names
    # name = case_when(
    #  name == "Allendale/Irvington/S. Hilton" ~ "Allendale/Irvington/South Hilton",
    #  TRUE ~ name
    # ),
    url = stringr::str_replace(url, "http://", "https://")
  ) %>%
  dplyr::arrange(id)

usethis::use_data(csas, overwrite = TRUE)


# Crosswalk: Community Statistical Areas to Zip Codes ----
xwalk_zip2csa <- rio::import(
  file = "https://bniajfi.org/wp-content/uploads/2014/04/Zip-to-CSA-2010.xls",
  setclass = "tibble",
  col_types = "text"
) %>%
  dplyr::rename(zip = Zip2010, csa = CSA2010) %>%
  dplyr::mutate(
    csa = dplyr::case_when(
      csa == "Orangeville/E. Highlandtown" ~ "Orangeville/East Highlandtown",
      csa == "Howard Park/W. Arlington" ~ "Howard Park/West Arlington",
      csa == "Cross Country/Cheswolde" ~ "Cross-Country/Cheswolde",
      csa == "Mt. Washington/Coldspring" ~ "Mount Washington/Coldspring",
      csa == "N. Baltimore/Guilford/Homeland" ~ "North Baltimore/Guilford/Homeland",
      csa == "Westport/Mt. Winans/Lakeland" ~ "Westport/Mount Winans/Lakeland",
      TRUE ~ csa
    )
  ) %>%
  dplyr::left_join(sf::st_drop_geometry(csas), by = c("csa" = "name"))

usethis::use_data(xwalk_zip2csa, overwrite = TRUE)


# Crosswalk: Community Statistical Areas to Neighborhood Statistical Areas ----
xwalk_csa2nsa <- rio::import(
  file = "https://bniajfi.org/wp-content/uploads/2014/04/CSA-to-NSA-2010.xlsx",
  setclass = "tibble",
  col_types = "text"
) %>%
  dplyr::rename(csa = CSA2010, nsa = NSA2010) %>%
  # Add missing NSAs
  dplyr::add_row(
    csa = "Belair-Edison",
    nsa = "Lower Herring Run Park"
  ) %>%
  dplyr::add_row(
    csa = "Southeastern",
    nsa = "Broening Manor"
  ) %>%
  dplyr::mutate(
    # Fix CSA names to match csas
    csa = dplyr::case_when(
      csa == "Allendale/Irvington/South Hilton" ~ "Allendale/Irvington/S. Hilton",
      csa == "Mt. Washington/Coldspring" ~ "Mount Washington/Coldspring",
      csa == "Westport/Mt. Winans/Lakeland" ~ "Westport/Mount Winans/Lakeland",
      csa == "Glen-Falstaff" ~ "Glen-Fallstaff",
      TRUE ~ csa
    ),
    # Fix NSA assigned to incorrect area
    csa = dplyr::case_when(
      nsa == "Spring Garden Industrial Area" ~ "South Baltimore",
      TRUE ~ csa
    ),
    # Add neighborhood column with names to match neighborhoods
    neighborhood = dplyr::case_when(
      nsa == "Booth-Boyd" ~ "Boyd-Booth",
      nsa == "Caroll-Camden Industrial Area" ~ "Carroll - Camden Industrial Area",
      nsa == "Glenham-Belford" ~ "Glenham-Belhar",
      nsa == "North Harford Road" ~ "Hamilton Hills",
      nsa == "Mt. Washington" ~ "Mount Washington",
      nsa == "Mt. Winans" ~ "Mount Winans",
      nsa == "Mt. Pleasant Park" ~ "Mt Pleasant Park",
      nsa == "New Southwest/Mt. Clare" ~ "New Southwest/Mount Clare",
      nsa == "Rosemont Homewoners/Tenants" ~ "Rosemont Homeowners/Tenants",
      nsa == "University of Maryland" ~ "University Of Maryland",
      TRUE ~ nsa
    )
  ) %>%
  dplyr::left_join(sf::st_drop_geometry(csas), by = c("csa" = "name")) %>%
  dplyr::relocate(id, .before = csa)

usethis::use_data(xwalk_csa2nsa, overwrite = TRUE)


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
bcps_zones_path <- "https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2122_Ezones_and_Programs/FeatureServer/15"

bcps_zones <- esri2sf::esri2sf(bcps_zones_path, crs = selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    #    program_name = prog_name,
    #    program_number = prog_no,
    zone_name,
    program_number = zone_no,
    geometry = geoms
  ) %>%
  dplyr::left_join(
    sf::st_drop_geometry(bcps_programs),
    by = "program_number"
  ) %>%
  dplyr::select(-swing_space) %>%
  dplyr::arrange(program_number) %>%
  sfext::relocate_sf_col()

usethis::use_data(bcps_zones, overwrite = TRUE)

# 2021-2022 program sites
bcps_programs_path <- "https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2122_Ezones_and_Programs/FeatureServer/11"

bcps_programs <- esri2sf::esri2sf(bcps_programs_path, crs = 2804) %>%
  janitor::clean_names("snake")

bcps_programs <- bcps_programs %>%
  #  sf::st_transform(selected_crs) %>%
  dplyr::select(
    program_name_short = prog_short,
    program_number = prog_no,
    type = mgmnt_type,
    category = categorization,
    # zone_name,
    swing_space = swing,
    geometry = geoms
  ) %>%
  dplyr::mutate(
    swing_space = if_else(
      swing_space == "y", TRUE, FALSE
    )
  )

bcps_programs <- bcps_programs %>%
  dplyr::arrange(program_number)

osm_schools <-
  getdata::get_osm_data(
    location = mapbaltimore::baltimore_city,
    key = "amenity",
    value = "school",
    geometry = "polygons"
  )

osm_schools_join <-
  sf::st_join(
    bcps_programs,
    osm_schools %>% sf::st_transform(2804),
    suffix = c("", "_osm")
  )

bcps_programs <-
  osm_schools_join %>%
  select(
    program_name_short,
    program_number,
    osm_name, # = name,
    osm_id,
    type,
    category,
    swing_space
  ) %>%
  mutate(
    osm_id = paste0("way/", osm_id)
  )

bcps_programs <-
  naniar::replace_with_na(bcps_programs, list(osm_id = "way/NA"))

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


## Park districts ----

park_districts <- esri2sf::esri2sf("https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/AGOL_BCRP_MGMT_20181220/FeatureServer/3")

park_districts <- park_districts %>%
  dplyr::select(
    name = AREA_NAME,
    geometry = geoms
  ) %>%
  sf::st_transform(selected_crs)

usethis::use_data(park_districts, overwrite = TRUE)


## Parks ----

# Set path to city parks hosted ArcGIS MapServer layer
parks_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2"

# Import parks data with esri2sf package
parks <- getdata::get_esri_data(
  url = parks_path,
  crs = selected_crs # Transform to projected CRS
) %>%
  sf::st_make_valid() %>% # Make valid to avoid "Ring Self-intersection" error
  dplyr::select(name, id = park_id, address, name_alt, operator = bcrp, geometry = geoms) %>% # Select relevant columns
  sf::st_join(dplyr::select(park_districts, park_district = name), largest = TRUE) %>%
  dplyr::mutate(
    operator = dplyr::if_else(operator == "Y", "Baltimore City Department of Recreation and Parks", "Other"),
    acres = units::set_units(sf::st_area(geometry), "acres")
  ) %>%
  dplyr::relocate(
    geometry,
    .after = tidyselect::everything()
  )


parks <- parks %>%
  mutate(
    name = stringr::str_trim(stringr::str_squish(name)),
    name_alt = case_when(
      (name == "Belnor Squares Park") ~ "Belnord Squares Park",
      (name == "Courthouse Plaza") ~ "Cathy Hughes Plaza",
      (name == "Mt Vernon Square Park") ~ name,
      (name == "Calvert & Madison Park") ~ name,
      (name == "Lehigh & Gough Park") ~ name,
      (name == "Ellwood Ave Park") ~ name,
      (name == "Contee-Parago Traffic Island") ~ name,
      (name == "Ambrose Kennedy Park") ~ name,
      (name == "Madison Square Park") ~ name,
      (name == "32nd Street Park") ~ name,
      (name == "Harwood Avenue Park") ~ name,
      TRUE ~ name_alt
    ),
    name = case_when(
      name == "Pauline Faunteroy" ~ "Pauline Faunteroy Park",
      name == "Mary E. Rodman Recreation Center" ~ "Mary E. Rodman Rec Center",
      name_alt == "Mt Vernon Square Park" ~ "Mount Vernon Place",
      name_alt == "Calvert & Madison Park" ~ "Mount Vernon Children's Park",
      name_alt == "Lehigh & Gough Park" ~ "Gloria Hertzfelt Playground",
      name_alt == "Belnor Squares Park" ~ "Library Square",
      name_alt == "Ellwood Ave Park" ~ "Ellwood Park",
      name_alt == "Contee-Parago Traffic Island" ~ "Contee-Parago Park",
      name_alt == "Ambrose Kennedy Park" ~ "Henrietta Lacks Educational Park",
      name_alt == "Madison Square Park" ~ "Nathan C. Irby, Jr. Park",
      (name_alt == "32nd Street Park") ~ "Abell Open Space",
      (name_alt == "Harwood Avenue Park") ~ "Harwood Park",
      TRUE ~ name
    ),
    name = case_when(
      stringr::str_detect(name, "[:space:]St[:space:]P") ~ stringr::str_replace(name, " St P", " St. P"),
      stringr::str_detect(name, "[:space:]Ave[:space:]P") ~ stringr::str_replace(name, " Ave P", " Ave. P"),
      stringr::str_detect(name, "[:space:]Street[:space:]P") ~ stringr::str_replace(name, " Street P", " St. P"),
      stringr::str_detect(name, "[:space:]Avenue[:space:]P") ~ stringr::str_replace(name, " Avenue P", " Ave. P"),
      TRUE ~ name
    )
  )

osm_parks <-
  getdata::get_osm_data(
    location = mapbaltimore::baltimore_city,
    key = "leisure",
    value = "park",
    osmdata = TRUE
  )

osm_parks_rev <- bind_rows(
  osm_parks$osm_polygons %>%
    mutate(
      osm_id = paste0("way/", osm_id)
    ) %>%
    sf::st_cast("MULTIPOLYGON"),
  osm_parks$osm_multipolygons %>%
    mutate(
      osm_id = paste0("relation/", osm_id)
    )
) |>
  dplyr::select(
    osm_id, name
  ) |>
  dplyr::filter(!is.na(name)) #|>
# naniar::replace_with_na(list(wikidata = "", start_date = ""))

osm_parks_name_matched <-
  osm_parks_rev %>%
  filter(name %in% parks$name) %>%
  sf::st_drop_geometry()

osm_xwalk <-
  tibble::tribble(
    ~name, ~osm_id_add,
    "Courthouse Plaza", "way/1020465427",
    "Pope John Paul II Prayer Garden", "way/1090360725",
    "Chick Webb Memorial Rec Center", "node/358249524",
    "Upton Boxing Center", "node/9362251051",
    "Moore's Run Park", "relation/12764727",
    "Atlantic Ave. Park", "relation/13007392",
    "Shake n' Bake", "relation/13587201",
    "Evesham Ave. Park", "relation/5771325",
    "Boston St. Pier Park", "relation/6649001",
    "Preston Gardens Park", "relation/6814275",
    "Chinquapin Run Park", "relation/9352296",
    "Stoney Run Park", "relation/9353383",
    "Winner Ave. Park", "way/1007202043",
    "Bocek Park", "way/100893180",
    "President & Pratt St. Park", "way/1014903193",
    "Newington Ave. Park", "way/1020465420",
    "Carlton St. Park", "way/1020465421",
    "Schroeder & Lombard Park", "way/1020465424",
    "Fox St. Park", "way/1020465428",
    "Miles Ave. Park", "way/1020465430",
    "Montpelier & 30th St. Park", "way/1020465431",
    "Woodbourne Ave. Park", "way/1020465740",
    "Riverside Park", "way/103285201",
    "Lehigh & Gough Park", "way/1035465876",
    "Waverly Mini Park", "way/1081962109",
    "Holocaust Memorial Park", "way/109485081",
    "Cottage Ave. Park", "way/114693976",
    "Greenspring Ave. Park", "way/114693991",
    "Pall Mall & Shirley", "way/114693996",
    "Shirley Ave. Park", "way/114694001",
    "Thames St. Park", "way/115211504",
    "Conway St. Park", "way/126145341",
    "Stricker & Ramsey Park", "way/127010721",
    "Elmley Ave. Park", "way/138384283",
    "Vincent St. Park", "way/165342610",
    "World Trade Plaza", "way/185099840",
    "Baltimore Immigration Memorial Park", "way/208444707",
    "Under Armour Waterfront Park", "way/208444711",
    "Abell Open Space", "way/220687246",
    "Arnold Sumpter Park", "way/220687249",
    "Robert C. Marshall Park", "way/227894291",
    "Buena Vista Park", "way/239263166",
    "Pierce's Park", "way/242782258",
    "Columbus Park", "way/242968653",
    "Pauline Faunteroy Park", "way/255481074",
    "Contee-Parago Park", "way/262584183",
    "Saint Mary's Park", "way/262587660",
    "Irvington Park", "way/262944613",
    "Lakeland Park", "way/283033503",
    "Paca St. Park", "way/283538339",
    "Castle St. Park", "way/292628813",
    "Janney St. Park", "way/292983554",
    "Keyes Park", "way/32426907",
    "Cecil Kirk Rec Center", "way/336339409",
    "Greenmount Rec Center", "way/336352554",
    "Forrest St. Park", "way/339540454",
    "Saint Leo's Bocce Park", "way/360962326",
    "Mount Royal Terrace Park", "way/379855071",
    "Rozena Ridgley Park", "way/380019341",
    "B & O Museum Park", "way/380020456",
    "Battle Monument", "way/431237141",
    "Cimaglia Park", "way/436726566",
    "Robert & Mcculloh Park", "way/452160218",
    "Lafayette Square Park", "way/49320694",
    "Harlem Square Park", "way/49320695",
    "Betty Hyatt Park", "way/495768187",
    "Maisel St. Park", "way/524637577",
    "Center Plaza", "way/530866324",
    "Henry St. Park", "way/544546985",
    "Henry H. Garnet Park", "way/628291631",
    "Elm Park", "way/638323195",
    "Hoes Heights Park", "way/638334715",
    "Catherine St. Park", "way/683467763",
    "McKeldin Plaza", "way/68624603",
    "Johnston Square Park", "way/69489464",
    "Kimberleligh Road Park", "way/699104068",
    "Warwick Ave. Park", "way/703993923",
    "Collington Sq Park", "way/71698840",
    "Luzerne Ave. Park", "way/740552334",
    "Willow Ave. Park", "way/765852714",
    "Nathan C. Irby, Jr. Park", "way/80318086",
    "Rosemont Park", "way/803377606",
    "Belvedere & Sunset St. Park", "way/813758923",
    "Saint Casmir's Park", "way/82422915",
    "Penn & Melvin St. Park", "way/838874053",
    "Russell St. Park", "way/838874054",
    "Warner St. Park", "way/838874055",
    "Union Square Park", "way/85585339",
    "Franklin Square Park", "way/85585348",
    "Joseph E. Lee Park", "way/85609472",
    "Indiana Ave. Park", "way/935844574",
    "Irvin Luckman Park", "way/95035178",
    "1640 Light St", "way/964597342"
  )


parks <- parks %>%
  left_join(osm_parks_name_matched, by = "name") %>%
  left_join(osm_xwalk, by = "name") %>%
  mutate(
    osm_id = if_else(is.na(osm_id), osm_id_add, osm_id)
  ) %>%
  select(-osm_id_add) %>%
  distinct(name, id, address, .keep_all = TRUE)

usethis::use_data(parks, overwrite = TRUE)

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
  dplyr::select(c(tractce20:name20, aland20:pop20))

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

# Crosswalk: Neighborhoods to Tracts weighted by 2010 household population ----

# Make a weighted dataframe of neighborhoods and tracts for use with the cwi package
# Based on https://github.com/CT-Data-Haven/cwi/blob/master/data-raw/make_neighborhood_shares.R

options(tigris_use_cache = TRUE)

xwalk_blocks <- baltimore_blocks %>%
  sf::st_drop_geometry() %>%
  dplyr::left_join(sf::st_drop_geometry(baltimore_tracts), by = c("tractce20" = "tractce")) %>%
  dplyr::select(block = geoid20, tract = geoid, block_name = name20, tract_name = namelsad)

# vars <-
#   tidycensus::load_variables(year = 2020, dataset = "pl")

blocks_households <-
  tidycensus::get_decennial(
    geography = "block",
    variables = "H1_002N",
    # variables = "H013001", # Total households
    state = "24",
    county = "510",
    year = 2020,
    sumfile = "pl",
    # sumfile = "sf1",
    cache = TRUE,
    geometry = TRUE
  ) %>%
  janitor::clean_names()

xwalk_block2tract <-
  blocks_households %>%
  dplyr::left_join(xwalk_blocks, by = c("geoid" = "block")) %>%
  dplyr::select(geoid, occupied_units_2020 = value)

# blocks_occupied_units <- tidycensus::get_decennial(
#   geography = "block",
#   variables = "H1_002N", # Total households
#   state = "24",
#   county = "510",
#   year = 2020,
#   sumfile = "sf1",
#   cache = TRUE,
#   geometry = FALSE
# ) %>%
#   janitor::clean_names() %>%
#   dplyr::select(geoid, occupied_units_2020 = value)

xwalk_block2tract <- blocks_households %>%
  dplyr::left_join(xwalk_blocks, by = c("geoid" = "block")) %>%
  dplyr::left_join(blocks_occupied_units, by = "geoid") %>%
  dplyr::select(block = geoid, tract, households_2010 = value, occupied_units_2020, -name)

xwalk_neighborhood2tract <-
  xwalk_block2tract %>%
  dplyr::select(geoid, tract, occupied_units_2020) %>%
  sf::st_transform(2804) %>%
  sf::st_join(neighborhoods, left = FALSE, largest = TRUE) %>%
  dplyr::filter(occupied_units_2020 > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, name) %>%
  dplyr::summarise(
    # households_2010 = sum(households_2010, na.rm = TRUE),
    occupied_units_2020 = sum(occupied_units_2020, na.rm = TRUE)
  ) %>%
  dplyr::mutate(
    # weight_households = round(households_2010 / sum(households_2010, na.rm = TRUE), digits = 2),
    weight_units = round(occupied_units_2020 / sum(occupied_units_2020, na.rm = TRUE), digits = 2)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::rename(geoid = tract) %>%
  dplyr::mutate(tract = stringr::str_sub(geoid, -6)) %>%
  dplyr::select(name, geoid, tract, weight_units)

usethis::use_data(xwalk_neighborhood2tract, overwrite = TRUE)

inspire_plans_for_xwalk <-
  inspire_plans %>%
  bind_rows(
    st_erase(baltimore_city, inspire_plans) %>% select(plan_name = name)
  )

xwalk_inspire2tract <-
  xwalk_block2tract %>%
  dplyr::select(geoid, tract, occupied_units_2020) %>%
  sf::st_transform(2804) %>%
  sf::st_join(inspire_plans_for_xwalk, left = FALSE, largest = TRUE) %>%
  dplyr::filter(occupied_units_2020 > 0) %>%
  sf::st_set_geometry(NULL) %>%
  dplyr::group_by(tract, plan_name) %>%
  dplyr::summarise(
    # households_2010 = sum(households_2010, na.rm = TRUE),
    occupied_units_2020 = sum(occupied_units_2020, na.rm = TRUE)
  ) %>%
  dplyr::mutate(
    # weight_households = round(households_2010 / sum(households_2010, na.rm = TRUE), digits = 2),
    weight_units = round(occupied_units_2020 / sum(occupied_units_2020, na.rm = TRUE), digits = 2)
  ) %>%
  dplyr::ungroup() %>%
  dplyr::rename(geoid = tract) %>%
  dplyr::mutate(tract = stringr::str_sub(geoid, -6)) %>%
  dplyr::select(plan_name, geoid, tract, weight_units)

xwalk_inspire2tract <-
  xwalk_inspire2tract %>%
  filter(plan_name != "Baltimore city")

usethis::use_data(xwalk_inspire2tract, overwrite = TRUE)

xwalk_block2tract %>%
  sf::st_set_geometry(NULL) %>%
  usethis::use_data(overwrite = TRUE)


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

explore_baltimore <- sfext::df_to_sf(explore_baltimore,
  coords = c("longitude", "latitude"),
  remove_coords = TRUE
)

explore_baltimore <- sf::st_transform(explore_baltimore, 2804)

usethis::use_data(explore_baltimore, overwrite = TRUE)

works <- sfext::read_sf_rdata("https://github.com/publicartbaltimore/inventory/raw/master/data/works.rda")


update_date <- "2023-01-18"

path <- glue(
  "https://github.com/publicartbaltimore/inventory/raw/master/files/data/{update_date}_works-public.csv"
)

works <-
  getdata::get_location_data(
    data = path,
    from_crs = 4326,
    clean_names = TRUE
  )

works <-
  works %>%
  dplyr::select(
    id,
    osm_id,
    title = work_title,
    location = location_name,
    type,
    medium,
    status = current_status,
    year,
    year_accuracy,
    creation_dedication_date,
    primary_artist,
    primary_artist_gender,
    street_address,
    city,
    state,
    zipcode,
    dimensions,
    program,
    funding = funding_source,
    artist_assistants,
    architect,
    fabricator,
    location_desc = location_description,
    indoor_outdoor_access = indoor_outdoor_accessible,
    subject_person,
    related_property,
    property_ownership,
    agency_or_insitution,
    wikipedia_url
  )

works <-
  works %>%
  mutate(
    work_type = stringr::str_extract(type, ".+(?=,)|(?<!,).+$"),
    work_type = forcats::fct_infreq(work_type),
    work_type = forcats::fct_lump_n(work_type, 6),
    work_type = forcats::fct_explicit_na(work_type)
  )

works <- works %>%
  sf::st_transform(2804) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::csas, csa = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::legislative_districts, legislative_district = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::neighborhoods, neighborhood = name)
  ) %>%
  sf::st_join(
    dplyr::select(mapbaltimore::council_districts, council_district = name)
  ) %>%
  dplyr::relocate(
    neighborhood, csa, council_district, legislative_district,
    .before = location_desc
  ) %>%
  sf::st_transform(2804)

public_art <- works

public_art$work_type <- NULL

usethis::use_data(public_art, overwrite = TRUE)

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

# Based on a combination of this data, scraped website data and bcpss::nces_school_directory_SY19
# "https://services1.arcgis.com/mVFRs7NF4iFitgbY/arcgis/rest/services/21st_Century_Schools/FeatureServer/0"

schools_21stc_sheet_url <-
  "https://docs.google.com/spreadsheets/d/1Ve9J8T-Q5A61MgEhtxmMYCrjnVrkwR0ynsf4DAJc26Y/edit?usp=sharing"

schools_21stc_sheet_url <- "/Users/elipousson/Downloads/Comparison – 21st Century Schools + INSPIRE - schools_21stc.csv"
schools_21stc_sheet <-
  read_sf_ext(path = schools_21stc_sheet_url, from_crs = 3857) %>%
  select(-c(address, zip)) %>%
  st_transform_ext(crs = 2804)

library(readr)

school_info <-
  read_csv("/Users/elipousson/Downloads/Schoollist.csv",
    col_types = cols(
      `School Number` = col_double(),
      `School Name` = col_character(),
      Address = col_character(),
      `Address Line 2` = col_logical(),
      Zip = col_double(),
      Phone = col_character(),
      `School leader` = col_character(),
      Website = col_character(),
      `Zone Number` = col_character(),
      Description = col_character(),
      `Community learning network number` = col_double(),
      `Official state grade band` = col_character(),
      `Grades served` = col_character(),
      `Management type` = col_character(),
      `Enrollment type` = col_character(),
      `Elementary Opening Bell` = col_character(),
      `Elementary Closing Bell` = col_character(),
      `Middle Opening bell` = col_character(),
      `Middle Closing bell` = col_character(),
      `High Opening Bell` = col_character(),
      `High Closing Bell` = col_character(),
      `Academics: Approach` = col_character(),
      `Academics: Special Programming` = col_character(),
      `Academics: CTE` = col_character(),
      `Academics: AP` = col_character(),
      `Title I` = col_character(),
      Extracurriculars = col_character(),
      Services = col_character(),
      `Building info` = col_character(),
      `Address Latitude` = col_double(),
      `Address Longitude` = col_character(),
      MSDE = col_character(),
      `School Effectiveness` = col_logical(),
      `School Performance` = col_character(),
      `School Profile` = col_character(),
      `Renewal Report` = col_character(),
      `Survey Results` = col_character(),
      `5 Star Rating` = col_logical(),
      `SAT Average` = col_double(),
      `Student Uniform` = col_character(),
      `Organized Parent Group` = col_character(),
      `Video Image` = col_character(),
      `Video URL` = col_logical(),
      `Community Partnerships` = col_character()
    )
  ) %>%
  janitor::clean_names("snake") %>%
  rename_with_xwalk(
    list(
      "school_website_url" = "website",
      "school_directory_name" = "school_name",
      "school_address_lat" = "address_latitude",
      "school_address_lon" = "address_longitude",
      "bldg_info" = "building_info",
      "description_yn" = "description",
      "parent_org_yn" = "organized_parent_group",
      "msde_url" = "msde",
      "school_performance_url" = "school_performance",
      "school_profile_url" = "school_profile",
      "renewal_report_url" = "renewal_report",
      "survey_results_url" = "survey_results"
    )
  ) %>%
  mutate(
    opening_bell = coalesce(elementary_opening_bell, middle_opening_bell, high_opening_bell),
    closing_bell = coalesce(elementary_closing_bell, middle_closing_bell, high_closing_bell),
    description_yn = if_else(description_yn == "yes", "Y", "N"),
    parent_org_yn = if_else(parent_org_yn == "No", "N", "Y")
  ) %>%
  select(-c(
    address_line_2, elementary_opening_bell, middle_opening_bell, high_opening_bell,
    elementary_closing_bell, middle_closing_bell, high_closing_bell,
    school_effectiveness, x5_star_rating, video_image, video_url # ,
    # NOTE: Dropping official state grade band because the data in the reference sheet is accurate
    # official_state_grade_band
  )) %>%
  relocate(ends_with("_yn"), .after = everything()) %>%
  relocate(ends_with("_url"), .after = everything())

schools_21stc <-
  schools_21stc_sheet %>%
  left_join(school_info, by = "school_number") %>%
  bind_boundary_col(
    boundary = list(
      "neighborhood" = mapbaltimore::neighborhoods,
      "council_district" = mapbaltimore::council_districts,
      "planning_district" = mapbaltimore::planning_districts %>% rename(label = name, name = id)
    )
  ) %>%
  relocate(
    ends_with("lon"),
    .after = everything()
  ) %>%
  relocate(
    ends_with("lat"),
    .after = everything()
  ) %>%
  relocate_sf_col()

usethis::use_data(schools_21stc, overwrite = TRUE)

adopted_plans_path <-
  # FIXME: The original link for this data no longer works but the new data is missing key information
  "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/72"
# "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/39"

inspire_path <-
  "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/19"

inspire <-
  sfext::read_sf_ext(url = inspire_path)

adopted_plans <-
  sfext::read_sf_ext(url = adopted_plans_path, crs = selected_crs)

adopted_plans <- adopted_plans %>%
  sfext::rename_sf_col() %>%
  dplyr::select(plan_name = area_name, year_adopted = status, url) %>%
  dplyr::mutate(
    year_adopted = stringr::str_sub(year_adopted, start = -4),
    program = dplyr::case_when(
      stringr::str_detect(plan_name, "(SNAP)") ~ "Strategic Neighborhood Action Plan (SNAP)",
      stringr::str_detect(plan_name, "[:space:]TAP") ~ "Urban Land Institute Technical Assistance Panel (TAP)",
      stringr::str_detect(plan_name, "[:space:]INSPIRE") ~ "INSPIRE (Investing in Neighborhoods and Schools to Promote Improvement, Revitalization, and Excellence)"
    )
  ) %>%
  dplyr::relocate(geometry, .after = program) %>%
  dplyr::relocate(program, .after = year_adopted)

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
zoning_path <- "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Zoning/FeatureServer/0"

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

zoning <-
  dplyr::left_join(
    x = zoning,
    y = zoning_legend %>% rename(zoning = code),
    by = "zoning"
  ) #  %>%
dplyr::left_join(zoning_legend, by = c("overlay" = "code"), suffix = c("_zoning", "_overlay"))

usethis::use_data(zoning, overwrite = TRUE)



## MTA Bus Lines ----

# Import Maryland Transit Administration bus line data (current as of July 12, 2020)
# https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1

mta_bus_lines <-
  getdata::get_esri_data(
    "https://geodata.md.gov/imap/rest/services/Transportation/MD_Transit/FeatureServer/10",
    crs = selected_crs
  ) %>%
  dplyr::select(-c(distribution_policy, objectid))

mta_bus_lines <- mta_bus_lines %>%
  sfext::rename_sf_col() %>%
  dplyr::mutate(
    frequent = dplyr::case_when(
      stringr::str_detect(route_number, "- Supplemental Service$") ~ FALSE,
      stringr::str_detect(route_number, "^CityLink") ~ TRUE,
      route_number %in% c("22", "26", "80", "54", "30", "85") ~ TRUE,
      TRUE ~ FALSE
    ),
    school = dplyr::case_when(
      stringr::str_detect(route_number, "- Supplemental Service$") ~ TRUE,
      TRUE ~ FALSE
    ),
    route_abb = dplyr::case_when(
      route_number == "CityLink BLUE" ~ "BL",
      route_number == "CityLink BROWN" ~ "BR",
      route_number == "CityLink GOLD" ~ "GD",
      route_number == "CityLink GREEN" ~ "GR",
      route_number == "CityLink LIME" ~ "LM",
      route_number == "CityLink NAVY" ~ "NV",
      route_number == "CityLink ORANGE" ~ "OR",
      route_number == "CityLink PINK" ~ "PK",
      route_number == "CityLink RED" ~ "RD",
      route_number == "CityLink SILVER" ~ "SV",
      route_number == "CityLink YELLOW" ~ "YW",
      route_number == "CityLink PURPLE" ~ "PR",
      route_number == "CityLink BLUE - Supplemental Service" ~ "BL SCH",
      route_number == "CityLink BROWN - Supplemental Service" ~ "BR SCH",
      route_number == "CityLink GOLD - Supplemental Service" ~ "GD SCH",
      route_number == "CityLink GREEN - Supplemental Service" ~ "GR SCH",
      route_number == "CityLink NAVY - Supplemental Service" ~ "NV SCH",
      route_number == "CityLink ORANGE - Supplemental Service" ~ "OR SCH",
      route_number == "CityLink PURPLE - Supplemental Service" ~ "PR SCH",
      route_number == "CityLink RED - Supplemental Service" ~ "RD SCH",
      route_number == "CityLink SILVER - Supplemental Service" ~ "SV SCH",
      school ~ paste(stringr::str_remove(route_number, " - Supplemental Service$"), "SCH"),
      TRUE ~ route_number
    ),
    .before = geometry
  ) %>%
  dplyr::relocate(route_abb, .after = route_number)

usethis::use_data(mta_bus_lines, overwrite = TRUE)

## MTA Bus Stops ----

mta_bus_stops <-
  getdata::get_esri_data("https://geodata.md.gov/imap/rest/services/Transportation/MD_Transit/FeatureServer/9",
    crs = selected_crs
  ) %>%
  sfext::rename_sf_col()

frequent_lines <- dplyr::filter(mta_bus_lines, frequent) %>%
  dplyr::pull(route_abb)

mta_bus_stops <- mta_bus_stops %>%
  dplyr::mutate(
    stop_name = stringr::str_squish(stop_name),
    shelter = dplyr::if_else(shelter == "Yes", TRUE, FALSE),
    direction = dplyr::case_when(
      stringr::str_detect(stop_name, "[:space:]nb") ~ "nb",
      stringr::str_detect(stop_name, "[:space:]eb") ~ "eb",
      stringr::str_detect(stop_name, "[:space:]sb") ~ "sb",
      stringr::str_detect(stop_name, "[:space:]wb") ~ "wb"
    ), # mb? fs?,
    stop_location =
      dplyr::case_when(
        stringr::str_detect(stop_name, "[:space:]fs") ~ "fs", # far side?
        stringr::str_detect(stop_name, "[:space:]mb") ~ "mb", # mid block?
        stringr::str_detect(stop_name, "[:space:]opp[:space:]") ~ "opp",
        stringr::str_detect(stop_name, "[:space:]mid[:space:]") ~ "mid",
        stringr::str_detect(stop_name, "[:space:]ns") ~ "ns" # near side?
      ),
    routes_served = stringr::str_replace_all(
      routes_served,
      c(
        "GREEN" = "GR",
        "BLUE" = "BL",
        "BROWN" = "BR",
        "GOLD" = "GD",
        "GREEN" = "GR",
        "LIME" = "LM",
        "NAVY" = "NV",
        "ORANGE" = "OR",
        "PINK" = "PK",
        "RED" = "RD",
        "SILVER" = "SV",
        "YELLOW" = "YW",
        "PURPLE" = "PR"
      )
    ),
    routes_served_sep = stringr::str_remove_all(routes_served, "[:space:]"),
    routes_served_sep = stringr::str_split(routes_served_sep, pattern = ";")
  ) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    frequent = any(routes_served_sep %in% frequent_lines)
  ) %>%
  dplyr::as_tibble() %>%
  sf::st_as_sf() %>%
  dplyr::relocate(stop_id, .before = stop_name) %>%
  dplyr::relocate(geometry, .after = tidyselect::everything()) %>%
  dplyr::select(-c(distribution_policy, routes_served_sep))

mta_bus_stops <- mta_bus_stops %>%
  dplyr::select(-objectid)

usethis::use_data(mta_bus_stops, overwrite = TRUE)

## MTA SubwayLink Lines ----

mta_subway_lines <- esri2sf::esri2sf("https://geodata.md.gov/imap/rest/services/Transportation/MD_Transit/FeatureServer/5")

mta_subway_lines <- janitor::clean_names(mta_subway_lines, "snake")

mta_subway_lines <- sf::st_transform(mta_subway_lines, 2804)

mta_subway_lines <- dplyr::select(mta_subway_lines,
  id = objectid,
  rail_name,
  mode = trans_mode,
  tunnel,
  direction,
  miles,
  status = line_statu,
  geometry = geoms
)

usethis::use_data(mta_subway_lines, overwrite = TRUE)

## Charm City Circulator Stopsand Routes ----

circulator_routes <- esri2sf::esri2sf("https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/1") %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::select(
    route_name,
    alt_route_name = alt_name,
    geometry = geoms
  )

usethis::use_data(circulator_routes, overwrite = TRUE)

circulator_stops <- esri2sf::esri2sf("https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/0") %>%
  sf::st_transform(selected_crs) %>%
  janitor::clean_names("snake") %>%
  dplyr::mutate(
    route = stringr::str_to_sentence(route)
  ) %>%
  dplyr::select(
    stop_num = stop,
    stop_location = stop_locat,
    corner,
    route_name = route,
    geometry = geoms
  ) %>%
  naniar::replace_with_na(list(corner = c(" ", "  ", "n/a")))

usethis::use_data(circulator_stops, overwrite = TRUE)

## MTA SubwayLink Stations ----
# https://data.imap.maryland.gov/datasets/maryland::maryland-transit-metro-subwaylink-stations/about
mta_subway_stations <- sf::read_sf("https://opendata.arcgis.com/datasets/76579336f7be446a9111eacf46c933b0_4.geojson")

mta_subway_stations <- janitor::clean_names(mta_subway_stations, "snake")

mta_subway_stations <- sf::st_transform(mta_subway_stations, 2804)

mta_subway_stations <- dplyr::select(mta_subway_stations,
  id = objectid_1,
  name,
  address,
  city,
  state,
  mode = transit_mo,
  avg_wkdy,
  avg_wknd,
  facility_type,
  geometry
)

usethis::use_data(mta_subway_stations, overwrite = TRUE)

# MTA Light Rail Line

mta_light_rail_lines <- sf::read_sf("https://opendata.arcgis.com/datasets/c7cb3ce4aaac4deb921e2a154cf22205_3.geojson") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    id = objectid_1,
    rail_name,
    mode = trans_mode,
    tunnel,
    direction,
    miles,
    status = line_statu,
    geometry
  )

usethis::use_data(mta_light_rail_lines, overwrite = TRUE)

# MTA Light Rail Stations

mta_light_rail_stations <- sf::read_sf("https://opendata.arcgis.com/datasets/c65b32c3c23f43169797f7b762ba1770_2.geojson") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    id = objectid_1,
    name,
    address,
    city,
    state,
    zipcode = zip,
    mode = transit_mo,
    avg_wkdy,
    avg_wknd,
    facility_type,
    geometry
  )

usethis::use_data(mta_light_rail_stations, overwrite = TRUE)

## MTA MARC Train Lines

# "https://services.arcgis.com/njFNhDsUCentVYJW/arcgis/rest/services/DC_Metro_Bus_Train_Lines_Stations/FeatureServer/10"

mta_marc_lines <-
  sf::read_sf("https://opendata.arcgis.com/datasets/de0efbe9f8884ac5aa69864b6b3ff633_10.geojson") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    id = objectid_1,
    rail_name,
    mode = trans_mode,
    tunnel,
    direction,
    miles,
    status = line_statu,
    geometry
  )

usethis::use_data(mta_marc_lines, overwrite = TRUE)

mta_marc_stations <-
  sf::read_sf("https://opendata.arcgis.com/datasets/e476dcb6dc154683ab63f23472bed5d6_6.geojson") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs) %>%
  dplyr::select(
    id = objectid_1,
    name,
    address,
    city,
    state,
    zipcode = zip,
    line_name,
    mode = transit_mo,
    avg_wkdy,
    avg_wknd,
    facility_type,
    geometry
  )

usethis::use_data(mta_marc_stations, overwrite = TRUE)


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
  dplyr::mutate(
    sha_class_label = forcats::fct_relevel(sha_class_label, sha_class_label_list$sha_class_label),
    dplyr::across(
      tidyselect::where(is.character),
      ~ .x %>%
        stringr::str_trim() %>%
        stringr::str_squish()
    )
  ) %>%
  naniar::replace_with_na(list(fullname = "", feanme = "")) %>%
  dplyr::left_join(subtype_label, by = "subtype") %>%
  dplyr::relocate(subtype_label, .after = subtype) %>%
  dplyr::rename(geometry = geoms)

usethis::use_data(streets, overwrite = TRUE)

# Named intersections ----

intersections <- baltimore_city %>%
  buffer_area(dist = 200) %>%
  get_area_data(data = "edge_of_pavement") %>%
  dplyr::filter(type == "RDINT") %>%
  dplyr::select(-type)

area_around_intersections <- intersections %>%
  buffer_area(dist = 20)

intersection_pts <- intersections %>%
  sf::st_centroid()

intersection_streets <- streets %>%
  dplyr::mutate(fullname = stringr::str_trim(stringr::str_squish(fullname))) %>%
  dplyr::group_by(fullname) %>%
  dplyr::summarise(geometry = sf::st_union(geometry)) %>%
  sf::st_intersection(area_around_intersections)

named_intersections <- intersection_streets %>%
  sf::st_drop_geometry() %>%
  dplyr::group_by(id) %>%
  dplyr::summarise(
    name = stringr::str_replace(paste0(fullname, collapse = " & "), "^&|^[:space:]&[:space:]", "")
  ) %>%
  naniar::replace_with_na(replace = list(name = ""))

named_intersections_sf <- intersection_pts %>%
  dplyr::left_join(named_intersections) %>%
  dplyr::rename(geometry = geom)

named_intersections <- named_intersections_sf

usethis::use_data(named_intersections, overwrite = TRUE)

request_types <- request_types %>%
  mutate(
    request_type = case_when(
      request_type == "SW-Clean Up (Mayor�s Spring Cleanup)" ~ "SW-Clean Up (Mayor’s Spring Cleanup)",
      request_type == "SW-Clean Up (Mayor�s Fall Cleanup)" ~ "SW-Clean Up (Mayor’s Fall Cleanup)",
      TRUE ~ request_type
    )
  )

usethis::use_data(request_types, overwrite = TRUE)


baltimore_msa_water <- baltimore_msa_counties$countyfp %>%
  purrr::map_dfr(
    ~ tigris::area_water(state = "MD", county = .x)
  ) %>%
  sf::st_simplify(dTolerance = 1)

baltimore_msa_water <- baltimore_msa_water %>%
  st_transform(2804) %>%
  janitor::clean_names("snake")

usethis::use_data(baltimore_msa_water, overwrite = TRUE)


url <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/CHAS_Historic_DIST_ADDED/MapServer/0"

chap_districts_geodata <- getdata::get_esri_data(url, crs = 2804)

chap_district_info <- tibble::tribble(
  ~name, ~url, ~deed_covenant, ~overlaps_nr_district,
  "Ashburton", "https://chap.baltimorecity.gov/ashburton", FALSE, FALSE,
  "Auchentoroly Terrace", "http://chap.baltimorecity.gov/auchentorolyterrace", FALSE, TRUE,
  "Bancroft Park", "http://chap.baltimorecity.gov/historic-districts/maps/bancroftpark", FALSE, FALSE,
  "Barclay/Greenmount", "http://chap.baltimorecity.gov/historic-districts/maps/barclaygreenmount", FALSE, FALSE,
  "Better Waverly", "http://chap.baltimorecity.gov/historic-districts/maps/betterwaverly", FALSE, FALSE,
  "Bolton Hill", "http://chap.baltimorecity.gov/historic-districts/maps/boltonhill", FALSE, TRUE,
  "Butcher's Hill", "http://chap.baltimorecity.gov/historic-districts/maps/butchershill", FALSE, TRUE,
  "Dickeyville", "http://chap.baltimorecity.gov/historic-districts/maps/dickeyville", FALSE, TRUE,
  "Eutaw Place/Madison Park", "http://chap.baltimorecity.gov/historic-districts/maps/eutawplaceandmadisonpark", FALSE, TRUE,
  "Federal Hill", "http://chap.baltimorecity.gov/historic-districts/maps/federalhill", FALSE, TRUE,
  "Fells Point", "http://chap.baltimorecity.gov/historic-districts/maps/fells-point", FALSE, TRUE,
  "Five & Dime", "https://chap.baltimorecity.gov/five-and-dime-historic-district", FALSE, TRUE,
  "Franklintown", "http://chap.baltimorecity.gov/historic-districts/maps/franklintower", FALSE, TRUE,
  "Howard Street Commercial", "https://chap.baltimorecity.gov/howard-street-commercial-historic-district", FALSE, TRUE,
  "Hunting Ridge", "http://chap.baltimorecity.gov/historic-districts/maps/huntingridge", FALSE, FALSE,
  "Jonestown", "http://chap.baltimorecity.gov/historic-districts/maps/jonestown", FALSE, FALSE,
  "Loft", "http://chap.baltimorecity.gov/historic-districts/maps/loft", FALSE, TRUE,
  "Madison Park", "http://chap.baltimorecity.gov/historic-districts/maps/madisonpark", FALSE, TRUE,
  "Mill Hill/Deck of Cards", "https://chap.baltimorecity.gov/historic-districts/maps/2600blockmillhilldeckofcardswilkinsave", FALSE, FALSE,
  "Mount Royal Terrace", "http://chap.baltimorecity.gov/mount-royal-terrace", FALSE, TRUE,
  "Mount Vernon", "http://chap.baltimorecity.gov/mount-vernon", FALSE, TRUE,
  "Mount Washington", "http://chap.baltimorecity.gov/mount-washington", FALSE, FALSE,
  "Oldtown Mall", "https://chap.baltimorecity.gov/oldtown-mall-historic-district", FALSE, FALSE,
  "Otterbein", "http://chap.baltimorecity.gov/otterbein", TRUE, FALSE,
  "Perlman Place", "http://chap.baltimorecity.gov/perlman-place", FALSE, FALSE,
  "Railroad", "http://chap.baltimorecity.gov/railroad", FALSE, FALSE,
  "Ridgely's Delight", "http://chap.baltimorecity.gov/rigleys-delight", FALSE, TRUE,
  "Seton Hill", "http://chap.baltimorecity.gov/seton-hill", FALSE, TRUE,
  "Sharp-Leadenhall", "https://chap.baltimorecity.gov/sharp-leadenhall", FALSE, FALSE,
  "Stirling Street", "http://chap.baltimorecity.gov/stirling-street", FALSE, FALSE,
  "Ten Hills", "http://chap.baltimorecity.gov/ten-hills", FALSE, FALSE,
  "Union Square", "http://chap.baltimorecity.gov/union-square", FALSE, TRUE,
  "Upton's Marble Hill", "http://chap.baltimorecity.gov/uptons-marble-hill", FALSE, TRUE,
  "Washington Hill", "http://chap.baltimorecity.gov/washington-hill", FALSE, TRUE,
  "Waverly", "http://chap.baltimorecity.gov/waverly", FALSE, FALSE,
  "Woodberry", "http://chap.baltimorecity.gov/woodberry", FALSE, TRUE,
  "Wyndhurst", "http://chap.baltimorecity.gov/wyndhurst", FALSE, FALSE
)


chap_districts <- chap_districts_geodata |>
  dplyr::filter(stringr::str_detect(cha_pcode_ty, "^A")) |>
  sfext::rename_sf_col() |>
  dplyr::rename(name = area_name) |>
  dplyr::mutate(
    name = dplyr::case_when(
      name == "Barclay/Greenmount -  People's Homestead" ~ "Barclay/Greenmount",
      name == "Eutaw Place/Madison Place" ~ "Eutaw Place/Madison Park",
      name == "Mt. Royal Terrace" ~ "Mount Royal Terrace",
      name == "Wilkens Avenue" ~ "Mill Hill/Deck of Cards",
      .default = name
    )
  ) |>
  dplyr::left_join(chap_district_info, by = "name") |>
  dplyr::mutate(
    acres = as.numeric(units::set_units(sf::st_area(geometry), "acres"))
  ) |>
  dplyr::select(
    name,
    contact_name = cntct_nme, url, deed_covenant, overlaps_nr_district, acres, geometry
  )

usethis::use_data(chap_districts, overwrite = TRUE)
