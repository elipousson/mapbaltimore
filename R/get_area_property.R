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
#' @importFrom dplyr select rename
get_area_property <- function(area = NULL,
                              bbox = NULL,
                              dist = NULL,
                              diag_ratio = NULL,
                              asp = NULL,
                              crop = TRUE,
                              trim = FALSE,
                              cache = FALSE,
                              ...) {

  url <- "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxOwnership/MapServer/0"

  real_property <-
    get_area_data(
      area = area,
      bbox = bbox,
      url = url,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crop = crop,
      trim = trim
    ) |>
    dplyr::mutate(
      dplyr::across(where(is.character), ~ stringr::str_trim(stringr::str_squish(.x)))
    ) |>
    naniar::replace_with_na_if(is.character, ~ .x == "") |>
    dplyr::select(
      block,
      lot,
      blocklot,
      full_address = fulladdr,
      bldg_num = bldg_no,
      fraction,
      span_num,
      street_dirpre = stdirpre,
      street_name = st_name,
      street_type = st_type,
      zip_code,
      zip_code_ext = extd_zip,
      permhome,
      no_imprv,
      dhcd_use = dhcduse1,
      resp_agency = respagcy,
      neighborhood = neighbor,
      sale_price = salepric,
      sale_date = saledate,
      owner_1,
      owner_2,
      owner_3,
      taxbase,
      fullcash,
      permhome,
      no_imprv,
      zoning = zonecode,
      year_built = year_build,
      sdatlink,
      geometry = geoms
    ) |>
    naniar::replace_with_na(replace = list(year_built = 0)) |>
    tidyr::replace_na(replace = list(no_imprv = "N"))

  vacants <-
    get_area_vacants(
      area = area,
      bbox = bbox,
      dist = dist,
      diag_ratio = diag_ratio,
      asp = asp,
      crop = crop,
      trim = trim
    )

  real_property <-
    real_property |>
    dplyr::mutate(
      vacind = if_else(blocklot %in% vacants$blocklot, "Y", "N"),
      .after = no_imprv
    )

  if (cache) {
    cache_baltimore_data(data = real_property, ...)
  }

  return(real_property)
}
