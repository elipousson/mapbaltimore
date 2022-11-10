
#' Get buffered area
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' This function is deprecated because the functionality has been incorporated
#' into the improved [sfext::st_buffer_ext()] function which uses a similar set
#' of parameters.
#'
#' Return an sf object of an area with a buffer applied to it. If no buffer
#' distance is provided, a default buffer is calculated of one-eighth the
#' diagonal distance of the bounding box (corner to corner) for the area. The
#' metadata for the provided area remains the same.
#'
#' @param area sf object.
#' @param dist buffer distance in meters. Optional.
#' @param diag_ratio ratio to set map extent based diagonal distance of area's
#'   bounding box. Ignored when `dist` is provided.
#' @keywords internal
#' @export
#' @importFrom sfext st_buffer_ext
buffer_area <- function(area,
                        dist = NULL,
                        diag_ratio = NULL) {
  lifecycle::deprecate_soft("0.1.2", "buffer_area()", "sfext::st_buffer_ext()")

  area <-
    sfext::st_buffer_ext(
      x = area,
      dist = dist,
      diag_ratio = diag_ratio,
      unit = "m"
    )

  return(area)
}
