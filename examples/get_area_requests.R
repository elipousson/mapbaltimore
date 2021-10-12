# Get dirty alley service requests for Edmondson Village in 2020 and 2021
area <- get_area("neighborhood", "Edmondson Village")

requests <-
  purrr::map_dfr(
    c(2021, 2020),
    ~ get_area_requests(area = area, year = .x, request_type = "SW-Dirty Alley")
  )
