library(dplyr)
library(mapbaltimore)
library(sfext)
library(getdata)

inspire_path <-
  "https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/19"

inspire_xwalk <-
  tibble::tribble(
    ~OBJECTID, ~PRG_NUM, ~School_1, ~plan_name,
    29L, 406L, "Forest Park High", "Forest Park High School and Calvin Rodwell Elementary School INSPIRE",
    30L, 256L, "Calvin M. Rodwell Elementary", "Forest Park High School and Calvin Rodwell Elementary School INSPIRE",
    31L, 213L, "Govans Elementary", "Govans Elementary School INSPIRE",
    32L, 249L, "Medfield Heights Elementary", "Medfield Heights Elementary School INSPIRE",
    33L, 37L, "Harford Heights Elementary and Sharp-Leadenhall", "REACH! Partnership at Lake Clifton Park + Harford Heights Building INSPIRE",
    34L, 85L, "Fort Worthington Elementary", "Fort Worthington Elementary/Middle School INSPIRE",
    35L, 204L, "Mary E. Rodman Elementary", "Mary E. Rodman Elementary School INSPIRE",
    36L, 88L, "Lyndhurst Elementary", "Wildwood (Lyndhurst) Elementary/Middle School INSPIRE",
    37L, 247L, "Cross Country Elementary/Middle", "Cross Country Elementary/Middle School INSPIRE",
    38L, 223L, "Pimlico Elementary/Middle", "Pimlico Elementary/Middle School INSPIRE",
    39L, 234L, "Arlington Elementary/Middle", "Arlington Elementary School INSPIRE",
    40L, 134L, "Walter P. Carter Elementary/Middle School and Lois T. Murray", "Walter P. Carter and Lois T. Murray Elementary/Middle Schools INSPIRE",
    41L, 242L, "Northwood Elementary", "Northwood Elementary School INSPIRE",
    42L, 366L, "Baltimore Antioch Diploma Plus High School", "REACH! Partnership at Lake Clifton Park + Harford Heights Building INSPIRE",
    43L, 44L, "Montebello Elementary/Middle", "Montebello Elementary/Middle School INSPIRE",
    44L, 338L, "Highlandtown Elementary/Middle #237", "Highlandtown Elementary/Middle School #237 INSPIRE",
    45L, 228L, "John Ruhrah Elementary/Middle", "John Ruhrah Elementary/Middle School INSPIRE",
    46L, 405L, "Patterson High School and Claremont", "Patterson High School and Claremont Middle/High School Planning Area INSPIRE",
    47L, 427L, "Academy for College and Career Exploration and Independence School", "Robert Poole Building INSPIRE",
    48L, 142L, "Robert W. Coleman Elementary", "Robert W. Coleman Elementary School INSPIRE",
    49L, 61L, "John Eager Howard Elementary", "Dorothy I. Height (John Eager Howard) Elementary School INSPIRE",
    50L, 75L, "Calverton", "Billie Holiday (James Mosher) Elementary School + Katherine Johnson Global Academy (Calverton Elementary/Middle) INSPIRE",
    51L, 144L, "James Mosher Elementary", "Billie Holiday (James Mosher) Elementary School + Katherine Johnson Global Academy (Calverton Elementary/Middle) INSPIRE",
    52L, 260L, "Frederick Elementary", "Frederick Elementary School INSPIRE",
    53L, 124L, "Bay-Brook Elementary/Middle", "Bay Brook Elementary/Middle School INSPIRE",
    54L, 159L, "Cherry Hill Elementary/Middle", "Arundel Elementary and Cherry Hill Elementary/Middle Schools INSPIRE",
    55L, 164L, "Arundel Elementary/Middle", "Arundel Elementary and Cherry Hill Elementary/Middle Schools INSPIRE",
    56L, 27L, "Friendship Academy of Science and Technology", "Commodore John Rodgers Elementary/Middle School INSPIRE"
  )

inspire <-
  sfext::read_sf_ext(url = inspire_path) %>%
  left_join(inspire_xwalk)

inspire_union <- inspire %>%
  st_transform_ext(2804) %>%
  sfext::rename_sf_col() %>%
  group_by(
    plan_name
  ) %>%
  summarise(
    geometry = sf::st_combine(sf::st_union(geometry))
  )

baybrook <- inspire_union %>%
  filter(plan_name == "Bay Brook Elementary/Middle School INSPIRE")

baybrook <-
  baybrook %>%
  st_buffer_ext(
    dist = .25,
    unit = "mi"
  )

inspire_union <- inspire_union %>%
  filter(plan_name != "Bay Brook Elementary/Middle School INSPIRE") %>%
  bind_rows(baybrook)

plans <-
  getdata::get_airtable_data(
    base = "appZPNXZR398hkvm9",
    table = "tbljHGkeDOlS1MlUi",
    view = "viw1SWsKcrnvqoMpq", # Public view
    cell_format = "string",
    geometry = FALSE
  )

inspire_union_map <-
  inspire_union %>%
  left_join(plans, by = "plan_name") %>%
  relocate_sf_col()

inspire_plans <- inspire_union_map %>%
  select(
    plan_name,
    plan_name_short,
    overall_status,
    recommendation_report_status,
    adoption_status,
    implementation_status,
    inspire_lead_planner,
    plan_url,
    recommendation_report_url,
    year_launched,
    launch_date_target,
    kick_off_presentation_date,
    walking_route_id_target_date,
    recommendations_date_target,
    year_adopted,
    commission_review_date_target,
    adoption_date,
    document_url
  )

inspire_plans <-
  inspire_plans %>%
  sf::st_cast("MULTIPOLYGON")

use_data(inspire_plans, overwrite = TRUE)
