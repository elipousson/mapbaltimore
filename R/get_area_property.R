#' Get real property data
#'
#' Get showing parcels described as owner occupied, non-owner occupied, vacant,
#' and unimproved. Real property or parcel data is from the Maryland State
#' Department of Assessment and Taxation and may include errors.
#'
#' @inheritParams get_area_data
#' @param cache If TRUE, cache data to mapbaltimore cache folder. Default FALSE.
#' @param ... Use to pass filename and overwrite parameter to cache_baltimore_data. Use gpkg file type.
#' @rdname get_area_property
#' @export
#' @importFrom dplyr mutate across rename
#' @importFrom stringr str_trim str_squish
#' @importFrom naniar replace_with_na_if replace_with_na
#' @importFrom tidyr replace_na
#' @importFrom overedge as_sf get_location_data
get_area_property <- function(area = NULL,
                              bbox = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              crop = TRUE,
                              trim = FALSE,
                              cache = FALSE,
                              ...) {
  url <- "https://geodata.baltimorecity.gov/egis/rest/services/CityView/Realproperty/MapServer/0"

  if (is.null(area) && !is.null(bbox)) {
    location <- overedge::as_sf(bbox)
  } else {
    location <- area
  }

  real_property <-
    overedge::get_location_data(
      location = location,
      data = url,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crop = crop,
      trim = trim
    ) %>%
    format_property_data()

  if (cache) {
    cache_baltimore_data(data = real_property, ...)
  }

  return(real_property)
}

#' @name format_property_data
#' @rdname get_area_property
#' @export
#' @importFrom dplyr mutate across rename if_else
#' @importFrom stringr str_trim str_squish
#' @importFrom naniar replace_with_na_if replace_with_na
#' @importFrom tidyr replace_na
format_property_data <-
  function(data) {
    data <-
      dplyr::mutate(
        data,
        dplyr::across(where(is.character), ~ stringr::str_trim(stringr::str_squish(.x)))
      )

    data <-
      naniar::replace_with_na_if(data, is.character, ~ .x == "")

    data <-
      dplyr::rename(
        data,
        full_address = fulladdr,
        bldg_num = bldg_no,
        street_dir_prefix = stdirpre,
        street_name = st_name,
        street_type = st_type,
        zip_code_ext = extd_zip,
        dhcd_use = dhcduse1,
        agency = respagcy,
        neighborhood = neighbor,
        sale_price = salepric,
        sale_date = saledate,
        zoning = zonecode,
        year_built = year_build
      )

    data <-
      dplyr::mutate(
        data,
        block_num = floor(bldg_num / 100) * 100,
        bldg_num_even_odd = if_else((bldg_num %% 2) == 0, "Even", "Odd"),
        block_number_st = glue::glue(block_num, street_dir_prefix, street_name, street_type, .sep = " ", .na = "")
      )

    data <-
      naniar::replace_with_na(
        data,
        replace = list(year_built = 0)
      )

    data <-
      tidyr::replace_na(
        data,
        replace = list(no_imprv = "N", vacind = "N")
      )

    data <-
      dplyr::mutate(
        data,
        vacant_lot = dplyr::if_else(no_imprv == "Y", TRUE, FALSE),
        vacant_bldg = dplyr::if_else(vacind == "Y", TRUE, FALSE)
        # vacant_bldg = dplyr::if_else(!is.na(vbn_issued), TRUE, FALSE)
      )

    return(data)
  }
