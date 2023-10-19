library(dplyr)
library(stringr)

url <- "https://services1.arcgis.com/UWYHeuuJISiGmgXx/arcgis/rest/services/recreationCenter2023/FeatureServer"

rec_centers_source <- esri2sf::esri2sf(url, crs = 2804)

rec_centers <- rec_centers_source |>
  getdata::rename_with_xwalk(
    xwalk = tibble::tribble(
      ~label, ~variable,
      "OBJECTID", "OBJECTID",
      "street_address", "ADDRESS",
      "address", "addressFull",
      "center_type", "TYPE",
      "school_name", "schoolName",
      "center_amenities", "amenity",
      "notes", "note",
      "CURRENT_", "CURRENT_",
      "operator", "OPERATOR",
      "inCivicRec", "inCivicRec",
      "inDivisionList", "inDivisionList",
      "center_assets", "civicRecAsset",
      "center_category", "CATEGORY",
      "name", "NAME",
      "recreation_district", "recDistrict",
      "park_district", "parkDstrct",
      "council_district", "cnclDistrict",
      "legislative_district", "lgsltvDstrct",
      "police_district", "policeDstrct",
      "id", "GISID",
      "geoms", "geoms"
    )
  ) |>
  dplyr::mutate(
    name_short = name,
    # FIXME: Distinguish between community center and rec center names
    name = paste0(name, " Rec Center"),
    police_district = str_to_sentence(police_district)
  ) |>
  dplyr::relocate(
    "id", "name", "name_short",
    ends_with("address"), starts_with("center"),
    "school_name", "operator", ends_with("district"),
    .before = everything()
  ) |>
  dplyr::relocate(
    "center_type",
    .before = "school_name"
  ) |>
  dplyr::select(!c("CURRENT_", "inCivicRec", "inDivisionList", "OBJECTID")) |>
  naniar::replace_with_na(
    list(
      school_name = "",
      center_amenities = "",
      notes = ""
    )
  ) |>
  sfext::rename_sf_col()

usethis::use_data(rec_centers, overwrite = TRUE)
