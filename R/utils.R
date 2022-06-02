utils::globalVariables(c(
  "named_intersections",
  "streets"
))

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
#' @importFrom overedge st_erase get_location
erase_parks <- function(x) {
  overedge::st_erase(
    x,
    overedge::get_location(
      type = neighborhoods,
      name_col = "type",
      name = "Park/open space",
      union = TRUE
    )
  )
}



#' @noRd
#' @importFrom overedge st_erase get_location
erase_water <- function(x) {
  overedge::st_erase(
    x,
    sf::st_union(baltimore_msa_water)
  )
}
