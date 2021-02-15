esri_sources <- tibble::tribble(
  ~name, ~slug, ~url, ~source, ~source_url, ~esri_server,
  "Maryland Food Stores 2017-2018", "md_food_stores_2017_2018", "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/218/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/c4a2bd61eaac4425b3e2e9c40735a7ae_218", "MapServer",
  "Farmers Markets 2020", "farmers_markets_2020", "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/481/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/a62650c0ae6d46ecbe199108c1125019_239", "MapServer",
  "Baltimore City Food Stores 2016", "baltimore_food_stores_2016", "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/217/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/650fa48f80ae46ef9843171703ff96f0_217", "MapServer",
  "Completed City Demo", "baltimore_demolitions", "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/0/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/completed-city-demo", "FeatureServer",
  "Contour 2ft", "contour_2ft", "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxBoundaries/MapServer/26/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/contour-2ft-1", "MapServer",
  "Contours 10ft", "contours_10ft", "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Contours_10ft/FeatureServer/0/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/contours-10ft-1", "FeatureServer",
  "Vacant Building Notices Open", "open_vacant_building_notices", "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/1/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/vacant-building-notices-open", "FeatureServer",
  "Liquor Licenses", "liquor_licenses", "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Liquor_Licenses/FeatureServer/0/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/liquor-licenses", "FeatureServer",
  "Fixed Speed Cameras", "fixed_speed_cameras", "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Fixed_Speed_Cameras/FeatureServer/0/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/fixed-speed-cameras", "FeatureServer",
  "Red Light Cameras", "red_light_cameras", "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Red_Light_Cameras/FeatureServer/0/", "Open Baltimore", "https://data.baltimorecity.gov/datasets/red-light-cameras-1", "FeatureServer",
  "Edge of Pavement", "edge_of_pavement", "https://maps.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/MapServer/0/", NA, NA, "MapServer"
)


usethis::use_data(esri_sources, internal = TRUE)
