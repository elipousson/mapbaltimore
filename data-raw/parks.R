## code to prepare `parks` dataset

# Set path to city parks hosted ArcGIS MapServer layer
parks_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2"

# Import parks data with esri2sf package
parks <- esri2sf::esri2sf(parks_path)

# Clean column names
parks <- janitor::clean_names(parks, "snake")

# Transform to projected CRS
parks <- sf::st_transform(parks, 2804)

# Select relevant columns
parks <- dplyr::select(parks,
                        park_id, name, address, name_alt, bcrp, geoms)

# Make valid to avoid "Ring Self-intersection" error when cropped
parks <- sf::st_make_valid(parks)

usethis::use_data(parks, overwrite = TRUE)
