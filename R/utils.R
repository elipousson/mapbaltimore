.onLoad <- function(libname, pkgname) {
  utils::data(
    list = c(
      "neighborhoods",
      "council_districts",
      "legislative_districts",
      "congressional_districts",
      "planning_districts",
      "police_districts",
      "csas",
      "park_districts",
      "baltimore_blocks",
      "baltimore_block_groups",
      "baltimore_tracts",
      "hmt_2017",
      "streets",
      "named_intersections",
      "request_types",
      "baltimore_city",
      "baltimore_gis_index",
      "baltimore_city_detailed",
      "baltimore_msa_water",
      "baltimore_water",
      "bcps_programs",
      "bcps_zones",
      "parks",
      "mta_bus_lines",
      "zoning"
    ),
    package = pkgname,
    envir = parent.env(environment())
  )
}

utils::globalVariables(
  c(
    "nm", "OBJECTID_1", "SUBTYPE", "geoms", "subtype", "fullname", "geometry",
    "incidentlocation", "calldatetime", "program_number", "aland10", "awater10",
    "aland", "awater", "name", "geoid10", "geoid", "esri_oid", "location",
    "longitude", "latitude", "acc_date", "date_of_birth", "age_at_crash",
    "row_id", "geo_location", "total_incidents", "slug", "objectid", "no_imprv",
    "vacind", "category_zoning", "label", "address", "bldg_no", "bldg_num",
    "category", "ciuse", "closedate", "cluster", "condition",
    "council_district", "councildistrict", "county_name", "createddate", "dbh",
    "descbldg_cat", "dhcduse1", "duedate", "est", "extd_zip", "fulladdr",
    "geoid_area", "geoid_area_in_area", "geolocation", "geom",
    "housing_market_typology2017", "improvement", "is_deleted",
    "lastactivitydate", "methodreceived", "needs_sync", "neighbor", "nt",
    "lastactivity", "outcome", "perc_geoid_in_area", "police_post",
    "policedistrict"
  )
)


# @staticimports pkg:isstatic
# is_all_null

#' Is this package installed?
#'
#' @param package Name of a package.
#' @param repo GitHub repository to use for the package.
#' @noRd
#' @importFrom rlang is_installed check_installed
is_pkg_installed <- function(pkg, repo = NULL) {
  if (!rlang::is_installed(pkg = pkg)) {
    if (!is.null(repo)) {
      pkg <- repo
    }

    rlang::check_installed(pkg = pkg)
  }
}


#' @noRd
#' @importFrom sfext st_erase
#' @importFrom getdata get_location
erase_parks <- function(x) {
  sfext::st_erase(
    x,
    getdata::get_location(
      type = neighborhoods,
      name_col = "type",
      name = "Park/open space",
      union = TRUE
    )
  )
}



#' @noRd
#' @importFrom sfext st_erase
#' @importFrom sf st_union
erase_water <- function(x) {
  sfext::st_erase(
    x,
    sf::st_union(baltimore_msa_water)
  )
}

#' @noRd
baltimore_gis_url <- function(nm = NULL) {
  get_index_var(
    nm = nm,
    index = baltimore_gis_index,
    "url"
  )
}

#' @noRd
get_index_var <- function(nm = NULL, index = NULL, var = NULL, id = "nm") {
  if (grepl(pattern = " ", x = nm)) {
    nm <- janitor::make_clean_names(nm)
  }
  if (is.data.frame(index)) {
    return(index[index[[id]] == nm, ][[var]])
  }
  if (is.list(index)) {
    index <- index[[nm]]
    if (!is.null(var)) {
      return(index[[var]])
    }
    return(index)
  }
}
