#' Get bounding box adjusted to match aspect ratio
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [sfext::st_bbox_asp()] function which uses a similar set
#' of parameters.
#'
#' Get bbox from sf or bbox object adjusted to match an aspect ratio
#'
#' Takes an area as an  `sf` or `bbox` object and returns a bounding
#' box that matches the aspect ratio provided to `asp` and contains the
#' area or bounding box provided. Common aspect ratios include "1:1" (1), "4:6"
#' (0.666), "8.5:11", "16:9" (1.777). The asp parameter supports both numeric
#' values and character strings with ratios matching the format of
#' "width:height".
#'
#' @param area `sf` object
#' @param bbox `bbox` object to adjust
#' @param asp Aspect ratio of width to height as a numeric value (e.g. 0.33) or
#'   character (e.g. "1:3").
#' @return `bbox` object
#' @keywords internal
#' @export
#' @importFrom stringr str_detect str_extract
#' @importFrom sf st_as_sfc st_as_sf st_bbox
adjust_bbox_asp <- function(area = NULL,
                            bbox = NULL,
                            asp = NULL) {
  lifecycle::deprecate_warn("0.1.2", "adjust_bbox_asp()", "sfext::st_bbox_asp()")

  if (is.null(area)) {
    # Convert bounding box to sf object if area is NULL
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf()
  } else {
    # Get bbox for area
    bbox <- sf::st_bbox(area)
  }

  # Check aspect ratio
  if (is.null(asp)) {
    return(bbox)
  } else if (is.character(asp) && stringr::str_detect(asp, ":")) {
    # If asp is provided as character string (e.g. "16:9") convert to a numeric ratio
    asp <- as.numeric(stringr::str_extract(asp, ".+(?=:)")) / as.numeric(stringr::str_extract(asp, "(?<=:).+"))
  } else if (!is.numeric(asp)) {
    stop("The aspect ratio cannot be determined. asp must be numeric (e.g. 0.666) or a string formatted as a ratio of width to height (e.g. '4:6').")
  }


  xdist <- bbox[3] - bbox[1] # Get area width
  ydist <- bbox[4] - bbox[2] # Get area height
  area_asp <- as.numeric(xdist) / as.numeric(ydist) # Get width to height aspect ratio for bbox

  # Set adjustments for x and y to 0
  adj_x <- 0
  adj_y <- 0

  # Compare aspect ratio to bbox aspect ratio
  if (asp >= area_asp) {
    # adjust x
    adj_x <- (asp * ydist - xdist) / 2
  } else {
    # Equivalent to asp < area_asp
    # adjust y
    adj_y <- ((1 / asp) * xdist - ydist) / 2
  }

  # Adjust bbox
  bbox[[1]] <- bbox[[1]] - adj_x
  bbox[[3]] <- bbox[[3]] + adj_x
  bbox[[2]] <- bbox[[2]] - adj_y
  bbox[[4]] <- bbox[[4]] + adj_y

  return(bbox)
}
