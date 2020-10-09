## code to prepare `bcps_zones` dataset

# Import Baltimore City Public School attendance zones from hosted ArcGIS Feature Server layer
bcps_zones_path <- "https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/BCPSZones_2021/FeatureServer/0"

bcps_zones <- esri2sf::esri2sf(bcps_zones_path)

bcps_zones <- janitor::clean_names(bcps_zones, "snake")

bcps_zones <- sf::st_transform(bcps_zones, 2804)

bcps_zones <- dplyr::rename(bcps_zones,
                            program_number = prog_no,
                            program_name = prog_name,
                            zone_number = zone_numbe)

bcps_zones <- dplyr::select(bcps_zones,
                            fid, program_number, program_name, zone_number, zone_name, geoms)

usethis::use_data(bcps_zones, overwrite = TRUE)
