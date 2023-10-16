select_crs <- 2804

# https://docs.google.com/spreadsheets/d/1vCQq4pW2_IH2T3PgipVpNohBdLVKya0wa7kKGzLPOTc/edit?usp=sharing
main_streets_data <- tibble::tribble(
  ~id,                               ~name,                                   ~url, ~funding_status,           ~name_short, ~name_abb,
   1L,         "Belair-Edison Main Street",        "http://www.belair-edison.org/",        "active",       "Belair-Edison",      "BE",
   3L, "Historic Federal Hill Main Street",                  "https://fedhill.org",        "active",        "Federal Hill",      "FH",
   4L,          "Fell’s Point Main Street", "http://www.fellspointmainstreet.org/",        "active",         "Fells Point",      "FP",
   5L,          "Highlandtown Main Street",   "http://www.ihearthighlandtown.com/",        "active",        "Highlandtown",       "H",
   6L,               "Pigtown Main Street",    "http://www.pigtownmainstreet.org/",        "active",             "Pigtown",       "P",
   7L,               "Waverly Main Street",    "http://www.waverlymainstreet.org/",        "active",             "Waverly",       "W",
   8L,   "Pennsylvania Avenue Main Street",        "http://www.pa-mainstreet.com/",        "active", "Pennsylvania Avenue",      "PA",
  10L,   "Hamilton-Lauraville Main Street",      "http://www.bmoremainstreet.com/",        "active", "Hamilton-Lauraville",      "HL",
   9L,              "Brooklyn Main Street",                                     NA,      "inactive",            "Brooklyn",       "B",
   2L,         "East Monument Main Street",                                     NA,      "inactive",       "East Monument",      "EM"
  )

# "https://www.arcgis.com/home/item.html?id=294dec422a924c509d799990610a7101"
url <- "https://services1.arcgis.com/43Lm3JYE3nM91DAF/arcgis/rest/services/MainStreets/FeatureServer/0"

main_streets <- url |>
  arcgislayers::arc_open() |>
  arcgislayers::arc_select()

main_streets <- main_streets |>
  sf::st_transform(select_crs) |>
  dplyr::select(
    id = OBJECTID#,
    # area_name = AREA_NAME,
    # name_abb = AREA_ABBR,
    # url = URL,
    # contact_name = CNTCT_NME,
    # resp_agency = CNTCT_DPT,
    # contact_phone = CNTCT_PHN,
    # contact_email = CNTCT_EML
  )

main_streets <- main_streets |>
  dplyr::left_join(main_streets_data)

usethis::use_data(main_streets, overwrite = TRUE)
