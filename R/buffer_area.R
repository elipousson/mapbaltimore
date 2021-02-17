
#' Get buffered area
#'
#' Return an sf object of an area with a buffer applied to it. If no buffer distance is provided, a default buffer is calculated of one-eighth the diagonal distance of the bounding box (corner to corner) for the area. The metadata for the provided area remains the same.
#'
#' @param area sf object.
#' @param dist buffer distance in meters. Optional.
#' @param diag_ratio ratio to set map extent based diagonal distance of area's bounding box. Default is 0.125 (1/8). Ignored when \code{dist} is provided.
#'
#' @export
#'
buffer_area <- function(area,
                              dist = NULL,
                              diag_ratio = 0.125) {
  if (is.null(dist)) {
    # If no buffer distance is provided, use the diagonal distance of the bounding box to generate a proportional buffer distance
    area_bbox <- sf::st_bbox(area)

    area_bbox_diagonal <- sf::st_distance(
      sf::st_point(
        c(
          area_bbox$xmin,
          area_bbox$ymin
        )
      ),
      sf::st_point(
        c(
          area_bbox$xmax,
          area_bbox$ymax
        )
      )
    )

    dist <- units::set_units(area_bbox_diagonal * diag_ratio, "m")
  } else if (is.numeric(dist)) {
    # Set the units for the buffer distance if provided
    dist <- units::set_units(dist, "m")
  } else {
    # Return error if the provided buffer distance is not numeric
    stop("The buffer must be a numeric value representing the buffer distance in meters.")
  }

  buffered_area <- sf::st_buffer(area, dist)

  return(buffered_area)
}
