
hmt_2017_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/25"

hmt_2017 <- esri2sf::esri2sf(hmt_2017_path) %>%
  janitor::clean_names("snake") %>%
  sf::st_transform(2804) # Transform to projected CRS

# https://planning.baltimorecity.gov/sites/default/files/FINAL_HMT2017_DataSeries_0518.pdf
hmt_2017 <- hmt_2017 %>%
  dplyr::select(geoid = bg, # all variables are derived from 2015 to 2017 data ()
                geoid_part = geo_i_dw_splt,
                cluster = mva17hrd_cd,
                median_sales_price = msp1517eo,
                sales_price_variation = vsp1517rsf, # Baltimore City real estate transactions 2015q3-2017q2
                num_sales = csp1517rsf, #
                num_foreclosure_filings = nfcl1517, # Baltimore City Circuit Court 2015q3-2017q2 foreclosure filings
                perc_foreclosure_sales = pct_fcl_sale, # Baltimore City Circuit Court 2015q3-2017q2 foreclosure filings
                perc_homeowners = phhooac6bg, # July 2017 data
                perc_permits_over10k = pct10k_prmt, # Baltimore Housing 2015q3-2017q2 Database
                vacant_lots_bldgs_per_acre_res = p_vl_vb_r_acr, # Baltimore Housing July 2017 Database
                units_per_acre_res = h_up_res_acre, # Baltimore Housing July 2017 Database
                geometry = geoms) %>%
  dplyr::mutate(
    part = dplyr::case_when(
      stringr::str_detect(geoid_part, "[:alpha:]") ~ stringr::str_extract(geoid_part, "[:alpha:]")
    ),
    cluster = dplyr::case_when(
      cluster == "NonResidential" ~ "Non-Residential",
      cluster == "Mixed Market/Subsd Rental" ~ "Mixed Market/Subsidized Rental Market",
      TRUE ~ cluster),
    perc_homeowners = dplyr::if_else(perc_homeowners != -9999, perc_homeowners / 100, 0),
    perc_foreclosure_sales = round(perc_foreclosure_sales, digits = 4),
    perc_permits_over10k = round(perc_permits_over10k, digits = 4),
    vacant_lots_bldgs_per_acre_res = round(vacant_lots_bldgs_per_acre_res, digits = 4)
  )

cluster_groups <- tibble::tribble(~cluster,  ~cluster_group,
                  "A", "A",
                  "B", "B & C",
                  "C", "B & C",
                  "D", "D & E",
                  "E", "D & E",
                  "F", "F, G, & H",
                  "G", "F, G, & H",
                  "H", "F, G, & H",
                  "I", "I & J",
                  "J", "I & J",
                  "Rental Market 1", "RM 1 & RM 2",
                  "Rental Market 2", "RM 1 & RM 2",
                  "Subsidized Rental Market", "Other Residential",
                  "Mixed Market/Subsidized Rental Market", "Other Residential",
                  "Non-Residential", "Non-Residential"
    )

hmt_2017 <- hmt_2017 %>%
  dplyr::left_join(cluster_groups, by = "cluster") %>%
  dplyr::relocate(cluster_group, .after = cluster) %>%
  dplyr::relocate(part, .after = geoid)


hmt_2017$cluster <- forcats::fct_relevel(hmt_2017$cluster, cluster_groups$cluster)
hmt_2017$cluster_group <- forcats::fct_relevel(hmt_2017$cluster_group, unique(cluster_groups$cluster_group))

usethis::use_data(hmt_2017, overwrite = TRUE)



adopted_plans_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/72"

adopted_plans <- esri2sf::esri2sf(adopted_plans_path)

adopted_plans <- janitor::clean_names(adopted_plans, "snake")

# Transform to projected CRS
adopted_plans <- sf::st_transform(adopted_plans, 2804)

adopted_plans <- adopted_plans %>%
  dplyr::select(plan = area_name, year_adopted = status, geometry = geoms) %>%
  dplyr::mutate(
    year_adopted = stringr::str_sub(year_adopted, start = -4),
    program = dplyr::case_when(
      stringr::str_detect(plan, "(SNAP)") ~ "Strategic Neighborhood Action Plan (SNAP)",
      stringr::str_detect(plan, "[:space:]TAP") ~ "Urban Land Institute Technical Assistance Panel (TAP)",
      stringr::str_detect(plan, "[:space:]INSPIRE") ~ "INSPIRE (Investing in Neighborhoods and Schools to Promote Improvement, Revitalization, and Excellence)"
    )
  )

usethis::use_data(adopted_plans, overwrite = TRUE)

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
zoning$overlay[zoning$overlay %in% c(" ", "")] <- NA

# Select relevant columns
zoning <- dplyr::select(zoning,
                        zoning,
                        overlay,
                        label,
                        geometry = geoms)

# Make valid to avoid "Ring Self-intersection" error when cropped
zoning <- sf::st_make_valid(zoning)

zoning_legend <- tibble::tribble(
     ~code,                                          ~category,                                                     ~name,
      "AU",                        "Special Purpose Districts",                       "Adult Use Overlay Zoning District",
     "BSC",                             "Industrial Districts",                      "Bio-Science Campus Zoning District",
     "C-1",                             "Commercial Districts",                   "Neighborhood Business Zoning District",
   "C-1-E",                             "Commercial Districts", "Neighborhood Business and Entertainment Zoning District",
  "C-1-VC",                             "Commercial Districts",  "Neighborhood Business Zoning District (Village Center)",
     "C-2",                             "Commercial Districts",                    "Community Commercial Zoning District",
     "C-3",                             "Commercial Districts",                      "General Commercial Zoning District",
     "C-4",                             "Commercial Districts",                        "Heavy Commercial Zoning District",
     "C-5",                             "Commercial Districts",                                       "Downtown District",
    "CBCA",           "Open-Space and Environmental Districts",    "Chesapeake Bay Critical Area Overlay Zoning District",
    "D-MU",                        "Special Purpose Districts",            "Detached Dwelling Mixed-Use Overlay District",
    "EC-1",                        "Special Purpose Districts",                      "Educational Campus Zoning District",
    "EC-2",                        "Special Purpose Districts",                      "Educational Campus Zoning District",
      "FP",           "Open-Space and Environmental Districts",                      "Floodplain Overlay Zoning District",
       "H",                        "Special Purpose Districts",                         "Hospital Campus Zoning District",
     "I-1",                             "Industrial Districts",                        "Light Industrial Zoning District",
     "I-2",                             "Industrial Districts",                      "General Industrial Zoning District",
   "IMU-1",                             "Industrial Districts",                    "Industrial Mixed-Use Zoning District",
   "IMU-2",                             "Industrial Districts",                    "Industrial Mixed-Use Zoning District",
      "MI",                             "Industrial Districts",                     "Maritime Industrial Zoning District",
     "OIC",                             "Industrial Districts",                "Office-Industrial Campus Zoning District",
    "OR-1",                        "Special Purpose Districts",                      "Office-Residential Zoning District",
    "OR-2",                        "Special Purpose Districts",                      "Office-Residential Zoning District",
      "OS",           "Open-Space and Environmental Districts",                              "Open-Space Zoning District",
      "PC",                        "Special Purpose Districts",                          "Port Covington Zoning District",
     "R-1", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
   "R-1-A", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
   "R-1-B", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
   "R-1-C", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
   "R-1-D", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
   "R-1-E", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
     "R-2", "Detached and Semi-Detached Residential Districts",  "Detached and Semi-Detached Residential Zoning District",
     "R-3", "Detached and Semi-Detached Residential Districts",                    "Detached Residential Zoning District",
     "R-4", "Detached and Semi-Detached Residential Districts",  "Detached and Semi-Detached Residential Zoning District",
     "R-5",  "Rowhouse and Multi-Family Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
     "R-6",  "Rowhouse and Multi-Family Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
     "R-7",  "Rowhouse and Multi-Family Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
     "R-8",  "Rowhouse and Multi-Family Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
     "R-9",  "Rowhouse and Multi-Family Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
    "R-10", "Detached and Semi-Detached Residential Districts",   "Rowhouse and Multi-Family Residential Zoning District",
    "R-MU",                        "Special Purpose Districts",                     "Rowhouse Mixed-Use Overlay District",
       "T",                        "Special Purpose Districts",                          "Transportation Zoning District",
   "TOD-1",                        "Special Purpose Districts",                   "Transit-Oriented Development District",
   "TOD-2",                        "Special Purpose Districts",                   "Transit-Oriented Development District",
   "TOD-3",                        "Special Purpose Districts",                   "Transit-Oriented Development District",
   "TOD-4",                        "Special Purpose Districts",                   "Transit-Oriented Development District",
     "W-1",                        "Special Purpose Districts",                      "Waterfront Overlay Zoning District",
     "W-2",                        "Special Purpose Districts",                      "Waterfront Overlay Zoning District",
    "PC-1",                        "Special Purpose Districts",                          "Port Covington Zoning District",
    "PC-2",                        "Special Purpose Districts",                          "Port Covington Zoning District",
    "PC-3",                        "Special Purpose Districts",                          "Port Covington Zoning District",
    "PC-4",                        "Special Purpose Districts",                          "Port Covington Zoning District",
  "C-5-TO",                             "Commercial Districts",                                       "Downtown District",
  "C-5-HS",                             "Commercial Districts",                                       "Downtown District",
  "C-5-DC",                             "Commercial Districts",                                       "Downtown District",
   "C-5-G",                             "Commercial Districts",                                       "Downtown District",
  "C-5-HT",                             "Commercial Districts",                                       "Downtown District",
  "C-5-IH",                             "Commercial Districts",                                       "Downtown District",
  "C-5-DE",                             "Commercial Districts",                                       "Downtown District"
  )



zoning <- zoning %>%
  dplyr::left_join(zoning_legend, by = c("zoning" = "code")) %>%
  dplyr::left_join(zoning_legend, by = c("overlay" = "code"), suffix = c("_zoning", "_overlay"))


usethis::use_data(zoning, overwrite = TRUE)
