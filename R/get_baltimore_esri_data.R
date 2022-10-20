#' Named list for matching type to nm values in baltimore_gis_index
#'
#' @noRd
type_to_nm_list <-
  list(
    "chap_hd" = "chap_districts_map",
    "chap_landmarks" = "designated_landmark_map"
  )

#' Get Baltimore data
#'
#' A wrapper for [getdata::get_esri_data()]
#'
#' @param area Area (passed to location), Default: NULL
#' @param nm nm (should match a single value from baltimore_gis_index$nm), Default: NULL
#' @param type Type used as an alias for a nm value, Default: NULL
#' @param crs Coordinate reference system, Default: NULL
#' @inheritDotParams getdata::get_esri_data
#' @return A dataframe or simple feature object

#' @seealso
#'  \code{\link[getdata]{get_esri_data}}
#' @rdname get_baltimore_esri_data
#' @export
#' @importFrom getdata get_esri_data
#' @importFrom sfext rename_sf_col
get_baltimore_esri_data <- function(area = NULL,
                               nm = NULL,
                               type = NULL,
                               crs = NULL,
                               ...) {

  if (!is.null(type)) {
    nm <- type_to_nm_list[[type]]
  }

  nm_index <-
    baltimore_gis_index[baltimore_gis_index$nm %in% nm, ]

  if (nrow(nm_index) > 1) {
    stop("Too many URLs")
  }

  url <- nm_index$url

  data <-
    getdata::get_esri_data(
      location = area,
      url = url,
      crs = crs,
      ...
    )

  if (!inherits(data, "sf")) {
    return(data)
  }

  sfext::rename_sf_col(data)
}
