#' @title Get streets
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
#' @param union Logical. If `TRUE`, use \code{st_union} to combine geometry by
#'   `fullname` of the streets.
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' get_streets(street_name = "UNIVERSITY PKWY")
#'
#' get_streets(street_name = c("E FAYETTE", "ORLEANS"), block_num = c(1700, 3600))
#' }
#' @seealso
#'  \code{\link[mapbaltimore]{streets}}
#'  \code{\link[mapbaltimore]{get_area_streets}}
#' @rdname get_streets
#' @export
#' @importFrom dplyr filter mutate group_by summarise
#' @importFrom stringr str_to_upper str_detect str_trim str_squish
#' @importFrom sf st_union

get_streets <- function(street_name = NULL,
                        exclude_name = NULL,
                        street_type = NULL,
                        sha_class = NULL,
                        block_num = NULL,
                        bbox = NULL,
                        union = TRUE) {

  street_name <- stringr::str_to_upper(street_name)

  named_streets <- streets %>%
    dplyr::filter(
      stringr::str_detect(
        fullname,
        paste0(street_name, collapse = "|")
      )
    )

  if (!is.null(exclude_name)) {
    named_streets <- named_streets %>%
      dplyr::filter(!stringr::str_detect(
        fullname,
        paste0(exclude_name, collapse = "|"))
      )
  }

  named_streets <- filter_streets(
    x = named_streets,
    sha_class = sha_class,
    street_type = street_type,
    block_num = block_num,
    union = union)

  if (!is.null(bbox)) {
    named_streets <- named_streets %>%
      sf::st_crop(bbox)
  }

  return(named_streets)
}
