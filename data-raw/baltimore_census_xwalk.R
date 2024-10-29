## code to prepare `area_xwalk` dataset goes here

library(getACS)
library(tidyverse)

block_xwalk <- make_block_xwalk(
  "MD",
  "Baltimore city"
)

area_xwalk_list_housing <- map(
  list(
    mapbaltimore::council_districts,
    mapbaltimore::neighborhoods,
    neighborhoods_2020,
    mapbaltimore::planning_districts
  ),
  \(x) {
    make_area_xwalk(
      x,
      block_xwalk,
      coverage = FALSE,
      name_col = "name",
      weight_col = "HOUSING20"
    )
  }
)

area_xwalk_housing <- purrr::list_rbind(
  set_names(
    area_xwalk_list_housing,
    c(
      "council district 2010",
      "neighborhood 2010",
      "neighborhood 2020",
      "planning district"
    )
  ),
  names_to = "geography"
)

area_xwalk_list_pop <- map(
  list(
    mapbaltimore::council_districts,
    mapbaltimore::neighborhoods,
    neighborhoods_2020,
    mapbaltimore::planning_districts
  ),
  \(x) {
    make_area_xwalk(
      x,
      block_xwalk,
      coverage = FALSE,
      name_col = "name",
      weight_col = "POP20"
    )
  }
)

area_xwalk_pop <- purrr::list_rbind(
  set_names(
    area_xwalk_list_pop,
    c(
      "council district 2010",
      "neighborhood 2010",
      "neighborhood 2020",
      "planning district"
    )
  ),
  names_to = "geography"
)

baltimore_census_xwalk <- dplyr::full_join(
  area_xwalk_pop,
  area_xwalk_housing
)

usethis::use_data(baltimore_census_xwalk, overwrite = TRUE)
