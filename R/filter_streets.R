
#' @title Filter streets
#'
#' Internal function for filtering streets by multiple parameters
#'
#' @param x sf object with streets to filter
#' @param street_type selected street subtypes to include. By default, the returned data includes all subtypes except alleys ("STRALY"). Options include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR", "STRURD", "STCLN", "STRTN"). Not supported for
#' @param sha_class selected SHA classifications to include. "all" selects all streets with an assigned SHA classification (around one-quarter of all street segments). Additional options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @param block_num Integer vector with block number c(300) or range of block numbers (c(100, 500)) to filter streets.
#' @param union Logical. Default `TRUE`. Union geometry based on `fullname` of streets.
#' @return streets filtered by parameters
#' @rdname filter_streets
#' @importFrom stringr str_to_upper str_trim str_squish
#' @importFrom dplyr filter mutate group_by summarise bind_rows
#' @importFrom sf st_union st_crop
filter_streets <- function(x,
                           sha_class = NULL,
                           street_type = NULL,
                           block_num = NULL,
                           union = FALSE) {

  # Limit to streets with selected SHA classifications
  if (!is.null(sha_class)) {
    sha_class_x <- stringr::str_to_upper(sha_class)

    if ("ALL" %in% sha_class_x) {
      x <- x %>%
        dplyr::filter(!is.na(sha_class))
    } else {
      x <- x %>%
        dplyr::filter(sha_class %in% sha_class_x)
    }
  }

  # Filter by selected street_type
  if (is.null(street_type)) {
    x <- x %>%
      dplyr::filter(subtype != "STRALY")
  } else {
    x <- x %>%
      dplyr::filter(subtype %in% street_type)
  }

  if (!is.null(block_num)) {
    block_num_x <- block_num
    x_blocks <- x %>%
      dplyr::filter(
        block_num >= min(block_num_x),
        block_num <= max(block_num_x),
        block_num != -9
      )

    x_blocks_missing <- x %>%
      dplyr::filter(block_num == -9) %>%
      sf::st_crop(sf::st_bbox(x_blocks))

    x <- dplyr::bind_rows(x_blocks, x_blocks_missing)
  }

  if (union) {
    x <- x %>%
      dplyr::mutate(
        fullname = stringr::str_trim(stringr::str_squish(fullname))
      ) %>%
      dplyr::group_by(fullname) %>%
      dplyr::summarise(geometry = sf::st_union(geometry))
  }

  return(x)
}
