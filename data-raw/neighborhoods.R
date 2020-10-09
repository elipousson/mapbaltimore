## code to prepare `neighborhoods` dataset

# Import neighborhood boundaries from iMAP (derived from a data set previously available on Open Baltimore)
# https://opendata.maryland.gov/Society/MD-iMAP-Maryland-Baltimore-City-Neighborhoods/dbbp-8u4u
neighborhoods_path <- "https://opendata.arcgis.com/datasets/fc5d183b20a145009eae8f8b171eeb0d_0.geojson"

neighborhoods <- sf::read_sf(neighborhoods_path)

neighborhoods <- janitor::clean_names(neighborhoods, "snake")

neighborhoods <- sf::st_transform(neighborhoods, 2804)

neighborhoods <- dplyr::rename(neighborhoods,
                               neighborhood = nbrdesc)

neighborhoods <- dplyr::select(neighborhoods,
                               label, neighborhood, geometry)

usethis::use_data(neighborhoods, overwrite = TRUE)
