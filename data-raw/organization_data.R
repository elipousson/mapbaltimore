
# Set projected CRS (NAD83(HARN) / Maryland, meters)
selected_crs <- 2804

library(magrittr)

# NDC Projects

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

usethis::use_data(ndc_projects, overwrite = TRUE)


# Explore Baltimore Heritage stories

explore_baltimore <- jsonlite::fromJSON("https://explore.baltimoreheritage.org/items/browse?output=mobile-json")

explore_baltimore <- explore_baltimore$items %>%
  dplyr::mutate(
    url = paste0("https://explore.baltimoreheritage.org/items/show/",id)
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
