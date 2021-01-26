## code to prepare `parks` dataset

# Set path to city parks hosted ArcGIS MapServer layer
parks_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2"

# Import parks data with esri2sf package
parks <- esri2sf::esri2sf(parks_path) %>%
  sf::st_transform(2804) %>%  # Transform to projected CRS
  sf::st_make_valid() %>% # Make valid to avoid "Ring Self-intersection" error
  janitor::clean_names("snake") %>%  # Clean column names
  dplyr::select(name, id = park_id, address, name_alt, operator = bcrp, geometry = geoms) %>% # Select relevant columns
  dplyr::mutate(
    operator = dplyr::if_else(operator == "Y", "Baltimore City Department of Recreation and Parks", "Other"),
    area = units::set_units(sf::st_area(geometry), "acres")
  )

usethis::use_data(parks, overwrite = TRUE)

# Get water data

baltimore_water_path <- "https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/7"

baltimore_water <- esri2sf::esri2sf(baltimore_water_path)

baltimore_water <- baltimore_water %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804) %>%
  dplyr::select(
    name,
    type,
    subtype,
    symbol,
    water,
    geometry = geoms
  )

usethis::use_data(baltimore_water, overwrite = TRUE)
