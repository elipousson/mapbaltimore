#' Get area of selected administrative type
#'
#' Get a sf object with one or more neighborhoods, Baltimore City Council districts,
#' Maryland Legislative Districts, U.S. Congressional Districts, Baltimore Planning Districts,
#' Baltimore Police Districts, or Community Statistical Areas.
#'
#' @param type area type matching one of the included boundary datasets.
#' Supported values include c("neighborhood", "council district", "legislative district",
#' "congressional district", "planning district", "police district", "csa")
#' @param area_name name or names matching id column in data of selected dataset.
#' @param area_id identifier or identifiers matching id column of selected dataset.
#' Not all supported datasets have an id column
#' @param union If TRUE and multiple area names are provided, the area geometry is combined
#' with \code{\link[sf]{st_union}} and names are concatenated into a single string.
#' Defaults to FALSE.
#'
#' @examples
#' get_area(type = "neighborhood", area_name = "Harwood")
#'
#' get_area(type = "council district", area_id = c(12, 14))
#'
#' get_area(type = "planning district", area_id = c("East", "Southeast"), union = TRUE)
#' @export
#'
get_area <- function(type = c(
                       "neighborhood",
                       "council district",
                       "legislative district",
                       "congressional district",
                       "planning district",
                       "police district",
                       "csa"
                     ),
                     area_name = NULL,
                     area_id = NULL,
                     union = FALSE) {
  type <- match.arg(type)
  type <- eval(as.name(paste0(gsub(" ", "_", type), "s")))

  if (is.character(area_name)) {
    area <- dplyr::filter(type, name %in% area_name)
  } else if (!is.null(area_id)) {
    area <- dplyr::filter(type, id %in% area_id)
  } else {
    stop("get_area requires an valid area_name or area_id parameter.")
  }

  if (length(area$geometry) == 0 && !is.null(area_name)) {
    stop(glue::glue("The provided area name ('{area_name}') does not match any {type}s."))
  }

  if (union == TRUE && length(area_name) > 1) {
    areas <- tibble::tibble(
      name = paste0(area$name, collapse = " & "),
      geometry = sf::st_union(area)
    )

    area <- sf::st_as_sf(areas)
  }

  return(area)
}
