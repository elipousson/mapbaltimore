#' Get streets
#'
#' Get streets in Baltimore City by name with option to exclude streets by name,
#' crop to a bounding box, or to filter to selected street types or functional
#' classifications.
#'
#' @seealso get_area_streets
#'
#' @param street_name Street names to return. Required.
#' @param exclude_name Street names to exclude
#' @inheritParams filter_streets
#' @param bbox bbox to crop returned streets. Optional.
#' @param union Logical. If `TRUE`, use `st_union` to combine geometry by
#'   `fullname` of the streets.
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @example examples/get_streets.R
#' @seealso
#'  [streets]
#'  [get_area_streets()]
#' @rdname get_streets
#' @export
#' @importFrom dplyr filter
#' @importFrom stringr str_detect

get_streets <- function(street_name,
                        exclude_name = NULL,
                        street_type = NULL,
                        sha_class = NULL,
                        block_num = NULL,
                        bbox = NULL,
                        union = TRUE) {
  rlang::check_required(street_name)
  if (!is.character(street_name)) {
    cli_abort(
      "{.arg street_name} must be a character vector."
    )
  }

  named_streets <- dplyr::filter(
    streets,
    stringr::str_detect(
      fullname,
      paste0(toupper(street_name), collapse = "|")
    )
  )


  if (!is.null(exclude_name)) {
    named_streets <- dplyr::filter(
      named_streets,
      !stringr::str_detect(
        fullname,
        paste0(toupper(exclude_name), collapse = "|")
      )
    )
  }

  filter_streets(
    x = named_streets,
    sha_class = sha_class,
    street_type = street_type,
    block_num = block_num,
    union = union,
    bbox = bbox
  )
}
