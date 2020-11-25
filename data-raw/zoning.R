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

adopted_plans_since_2010 <- adopted_plans %>%
  filter(year_adopted >= 2010)

adopted_plans_since_2010_union <- sf::st_union(adopted_plans_since_2010) %>%
  sf::st_sf()

adopted_plans_since_2010_union$name <- "Adopted plans since 2010"

adopted_plans_since_2010_tracts <- get_area_census_geography(area = adopted_plans_since_2010_union,
                                                             geography = "tract")
adopted_plans_since_2010_acs <- get_acs_table(adopted_plans_since_2010_tracts,
              geography = "tract",
              table_id = "B25106")



selected_area <- get_area(area_type = "neighborhood",
                          area_name = "East Baltimore Midway")

selected_tracts <- get_area_census_geography(area = selected_area,
                                             geography = "tract")

housing_table <- get_acs_table(selected_tracts,
                               geography = "tract",
                               table_id = "B25106")

sum_secondary <- housing_table %>%
  dplyr::filter(!is.na(label_secondary)) %>%
  dplyr::filter(is.na(label_tertiary)) %>%
  group_by(label_secondary) %>%
  summarise(
    total = sum(estimate)
  )

sum_tertiary <- housing_table %>%
  dplyr::filter(!is.na(label_secondary)) %>%
  dplyr::filter(!is.na(label_tertiary)) %>%
  group_by(label_secondary, label_tertiary) %>%
  summarise(
    total = sum(estimate)
  )


housing_table %>%

# Plot household income by tenure
plot_acs_table(selected_tracts,
               geography = "tract",
               table_id = "B25106",
               level = "secondary") + #acs_plot_theme +
  labs(title = "Tenure by Household Income in the Past 12 Months",
       x = "Household income",
       y = "Total households",
       fill = "Tenure")


# Plot home value
plot_acs_table(selected_tracts,
               geography = "tract",
               table_id = "B25075",
               level = "primary") + acs_plot_theme +
  labs(x = "Home value ($)",
       y = "Houses")

plot_acs_table(selected_tracts,
               geography = "tract",
               table_id = "B25063",
               level = "secondary") +
  acs_plot_theme + guides(fill = "none") +
  labs(x = "Gross rent ($)",
       y = "Rental units")


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
