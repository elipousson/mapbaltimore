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
  dplyr::filter(PUMACE10 %in% c("00801", "00802", "00803", "00804", "00805")) %>%
  janitor::clean_names("snake")

usethis::use_data(baltimore_pumas, overwrite = TRUE)

# Make a weighted dataframe of neighborhoods and tracts for use with the cwi package
# Based on https://github.com/CT-Data-Haven/cwi/blob/master/data-raw/make_neighborhood_shares.R

library(mapbaltimore)

# Make crosswalk dataframe for blocks and tracts
blocks_xwalk <- baltimore_blocks %>%
  sf::st_drop_geometry() %>%
  dplyr::left_join(sf::st_drop_geometry(baltimore_tracts), by = c("tractce10" = "tractce")) %>%
  dplyr::select(block = geoid10, tract = geoid, block_name = name10, tract_name = namelsad)

blocks_pop <- tidycensus::get_decennial(geography = "block",
                                        variables = "H013001", # Total households
                                        state = "24",
                                        county = "510",
                                        year = 2010,
                                        sumfile = "sf1",
                                        geometry = TRUE) %>%
  janitor::clean_names()


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
