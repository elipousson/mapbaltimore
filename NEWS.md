# mapbaltimore (development version)

## New data

* Added `buildings_21stc` (2023-04-28), `main_streets` (2023-10-16), `rec_centers` (2023-10-19), and `neighborhoods_2020` (2023-11-06) spatial data.
* Added `baltimore_area_xwalk` (2023-11-06) reference data.

## Updated data

* Update `adopted_plans` data (2023-10-19) to reflect new source (adds 1 new plan for 2023).
* Update `baltimore_gis_index` data (2023-05-26) to reflect currently available layers as of the update date.
* Update `parks` data to use new BCRP layer that includes community green spaces and other non-city owned open spaces (2023-10-16).
* Update `mta_bus_stops` to use current winter 2023 service data and correct issue with frequency variable where stops with frequent service had not been identified as such.
* Update `baltimore_water` data (2023-11-08) to add an acres column and fill in the name column based on intersections with the `mapmaryland::md_water` data.

## New or modified functions

* Add `get_neighborhood()` and refactor `get_baltimore_area()` for more consistency with `{getdata}` parameter names (2023-05-26).

## Other

* Update package logo and switch pkgdown site to rendering with GitHub actions (2023-06-13)

# mapbaltimore 0.1.1.9000 (2023-03-31)

## New data

* Add new `chap_districts` spatial data  (2023-02-10).
* Add new version of `legislative_districts` data and rename prior version as `legislative_districts_2012`.
* Add new `baltimore_gis_index` (2022-10-20) and `respagency_codes` (2023-03-29) reference data.

## Updated data

* Update `baltimore_mihp` and `explore_baltimore` spatial data (2023-03-29).

## New or modified functions

* Add `get_baltimore_worker_flows()` (2023-03-31) and `get_baltimore_esri_data()` function.
* Deprecate `get_area_data()` function (2023-03-31).

## Other

* Move `forcats`, `ggrepel`, `ggplot2`  `maplayer`, `naniar`, `progress`, and `readr` from Imports to Suggests.
* Remove `baltimorecensus` from Imports.

# mapbaltimore 0.1.1 (2022-10-13)

I haven't been consistent in updating versions but this is a patch update in preparation to address the issue (#3) with version control for package data and starting the deprecation process for general utility functions (#4).

Key changes since version 0.1.0.9001 include removing the dependency on `{overedge}`, adding new datasets (`inspire_plans` and `schools_21stc`) and updates to column names and attributes for `parks`, `bcps_programs`,  `bcps_zones`,  `public_art`, and surely a few others I'm missing.

# mapbaltimore 0.1.0.9001 (2022-01-10)

## Updated data

* Update `neighborhoods` to include a osm_id column + use "Institutional area" as a type value.

## New or modified functions

* Replace hard-coded CRS for `map_area_zoning()`
* Update `get_area_requests()` to support 2022 requests and work w/ modified column names.

# mapbaltimore 0.1.0.9000 (2022-01-10)

* Initial release!
