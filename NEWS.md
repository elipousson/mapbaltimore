<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# mapbaltimore 0.1.1 (2022-10-13)

I haven't been consistent in updating versions but this is a patch update in preparation to address the issue (#3) with version control for package data and starting the deprecation process for general utility functions (#4).

Key changes since version 0.1.0.9001 include removing the dependency on `{overedge}`, adding new datasets (`inspire_plans` and `schools_21stc`) and updates to column names and attributes for `parks`, `bcps_programs`,  `bcps_zones`,  `public_art`, and surely a few others I'm missing.

# mapbaltimore 0.1.0.9001 (2022-01-10)

- docs: Update pkgdown site to use Bootstrap 5
- feat: Update `neighborhoods` to include a osm_id column + use "Institutional area" as a type value
- fix: Replace hard-coded CRS for `map_area_zoning`
- fix: Update `get_area_requests` to support 2022 requests and work w/ modified column names


# mapbaltimore 0.1.0.9000 (2022-01-10)

- docs: Set-up NEWS.md to begin version tracking

