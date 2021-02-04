# from cwi package https://github.com/CT-Data-Haven/cwi
# https://github.com/CT-Data-Haven/cwi/blob/master/R/acs_helpers.R
acs_counties <- function(table, year, counties, state, survey, key) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "county", table = table, year = year, state = state, survey = survey, key = key)) %>%
    dplyr::mutate(NAME = stringr::str_extract(NAME, "^.+County(?=, )")) %>%
    dplyr::mutate(state = state)

  if (!identical(counties, "all")) {
    fetch <- fetch %>% dplyr::filter(NAME %in% counties | GEOID %in% counties)
  }
  fetch
}

acs_tracts <- function(table, year, tracts, counties, state, survey, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "tract", table = table, year = year, state = state, county = county, survey = survey, key = key)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(tracts, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% tracts)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

acs_blockgroups <- function(table, year, blockgroups, counties, state, survey, key) {
  fetch <- counties_to_fetch(st = state, counties = counties) %>%
    purrr::map_dfr(function(county) {
      suppressMessages(tidycensus::get_acs(geography = "block group", table = table, year = year, state = state, county = county, survey = survey, key = key)) %>%
        dplyr::mutate(county = county)
    })

  if (!identical(blockgroups, "all")) {
    fetch <- fetch %>% dplyr::filter(GEOID %in% blockgroups)
  }
  fetch %>%
    dplyr::mutate(state = state)
}

# TODO: Bring back quosures once I know how they work
acs_nhood <- function(table, year, selected_neighborhoods, counties, state, survey, name, geoid, weight, key, is_tract) {

  if(!missing(selected_neighborhoods)) {
    nhood <- dplyr::filter(neighborhoods_tracts, name %in% selected_neighborhoods$name)
  }

  geoids <- unique(dplyr::pull(nhood, geoid))
  if (is_tract) {
    fetch <- acs_tracts(table, year, geoids, counties, state, survey, key) %>%
      dplyr::rename(geoid = GEOID)
  } else {
    fetch <- acs_blockgroups(table, year, geoids, counties, state, survey, key) %>%
      dplyr::rename(geoid = GEOID)
  }

  nhood %>%
    dplyr::left_join(fetch, by = "geoid") %>%
    dplyr::group_by(variable, county, state, name) %>%
    dplyr::summarise(estimate = round(sum(estimate * weight)),
                     moe = round(tidycensus::moe_sum(moe, estimate * weight))) %>%
    dplyr::ungroup()
}



# Selected MSA is Baltimore-Columbia-Towson, MD Metro Area
acs_msa <- function(table, year, selected_msa = "12580", survey, key) {
  fetch <- suppressMessages(tidycensus::get_acs(geography = "metropolitan statistical area/micropolitan statistical area", table = table, year = year, survey = survey, key = key))
  if (!is.null(selected_msa)) {
    fetch <- fetch %>%
      dplyr::filter(GEOID %in% selected_msa)
  }

  fetch
}

# decennial API needs state-county-county sub hierarchy
# from https://github.com/CT-Data-Haven/cwi/blob/c39b5a4afb033515eab62d7832c6551c60482614/R/decennial_helpers.R
counties_to_fetch <- function(st, counties) {
  if (!is.null(counties) & !identical(counties, "all")) {
    out <- counties
  } else {
    out <- tidycensus::fips_codes %>%
      dplyr::filter(state_code == st | state_name == st) %>%
      dplyr::pull(county)
  }
  return(out)
}


############# GET CLEAN VARIABLE NAMES
# get acs variables by year, cached
clean_acs_vars <- function(year, survey = "acs5") {
  tidycensus::load_variables(year = year, survey, cache = T) %>%
    dplyr::filter(stringr::str_detect(name, "_\\d{3}E?$")) %>%
    dplyr::mutate(label = stringr::str_remove(label, "Estimate!!")) %>%
    dplyr::mutate(label = stringr::str_remove_all(label, ":")) %>%
    dplyr::mutate(name = stringr::str_remove(name, "E$"))
}


############# CHECK AVAILABILITY OF TABLE
# call clean_acs_vars, grep table number, return number & concept
acs_available <- function(tbl, year, survey) {
  acs_vars <- clean_acs_vars(year, survey)
  avail <- acs_vars %>%
    dplyr::select(-label) %>%
    dplyr::mutate(table = stringr::str_extract(name, "^[BC]\\d+[[:upper:]]?(?=_)")) %>%
    dplyr::select(table, concept) %>%
    unique() %>%
    dplyr::filter(table == tbl)
  # is_avail <- nrow(avail) > 0
  # assertthat::assert_that(is_avail, msg = stringr::str_glue("Table {tbl} for {year} {survey} is not available in the API."))
  # is_avail
  list(is_avail = nrow(avail) > 0, table = avail[["table"]], concept = avail[["concept"]])
}


#' Quickly add the labels of ACS variables
#'
#' `tidycensus::get_acs` returns an ACS table with its variable codes, which can be joined with `cwi::acs_vars18` to get readable labels. This function is just a quick wrapper around the common task of joining these two data frames.
#' @param df A data frame/tibble.
#' @param year The endyear of ACS data; defaults 2018.
#' @param survey A string: which ACS estimate to use. Defaults to 5-year (`"acs5"`), but can also be 1-year (`"acs1"`) or 3-year (`"acs3"`), though both 1-year and 3-year have limited availability.
#' @param variable The bare column name of variable codes; defaults to `variable`, as returned by `tidycensus::get_acs`.
#' @return A tibble
#' @seealso [acs_vars18]
label_acs <- function(df, year = 2018, survey = "acs5", variable = variable) {
  variable_var <- rlang::enquo(variable)
  acs_vars <- clean_acs_vars(year = year, survey = survey)
  df %>%
    dplyr::left_join(acs_vars %>% dplyr::select(-concept),
                     by = stats::setNames("name", rlang::as_label(variable_var)))
}
