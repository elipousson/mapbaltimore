#' @title Get intersections
#' @description Get intersections by name and id with option to apply buffer and
#'   return streets or edgement of pavement instead of the intersection.
#' @param street_names street names matching one or more of the names from the
#'   `named_intersections` data.
#' @param id id values corresponding to one or more id values from the
#'   `named_intersections` data.
#' @inheritParams buffer_area
#' @param type Type of data to return. "area" returns the intersection center if
#'   `dist` is 0 or a circle centered on the intersection center with any
#'   positive dist value. "edge_of_pavement" or "streets" return what either the
#'   cached edge of pavement data or street center line data.
#' @param trim If type is "edge_of_pavement" or "streets" and `trim` is TRUE
#'   return data trimmed to the buffered intersection, otherwise return data
#'   within bounding box, Default: TRUE
#' @return Intersection center point, buffered area around intersection center,
#'   streets, or edge of pavement data.
#' @example examples/get_intersection.R
#' @rdname get_intersection
#' @export
#' @importFrom stringr str_to_upper str_detect
#' @importFrom dplyr filter summarise
#' @importFrom sf st_union
#' @importFrom sfext st_buffer_ext
get_intersection <- function(street_names = NULL,
                             id = NULL,
                             dist = 25,
                             type = c("area", "edge_of_pavement", "streets"),
                             trim = TRUE) {
  if (is.null(id)) {
    street_names <- stringr::str_to_upper(street_names)
    intersection <- dplyr::filter(
      named_intersections,
      stringr::str_detect(name, street_names)
    )
  } else {
    select_id <- id
    intersection <- dplyr::filter(named_intersections, id %in% select_id)
  }

  if (dist > 0) {
    intersection <- sfext::st_buffer_ext(intersection, dist = dist)
  }

  type <- match.arg(type)

  switch(type,
    "area" = intersection,
    "edge_of_pavement" = getdata::get_location_data(
      location = intersection,
      data = type,
      package = "mapbaltimore",
      trim = trim
    ),
    "streets" = get_area_streets(
      area = intersection,
      trim = trim
    )
  )
}
