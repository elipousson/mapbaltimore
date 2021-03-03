#' Get selected area streets
#'
#' Get streets within an area or areas.
#'
#' @param area sf object with area of streets to return.
#' @param street_type selected street subtypes to include. By default, the returned data includes all subtypes except alleys ("STRALY").
#' Options include c("STRALY", "STRPRD", "STRR", "STREX", "STRFIC", "STRNDR", "STRURD", "STCLN", "STRTN")
#' @param sha_class selected SHA classifications to include.
#' "all" selects all streets with an assigned SHA classification (around one-quarter of all street segments).
#' Additional options include c("COLL", "LOC", "MART", "PART", "FWY", "INT")
#' @inheritParams get_area_data
#' @param trim Logical. Default \code{FALSE}. Trim streets to area using `sf::st_intersection()`.
#' @param msa Logical. Default \code{FALSE}. Get streets from cached `baltimore_msa_streets.gpkg` file using `cachedata` parameter of `get_area_data` function.
#' @param union Logical. Default \code{TRUE}. Union geometry based on `fullname` of streets.
#' @export
#' @importFrom dplyr mutate filter rename group_by summarise
#' @importFrom stringr str_to_upper
#' @importFrom sf st_union
#'
get_area_streets <- function(area = NULL,
                             street_type = NULL,
                             sha_class = NULL,
                             bbox = NULL,
                             dist = NULL,
                             diag_ratio = NULL,
                             asp = NULL,
                             trim = FALSE,
                             msa = FALSE,
                             union = TRUE) {
  if (!msa) {
    # Get streets in area
    area_streets <- get_area_data(
      data = streets,
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim
    )

  } else {
    # Get streets in area that includes MSA
    area_streets <- get_area_data(
      area = area,
      cachedata = "baltimore_msa_streets",
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim
    ) %>%
      dplyr::rename(
        fullname = road_name,
        geometry = geom
      ) %>%
      dplyr::mutate(
        subtype = ""
      )
  }

  area_streets <- filter_streets(x = area_streets,
                                 sha_class = sha_class,
                                 street_type = street_type,
                                 union = union)

  return(area_streets)
}

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
#' @importFrom dplyr filter mutate group_by summarise
#' @importFrom sf st_union
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
    x <- x %>%
      dplyr::filter((block_num >= min(block_num_x)) | block_num == -9,
                    block_num <= max(block_num_x))
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
