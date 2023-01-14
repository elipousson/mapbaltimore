## code to prepare `baltimore_arcgis_index` dataset goes here
library(dplyr)

clean_esriIndex <- function(x) {
  x %>%
    dplyr::arrange(url) %>%
    dplyr::distinct(url, .keep_all = TRUE) %>%
    dplyr::mutate(
      url = stringr::str_replace(url, "services//", "services/"),
      nm = dplyr::case_when(
        (serviceType == "FeatureServer") & !is.na(geometryType) ~ janitor::make_clean_names(name),
        (serviceType == "MapServer") & !is.na(geometryType) ~ janitor::make_clean_names(glue::glue("{name} map")),
        !is.na(geometryType) ~ janitor::make_clean_names(glue::glue("{name} {serviceType}")),
        TRUE ~ janitor::make_clean_names(glue::glue("{name} {urlType}"))
      ),
      nm = stringr::str_remove(nm, "_2$"),
      .after = "name"
    )
}

geodata_gis_index <-
  esri2sf::esriIndex(
    url = "https://geodata.baltimorecity.gov/egis/rest/services",
    recurse = TRUE
  ) %>%
  clean_esriIndex() %>%
  dplyr::filter(!stringr::str_detect(url, "Internal|internal")) %>%
  dplyr::filter(!stringr::str_detect(url, "Payment"))

openbaltimore_gis_index <-
  esri2sf::esriIndex(
    url = "https://gisdata.baltimorecity.gov/egis/rest/services",
    recurse = TRUE
  )

openbaltimore_gis_index <-
  openbaltimore_gis_index %>%
  clean_esriIndex() %>%
  dplyr::filter(!stringr::str_detect(url, "CAD911"))

egis_gis_index <-
  esri2sf::esriIndex(
    url =  "https://egis.baltimorecity.gov/egis/rest/services",
    recurse = TRUE
  )

egis_gis_index <-
  clean_esriIndex(egis_gis_index)

opendata_gis_index <-
  bind_rows(
    esri2sf::esriIndex(
      url = "https://opendata.baltimorecity.gov/egis/rest/services/Hosted",
      recurse = TRUE
    ),
    esri2sf::esriIndex(
      url = "https://opendata.baltimorecity.gov/egis/rest/services/NonSpatialTables",
      recurse = TRUE
    ),
    esri2sf::esriIndex(
      url = "https://opendata.baltimorecity.gov/egis/rest/services/OpenBaltimore",
      recurse = TRUE
    )
  )

opendata_gis_index <-
  clean_esriIndex(opendata_gis_index)

baltimore_gis_index <-
  dplyr::bind_rows(
    geodata_gis_index,
    openbaltimore_gis_index,
    egis_gis_index,
    opendata_gis_index
  )

usethis::use_data(baltimore_gis_index, overwrite = TRUE)
