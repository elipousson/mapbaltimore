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

# Get rivers and streams data

md_water_path <- "https://geodata.md.gov/imap/rest/services/Hydrology/MD_Waterbodies/FeatureServer/2"
md_water <- esri2sf::esri2sf(md_water_path)

baltimore_water <- md_water %>%
  sf::st_transform(2804) %>%
  sf::st_intersection(baltimore_city) %>%
  dplyr::select(
    layer = LAYER,
    geometry = geoms
  )

usethis::use_data(baltimore_water, overwrite = TRUE)

