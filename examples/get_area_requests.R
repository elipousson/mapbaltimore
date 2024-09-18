# Get boundary for Edmondson Village
area <- get_baltimore_area("neighborhood", "Edmondson Village")

# Get fallen limb requests for 2022
fallen_limbs <- get_area_requests(
  area = area,
  date_range = c("2022-11-01", "2022-11-15"),
  request_type = "FOR-Fallen Limb"
)

dplyr::glimpse(fallen_limbs)

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

