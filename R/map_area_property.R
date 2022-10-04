#' Real property or parcel data is from the Maryland State Department of
#' Assessment and Taxation and may include outdated or inaccurate information.
#'
#' @param area Simple features object. Function currently supports only a single
#'   area at a time.
#' @param property Real property variable to map. Options include c("improved",
#'   "vacant", "principal residence", "value"). Currently supports only one
#'   variable at a time.
#' @inheritParams get_area_data
#' @param show_mask If `TRUE`, apply a white, 0.6 alpha mask over property
#'   located outside the provided area. Default `FALSE.`
#' @export
#' @importFrom ggplot2 ggplot aes geom_sf labs scale_fill_viridis_d
#' @importFrom dplyr nest_by case_when mutate filter
#' @importFrom purrr map
#' @importFrom forcats fct_relevel
map_area_property <- function(area,
                              property = c("improved", "vacant", "principal residence", "use", "building type", "value"),
                              dist = NULL,
                              diag_ratio = 0.1,
                              asp = NULL,
                              trim = FALSE,
                              show_mask = FALSE) {
  property <- match.arg(property)

  if (length(area$geometry) == 1) {
    area_property <- get_area_data(
      area = area,
      cachedata = "real_property",
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      trim = trim
    )
  } else if (length(area$geometry) > 1) {
    stop("Multiple areas are not currently supported by this function.")

    area <- area %>%
      dplyr::nest_by(name, .keep = TRUE)

    area_property <- purrr::map(
      area$data,
      ~ get_area_data(
        area = .x,
        cachedata = "real_property",
        dist = dist,
        diag_ratio = diag_ratio,
        asp = asp,
        trim = trim
      )
    )
  }

  # Set up ggplot2 plot
  area_property_map <- ggplot2::ggplot()

  exclude_color <- "gray80"

  # Get area park data (breaks for multiple areas when/if that is supported)
  area_parks <- get_area_data(
    data = parks,
    area = area,
    diag_ratio = diag_ratio,
    dist = dist,
    trim = trim
  )

  if (property == "improved") {
    # Set ordered levels for status variable
    property_levels <- c(
      "Improved property",
      "Unimproved property"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        improvement = dplyr::case_when(
          no_imprv == "Y" ~ property_levels[[2]],
          no_imprv == "N" ~ property_levels[[1]]
        ),
        improvement = forcats::fct_relevel(improvement, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = improvement),
        color = NA
      ) +
      ggplot2::labs(fill = "Category") +
      ggplot2::scale_fill_viridis_d(begin = 0.1, end = 0.8)
  } else if (property == "vacant") {
    # Set ordered levels for status variable
    property_levels <- c(
      "Vacant property",
      "Vacant lot",
      "Occupied property",
      "Park/open space"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        vacant = dplyr::case_when(
          zonecode == "OS" ~ property_levels[[4]],
          no_imprv == "Y" ~ property_levels[[2]],
          vacind == "Y" ~ property_levels[[1]],
          vacind == "N" ~ property_levels[[3]]
        ),
        vacant = forcats::fct_relevel(vacant, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = vacant),
        color = NA
      ) +
      ggplot2::labs(fill = "Category") +
      ggplot2::scale_fill_viridis_d(begin = 0.4, direction = -1)
  } else if (property == "principal residence") {
    # Set ordered levels for status variable
    property_levels <- c(
      "Principal residence only",
      "Principal residence (and another use)",
      "Not a principal residence"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        principal_residence = dplyr::case_when(
          permhome == "H" ~ property_levels[[1]],
          permhome == "D" ~ property_levels[[2]],
          permhome == "N" ~ property_levels[[3]]
        ),
        principal_residence = forcats::fct_relevel(principal_residence, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = principal_residence),
        color = NA
      ) +
      ggplot2::geom_sf(
        data = dplyr::filter(area_property, !is.na(ciuse)),
        fill = "gray60",
        color = NA
      ) +
      ggplot2::labs(fill = "Tenure category") +
      ggplot2::scale_fill_viridis_d()
  } else if (property == "use") {
    property_levels <- c(
      "Residential",
      "Commercial",
      "Industrial",
      "Other"
    )

    area_property <- area_property %>%
      dplyr::mutate(
        use_category = dplyr::case_when(
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
        use_category = forcats::fct_relevel(use_category, property_levels)
      )

    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = use_category),
        color = NA
      ) +
      ggplot2::labs(fill = "Property use") +
      ggplot2::scale_fill_viridis_d()
  } else if (property == "building type") {
    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = area_property,
        ggplot2::aes(fill = stringr::str_to_title(descbldg_cat)),
        color = NA
      ) +
      ggplot2::labs(fill = "Building type") +
      ggplot2::scale_fill_viridis_d()
  }

  if (property != "improved" & property != "vacant") {
    # Cover unimproved properties with light gray for all maps except improvement maps
    area_property_map <- area_property_map +
      ggplot2::geom_sf(
        data = dplyr::filter(area_property, no_imprv == "Y"),
        fill = exclude_color,
        color = NA
      ) +
      ggplot2::geom_sf(
        data = area_parks,
        fill = exclude_color,
        color = NA
      )
  }

  if (show_mask) {
    area_property_map <- area_property_map +
      layer_area_mask(
        area = area,
        diag_ratio = diag_ratio,
        dist = dist,
        asp = asp,
        fill = "white",
        color = NA,
        alpha = 0.6
      )
  }

  return(area_property_map)
}
