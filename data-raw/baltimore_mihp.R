## code to prepare `baltimore_mihp` dataset

# Import from iMap
# https://data.imap.maryland.gov/datasets/maryland-inventory-historic-properties-maryland-inventory-of-historic-properties/data
mihp_path <- "https://geodata.md.gov/imap/rest/services/Historic/MD_InventoryHistoricProperties/FeatureServer/0"

# Import baltimore_mihp data with esri2sf package
mihp <- esri2sf::esri2sf(mihp_path)

# Clean column names
mihp <- janitor::clean_names(mihp, "snake")

# Filter to properties in Baltimore City
baltimore_mihp <- dplyr::filter(mihp, county == "Baltimore City" | county == "BaltCity,BaltCo")

# Transform to projected CRS
baltimore_mihp <- sf::st_transform(baltimore_mihp, 2804)

# Rename columns
baltimore_mihp <- dplyr::rename(baltimore_mihp,
                                mihp_id = mihpid,
                                property_id = propertyid,
                                mihp_num = mihpno,
                                name = nam,
                                alternate_name = a,
                                full_address = fulladdr)

# Remove unnecessary columns
baltimore_mihp <- dplyr::select(baltimore_mihp,
                                -c(objectid, class))

usethis::use_data(baltimore_mihp, overwrite = TRUE)
