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
      "baltimore_city"
    ),
    package = pkgname,
    envir = parent.env(environment())
  )
}

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
get_index_var <- function (nm = NULL, index = NULL, var = NULL, id = "nm") {
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

