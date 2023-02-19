# Get boundary for Edmondson Village
area <- get_area("neighborhood", "Edmondson Village")

# Get fallen limb requests for 2022
get_area_requests(
  area = area,
  date_range = c("2022-11-01", "2022-12-31"),
  request_type = "FOR-Fallen Limb"
)

# Get dirty alley service requests for multiple years using purrr::map_dfr()
purrr::list_rbind(
  purrr::map(
    c(2021, 2020),
    ~ get_area_requests(
      area = area,
      year = .x,
      request_type = "SW-Dirty Alley"
    )
  )
)

