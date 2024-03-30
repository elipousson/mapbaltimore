library(dplyr)
library(mapbaltimore)
library(sfext)
library(getdata)

inspire_path <- "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/19"

inspire_path <- "https://services1.arcgis.com/43Lm3JYE3nM91DAF/ArcGIS/rest/services/INSPIRE_Planning_Areas/FeatureServer/0"

inspire_source <-
  sfext::read_sf_ext(url = inspire_path) %>%
  sfext::rename_sf_col() %>%
  dplyr::mutate(
    plan_name_short = if_else(
      plan_name_short == "Mary E Rodman ES",
      "Mary E. Rodman ES",
      plan_name_short
    )
  ) |>
  sf::st_transform(2804)

baybrook <- inspire_source %>%
  dplyr::filter(plan_name == "Bay Brook Elementary/Middle School INSPIRE") %>%
  dplyr::mutate(
    plan_name_short = "Bay Brook EMS"
  ) |>
  st_buffer_ext(
    dist = .25,
    unit = "mi"
  ) %>%
  select(plan_name_short)

douglass <- get_location(
  bcpss::bcps_programs_SY2021,
  name = c("Frederick Douglass H"),
  name_col = "program_name_short",
  crs = 2804
) |>
  st_buffer_ext(
    dist = .25,
    unit = "mi"
  )

coleman <- inspire_source |>
  dplyr::filter(
    plan_name_short == "Robert Coleman ES"
  ) |>
  mutate(
    geometry = sf::st_union(geometry, douglass$geometry)
  )

plans_geometry <- inspire_source |>
  dplyr::filter(!(plan_name_short %in% c("Robert Coleman ES", "Bay Brook EMS"))) |>
  dplyr::bind_rows(
    coleman,
    baybrook
  ) |>
  dplyr::select(plan_name_short)

plans_source <- rairtable::list_records(
  base = "appZPNXZR398hkvm9",
  table = "tbljHGkeDOlS1MlUi",
  view = "viw1SWsKcrnvqoMpq", # Public view
  cell_format = "string"
)

plans <- plans_source |>
  janitor::clean_names() |>
  dplyr::left_join(
    plans_geometry,
    by = dplyr::join_by(plan_name_short)
  ) |>
  sf::st_as_sf()

inspire_plans <- plans %>%
  mutate(
    program_numbers = stringr::str_remove(program_numbers, pattern = "[:space:]"),
    program_numbers = stringr::str_split(program_numbers, pattern = ",")
  ) |>
  select(
    plan_name,
    plan_name_short,
    overall_status,
    inspire_lead_planner,
    plan_url,
    year_launched,
    year_adopted,
    adoption_status,
    adoption_date,
    document_url,
    recommendation_report_status,
    recommendation_report_url,
    kick_off_presentation_date,
    launch_date_target,
    walking_route_id_target_date,
    recommendations_date_target,
    commission_review_date_target,
    implementation_status,
    program_numbers,
    planning_districts,
    neighborhoods,
    council_districts
  )

inspire_plans <-
  inspire_plans %>%
  sf::st_cast("MULTIPOLYGON")

use_data(inspire_plans, overwrite = TRUE)
