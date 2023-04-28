## Trees (exported to extdata - not yet documented)

trees_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Trees_12052017/FeatureServer/0"

trees_csa <- map_dfr(
  csas_nest$data,
  ~ esri2sf::esri2sf(trees_path, bbox = sf::st_bbox(.x))
)

trees <- trees_csa %>%
  janitor::clean_names("snake") %>%
  distinct(global_id, .keep_all = TRUE)

trees <- trees %>%
  arrange(id) %>%
  select(
    street_number = address,
    street_name = street,
    on_street = on_str,
    location_type = loc_type,
    side,
    condition,
    dbh, # Diameter at breast height
    height = tree_ht,
    multi_stem,
    spp, # Species pluralis
    cultivar,
    common,
    genus,
    x_coord,
    y_coord,
    geometry = geoms
  ) %>%
  sf::st_transform(selected_crs)

sf::write_sf(trees, "inst/extdata/trees.gpkg")

## Vegetated area (exported to extdata - not yet documented) ----

vegetated_area_path <- "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Vegetated_Area/FeatureServer/0"
vegetated_area <- esri2sf::esri2sf(vegetated_area_path) %>%
  sf::st_transform(selected_crs) %>%
  dplyr::mutate(
    area = units::set_units(sf::st_area(geoms), "acres")
  ) %>%
  dplyr::select(
    id = OBJECTID,
    area,
    geometry = geoms
  )

# mapview::mapview(vegetated_area)
sf::write_sf(vegetated_area, "inst/extdata/vegetated_area.gpkg")

# usethis::use_data(vegetated_area, overwrite = TRUE)
