#' Filter streets
#'
#' Internal function for filtering streets by multiple parameters
#'
#' @param x sf object with streets to filter
#' @param sha_class selected SHA classifications to include. "all" selects all
#'   streets with an assigned SHA classification (around one-quarter of all
#'   street segments). Additional options include c("COLL", "LOC", "MART",
#'   "PART", "FWY", "INT")
#' @param street_type selected street subtypes to include. By default, the
#'   returned data includes all subtypes except alleys ("STRALY"). Options
#'   include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR",
#'   "STRURD", "STCLN", "STRTN"). Not supported for
#' @param block_num Integer vector with block number, e.g. 300, or range of
#'   block numbers (e.g. `c(100, 500)`) to filter streets.
#' @param union Logical. Default `TRUE`. Union geometry based on `fullname` of
#'   streets.
#' @param bbox Bounding box to filter passed to location parameter of
#'   [getdata::get_location_data()].
#' @return streets filtered by parameters
#' @rdname filter_streets
#' @importFrom dplyr filter bind_rows mutate group_by summarise
#' @importFrom sf st_crop st_bbox st_union
#' @importFrom stringr str_trim str_squish
#' @importFrom getdata get_location_data
#' @importFrom pkgconfig get_config
filter_streets <- function(x,
                           sha_class = NULL,
                           street_type = NULL,
                           block_num = NULL,
                           union = FALSE,
                           bbox = NULL,
                           call = caller_env()) {
  # Limit to streets with selected SHA classifications
  if (!is.null(sha_class)) {
    check_character(sha_class, call = call)

    sha_class_x <- toupper(sha_class)

    if ("ALL" %in% sha_class_x) {
      x <- dplyr::filter(x, !is.na(sha_class))
    } else {
      x <- dplyr::filter(x, sha_class %in% sha_class_x)
    }
  }

  # Filter by selected street_type
  if (is.null(street_type)) {
    x <- dplyr::filter(x, subtype != "STRALY")
  } else {
    check_character(street_type, call = call)

    x <- dplyr::filter(x, subtype %in% street_type)
  }

  if (!is.null(block_num)) {
    block_num_x <- block_num

    x_blocks <- dplyr::filter(
      x,
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

  if (is.null(bbox)) {
    return(x)
  }

  getdata::get_location_data(
    data = x,
    location = bbox,
    crs = pkgconfig::get_config("mapbaltimore.crs", 2804)
  )
}
