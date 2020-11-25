## MTA Bus Lines

# Import Maryland Transit Administration bus line data (current as of July 12, 2020)
# https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1
mta_bus_lines <- sf::read_sf("https://opendata.arcgis.com/datasets/44253e8ca1a04c08b8666d212e04a900_10.geojson")

mta_bus_lines <- janitor::clean_names(mta_bus_lines, "snake")

mta_bus_lines <- sf::st_transform(mta_bus_lines, 2804)

mta_bus_lines <- dplyr::select(mta_bus_lines, -c(distribution_policy, objectid))

usethis::use_data(mta_bus_lines, overwrite = TRUE)

## MTA Bus Stops

mta_bus_stops <- sf::read_sf("https://opendata.arcgis.com/datasets/cf30fef14ac44aad92c135f6fc8adfbe_9.geojson")

mta_bus_stops <- janitor::clean_names(mta_bus_stops, "snake")

mta_bus_stops <- sf::st_transform(mta_bus_stops, 2804)

mta_bus_stops <- dplyr::select(mta_bus_stops, -c(distribution_policy, objectid))

usethis::use_data(mta_bus_stops, overwrite = TRUE)

## Import street center line
# Open Baltimore https://data.baltimorecity.gov/Geographic/Street-Centerlines/tau7-6emy
# Updated 2008

streets <- sf::read_sf("/Users/elipousson/References/baltimore_gis/street-centerline/Street_Centerline.shp") %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804)

usethis::use_data(streets, overwrite = TRUE)
