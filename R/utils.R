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
