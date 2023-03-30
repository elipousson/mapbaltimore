<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# mapbaltimore development

* Update `baltimore_mihp` and `explore_baltimore` spatial data (2023-03-29).
* Add new `chap_districts` spatial data  (2023-02-10).
* Add new `baltimore_gis_index` (2022-10-20) and `respagency_codes` (2023-03-29) reference data.
* Move `forcats`, `ggrepel`, `ggplot2`  `maplayer`, `naniar`, `progress`, and `readr` from Imports to Suggests.
* Remove `baltimorecensus` from Imports.

# mapbaltimore 0.1.1 (2022-10-13)

I haven't been consistent in updating versions but this is a patch update in preparation to address the issue (#3) with version control for package data and starting the deprecation process for general utility functions (#4).

Key changes since version 0.1.0.9001 include removing the dependency on `{overedge}`, adding new datasets (`inspire_plans` and `schools_21stc`) and updates to column names and attributes for `parks`, `bcps_programs`,  `bcps_zones`,  `public_art`, and surely a few others I'm missing.

# mapbaltimore 0.1.0.9001 (2022-01-10)

* Update `neighborhoods` to include a osm_id column + use "Institutional area" as a type value.
* Replace hard-coded CRS for `map_area_zoning()`
* Update `get_area_requests()` to support 2022 requests and work w/ modified column names.

# mapbaltimore 0.1.0.9000 (2022-01-10)

* Initial release!
