selected_crs <- 2804

csas_nest <- csas %>%
  nest_by(name)


## Parks ----

# Set path to city parks hosted ArcGIS MapServer layer
parks_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2"

# Import parks data with esri2sf package
parks <- esri2sf::esri2sf(parks_path) %>%
  sf::st_transform(selected_crs) %>%  # Transform to projected CRS
  sf::st_make_valid() %>% # Make valid to avoid "Ring Self-intersection" error
  janitor::clean_names("snake") %>%  # Clean column names
  dplyr::select(name, id = park_id, address, name_alt, operator = bcrp, geometry = geoms) %>% # Select relevant columns
  dplyr::mutate(
    operator = dplyr::if_else(operator == "Y", "Baltimore City Department of Recreation and Parks", "Other"),
    area = units::set_units(sf::st_area(geometry), "acres")
  )

usethis::use_data(parks, overwrite = TRUE)

## Trees (exported to extdata - not yet documented)

trees_path <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Trees_12052017/FeatureServer/0"

trees_csa <- map_dfr(csas_nest$data,
                     ~ esri2sf::esri2sf(trees_path, bbox = sf::st_bbox(.x)))

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
  dplyr::select(id = OBJECTID,
                area,
                geometry = geoms)

# mapview::mapview(vegetated_area)
sf::write_sf(vegetated_area, "inst/extdata/vegetated_area.gpkg")

# usethis::use_data(vegetated_area, overwrite = TRUE)

## Edge of pavement (saved to local cache) ----

edge_of_pavement_path <- "https://gisdata.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/FeatureServer/0"

edge_of_pavement_csa <- map_dfr(csas_nest$data,
        ~ esri2sf::esri2sf(edge_of_pavement_path, bbox = sf::st_bbox(.x)))

edge_of_pavement <- edge_of_pavement_csa %>%
  distinct(GlobalID, .keep_all = TRUE) %>%
  select(id = OBJECTID_1,
         type = SUBTYPE,
         geometry = geoms)

sf::write_sf(edge_of_pavement, paste0(rappdirs::user_cache_dir("mapbaltimore"), "/edge_of_pavement.gpkg"))

## Park districts (not yet documented) ----

park_districts <- esri2sf::esri2sf("https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/AGOL_BCRP_MGMT_20181220/FeatureServer/3")

park_districts <- park_districts %>%
  dplyr::select(name = AREA_NAME,
                geometry = geoms)
  sf::st_transform(selected_crs)

usethis::use_data(park_districts, overwrite = TRUE)

esri_sources[slug == "edge_of_pavement"]$source_url


# Water ----

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
