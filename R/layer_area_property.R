#' Add a layer to a gpplot2 map with area property categorized by type
#'
#' Real property or parcel data is from the Maryland State Department of
#' Assessment and Taxation and may include outdated or inaccurate information.
#' @param type Real property variable to map. Options include c("improved",
#'   "vacant", "principal residence", "value"). Currently supports only one
#'   variable at a time.
#' @inheritParams layer_area_data
#' @examples
#' \dontrun{
#' area <- get_area("neighborhood", "West Forest Park")
#'
#' property <- get_area_property(area = area)
#'
#' ggplot2::ggplot() +
#'   layer_area_property(area = area, data = property, type = "principal residence")
#' }
#' @seealso layer_area_data
#' @rdname layer_area_property
#' @export
#' @export
#' @importFrom dplyr mutate case_when
#' @importFrom forcats fct_relevel
#' @importFrom stringr str_to_title
layer_area_property <- function(area = NULL,
                                bbox = NULL,
                                data = NULL,
                                type = c("improved", "vacant", "principal residence", "use", "building type", "value"),
                                asis = FALSE,
                                diag_ratio = NULL,
                                dist = NULL,
                                asp = NULL,
                                crop = TRUE,
                                trim = FALSE,
                                show_area = FALSE,
                                show_mask = FALSE,
                                crs = pkgconfig::get_config("mapbaltimore.crs", 2804),
                                ...) {

  categorize_area_property <- function(area_property, type) {
    if (type == "improved") {
      # Set ordered levels for status variable
      category_levels <- c(
        "Improved property",
        "Unimproved property"
      )

      area_property <- area_property %>%
        dplyr::mutate(
          category = dplyr::case_when(
            no_imprv == "N" ~ category_levels[[1]],
            no_imprv == "Y" ~ category_levels[[2]]
          ),
          category = forcats::fct_relevel(category, category_levels)
        )
    } else if (type == "vacant") {

      # Set ordered levels for status variable
      category_levels <- c(
        "Vacant property",
        "Vacant lot",
        "Occupied property",
        "Park/open space"
      )

      area_property <- area_property %>%
        dplyr::mutate(
          category = dplyr::case_when(
            zoning == "OS" ~ category_levels[[4]],
            no_imprv == "Y" ~ category_levels[[2]],
            vacind == "Y" ~ category_levels[[1]],
            vacind == "N" ~ category_levels[[3]]
          ),
          category = forcats::fct_relevel(category, category_levels)
        )
    } else if (type == "principal residence") {
      category_levels <- c(
        "Principal residence only",
        "Principal residence (and another use)",
        "Not a principal residence"
      )

      area_property <- area_property %>%
        dplyr::mutate(
          category = dplyr::case_when(
            permhome == "H" ~ category_levels[[1]],
            permhome == "D" ~ category_levels[[2]],
            permhome == "N" ~ category_levels[[3]]
          ),
          category = forcats::fct_relevel(category, category_levels)
        )
    } else if (type == "use") {
      stop("Use data is currently unavailable.")
      category_levels <- c(
        "Residential",
        "Commercial",
        "Industrial",
        "Other"
      )

      area_property <- area_property %>%
        dplyr::mutate(
          category = dplyr::case_when(
            desclu == "Residential" ~ "Residential",
            desclu == "Residential Condominium" ~ "Residential",
            desclu == "Apartments" ~ "Residential",
            desclu == "Residential/Commercial" ~ "Residential",
            desclu == "Commercial" ~ "Commercial",
            desclu == "Commercial Condominium" ~ "Commercial",
            desclu == "Commercial/Residential" ~ "Commercial",
            desclu == "Exempt Commercial" ~ "Commercial",
            desclu == "Industrial" ~ "Industrial",
            desclu == "Exempt" ~ "Other",
            TRUE ~ "Other",
          ),
          category = forcats::fct_relevel(category, category_levels)
        )
    } else if (type == "building type") {
      stop("building type is not currently supported.")
      area_property <- area_property %>%
        mutate(
          category = stringr::str_to_title(descbldg_cat)
        )
    } else if ("category" %in% names(area_property)) {
      message("Using custom category from data.")
    }

    return(area_property)
  }

  if (is.null(data)) {
    property_layer <-
      layer_area_data(
        area = area,
        data = suppressMessages(
          get_area_property(
            area = area,
            diag_ratio = diag_ratio,
            dist = dist,
            asp = asp,
            crop = crop,
            trim = trim
          )
        ),
        asis = TRUE,
        fn = ~ .x %>%
          categorize_area_property(type = type),
        mapping = aes(fill = category),
        show_area = show_area,
        show_mask = show_mask,
        ...
      )
  } else {
    property_layer <-
      layer_area_data(
        area = area,
        data = data,
        asis = asis,
        diag_ratio = diag_ratio,
        dist = dist,
        asp = asp,
        crop = crop,
        trim = trim,
        fn = ~ .x %>%
          categorize_area_property(type = type),
        mapping = aes(fill = category),
        show_area = show_area,
        show_mask = show_mask,
        ...
      )
  }

  return(property_layer)
}
