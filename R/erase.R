#' Erase any are overlapping the geometry
#'
#' @name erase_baltimore
#' @inheritParams sfext::st_erase
#' @inheritDotParams sfext::st_erase -y
NULL

#' @rdname erase_baltimore
#' @name erase_baltimore_park
#' @export
#' @importFrom sfext st_erase
#' @importFrom getdata get_location
erase_baltimore_parks <- function(x, ...) {
  sfext::st_erase(
    x,
    # FIXME: Should this use parks instead?
    getdata::get_location(
      type = neighborhoods,
      name_col = "type",
      name = "Park/open space",
      union = TRUE
    ),
    ...
  )
}

#' @rdname erase_baltimore
#' @name erase_baltimore_water
#' @param water Type of water data to use, either `baltimore_water` or
#'   `baltimore_msa_water`.
#' @export
#' @importFrom sfext st_erase
#' @importFrom sf st_union
erase_baltimore_water <- function(x, water = c("city", "msa"), ...) {
  water <- arg_match(water)

  water <- switch (water,
    "city" = baltimore_water,
    "msa" = baltimore_msa_water
  )

  sfext::st_erase(x, water, ...)
}
