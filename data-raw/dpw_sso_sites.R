library(tidyverse)
url <- "https://dpwdata.baltimorecity.gov/pubgis/rest/services/Public/SSO_Points_Last5Years/MapServer/0"
data <- arcgislayers::arc_read(url, crs = 2804)

# glimpse(data)
# data |>
#   mapview::mapview()


data |>
  janitor::clean_names() |>
  filter(
    site_type == "Structured SSO"
  ) |>
  select(
    location, rec_waters, watershed
  ) |>
  mutate(
    location = str_trim(location),
    sso_site_id = str_extract(location, "(?<=#)[:digit:]+$")
  ) |>
  distinct(sso_site_id, .keep_all = TRUE) |>
  sf::write_sf(
    "dpw_sso_sites.geojson"
  )


usethis::use_data(dpw_sso_sites, overwrite = TRUE)
