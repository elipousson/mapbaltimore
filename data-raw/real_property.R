## code to prepare `real_property` dataset

# Set path to City of Baltimore Open GIS Data Real Property
# https://gis-baltimore.opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0
# This data is a subset of the statewide data available from the Maryland State Department of Assessment and Taxation.
real_property_path <- "https://opendata.arcgis.com/datasets/b41551f53345445fa05b554cd77b3732_0.geojson"

# download.file(real_property_path, "real_property.geojson")

# Import real_property data with esri2sf package
real_property <- sf::read_sf("real_property.geojson")

# Clean column names
real_property <- janitor::clean_names(real_property, "snake")

# Transform to projected CRS
real_property <- sf::st_transform(real_property, 2804)

usethis::use_data(real_property, overwrite = TRUE)
