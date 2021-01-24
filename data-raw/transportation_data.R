selected_crs <- 2804

## MTA Bus Lines

# Import Maryland Transit Administration bus line data (current as of July 12, 2020)
# https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1
mta_bus_lines <- sf::read_sf("https://opendata.arcgis.com/datasets/44253e8ca1a04c08b8666d212e04a900_10.geojson")

mta_bus_lines <- janitor::clean_names(mta_bus_lines, "snake")

mta_bus_lines <- sf::st_transform(mta_bus_lines, selected_crs)

mta_bus_lines <- dplyr::select(mta_bus_lines, -c(distribution_policy, objectid))

usethis::use_data(mta_bus_lines, overwrite = TRUE)

## MTA Bus Stops

mta_bus_stops <- sf::read_sf("https://opendata.arcgis.com/datasets/cf30fef14ac44aad92c135f6fc8adfbe_9.geojson")

mta_bus_stops <- janitor::clean_names(mta_bus_stops, "snake")

mta_bus_stops <- sf::st_transform(mta_bus_stops, 2804)

mta_bus_stops <- dplyr::select(mta_bus_stops, -c(distribution_policy, objectid))

usethis::use_data(mta_bus_stops, overwrite = TRUE)

## Import street center line

streets_path <- "https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/4"

streets <- esri2sf::esri2sf(streets_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804)

sha_class_label_list <- tibble::tribble(
  ~sha_class, ~sha_class_label, ~functional_class,
  "INT", "Interstate and Principal Arterial", 1,
  "FWY", "Freeway and Expressway", 2,
  "PART", "Other Principal Arterial Street", 3,
  "MART", "Minor Arterial Street", 4,
  "COLL", "Collector Street", 5,
  "LOC", "Local Street", 7
)


functional_class_list <- tibble::tribble(
  ~sha_class, ~functional_class, ~functional_class_desc,
  "INT", 1,                                          "Interstate",
  "FWY", 2, "Principal Arterial – Other Freeways and Expressways",
  "PART", 3,                          "Principal Arterial – Other",
  "MART", 4,                                      "Minor Arterial",
  "COLL", 5,                                     "Major Collector",
  "COLL", 6,                                     "Minor Collector",
"LOC", 7,                                               "Local")

subtype_label <- tibble::tribble(
  ~subtype, ~subtype_label,
  "STRALY", "Alley",
  "STRPRD", "Paved Road",
  "STRR", "Ramp",
  "STREX", "Limited Access",
  "STRFIC", "Fictitious Centerline Segment",
  "STRNDR", NA,
  "STRURD", "Unpaved Road",
  "STCLN", "County Street Centerline",
  "STRTN", "Tunnel"
)

streets <- streets %>%
  dplyr::select(-c(objectid_1:edit_date, flag:comments, shape_leng, place, zipcode:shape_st_length)) %>%
  dplyr::left_join(sha_class_label_list, by = "sha_class") %>%
  dplyr::relocate(sha_class_label, .after = sha_class) %>%
  dplyr::mutate(sha_class_label = forcats::fct_relevel(sha_class_label, sha_class_label_list$sha_class_label)) %>%
  dplyr::left_join(subtype_label, by = "subtype") %>%
  dplyr::relocate(subtype_label, .after = subtype) %>%
  dplyr::rename(geometry = geoms)

usethis::use_data(streets, overwrite = TRUE)


md_streets_path <- "https://geodata.md.gov/imap/rest/services/Transportation/MD_HighwayPerformanceMonitoringSystem/MapServer/2"

baltimore_msa_streets <- esri2sf::esri2sf(md_streets_path,
                               bbox = sf::st_bbox(baltimore_msa_counties))

baltimore_msa_streets <- baltimore_msa_streets %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(selected_crs)

baltimore_msa_streets <- baltimore_msa_streets %>%
  dplyr::filter(county_name %in% c("ANNE ARUNDEL", "BALTIMORE CITY", "BALTIMORE", "CARROLL", "HOWARD", "HARFORD", "QUEEN ANNE'S")) %>%
  dplyr::left_join(functional_class_list, by = c("functional_class", "functional_class_desc"))


usethis::use_data(baltimore_msa_streets, overwrite = TRUE)
