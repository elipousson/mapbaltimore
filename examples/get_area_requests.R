# Get boundary for Edmondson Village
area <- get_area("neighborhood", "Edmondson Village")

# Get fallen limb requests for 2022
get_area_requests(
  area = area,
  year = 2022,
  request_type = "FOR-Fallen Limb"
)

# Get dirty alley service requests for multiple years using purrr::map_dfr()
purrr::map_dfr(
  c(2021, 2020),
  ~ get_area_requests(
    area = area,
    year = .x,
    request_type = "SW-Dirty Alley"
  )
)
