#' Validate area provided to mapping or charting function.
#'
#' Validate an area for a mapping function or another mapbaltimore function.
#'
#' @param area \code{sf} object with a column named "name."
#'
#' @export
#'
check_area <- function(area) {

  # Check if area is an sf object
  if (!("sf" %in% class(area))) {
    stop("The area must be an sf class object.")
  } else if (!("name" %in% names(area))) {
    stop("The area must have a 'name' column.")
  }
}
