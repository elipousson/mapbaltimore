## code to prepare `zoning` dataset

# Set path to Baltimore City Department of Planning Zoning hosted ArcGIS MapServer layer
zoning_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/20"

# Import zoning data with esri2sf package
zoning <- esri2sf::esri2sf(zoning_path)

# Clean column names
zoning <- janitor::clean_names(zoning, "snake")

# Transform to projected CRS
zoning <- sf::st_transform(zoning, 2804)

# Replace blank overlay values with NA
zoning <- dplyr::mutate(zoning,
                        overlay = if_else(overlay %in% c(" ", ""), NA, overlay))

# Select relevant columns
zoning <- dplyr::select(zoning,
                            zoning, overlay, label, geoms)

# Make valid to avoid "Ring Self-intersection" error when cropped
zoning <- sf::st_make_valid(zoning)

usethis::use_data(zoning, overwrite = TRUE)
