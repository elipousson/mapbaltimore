#' @title Batch load or save data for an area, street, or intersection
#' @description This batch loading/saving function is less flexible than
#'   `get_area_data()` can reduce the need for repetitive calls to `get_area_data()`
#'   when gathering area-level data for mapping.
#'   - `get_data_batch()` calls `get_area_data()`.
#'   - `get_area_batch()` calls `get_area()` using the provided area as the location parameter.
#' @param get Type of geography to use in setting the area of data to load or
#'   save, Default: c("area", "street", "intersection")
#' @param label Label to use for the loaded objects or saved files, Defaults to
#'   the same as the get parameter.
#' @param adj Named list with parameters used by `adjust_bbox()` to create a
#'   bounding box for the area, street, or intersection. Set to NULL if to use
#'   the area as is (or to use another sf object with the other_area parameter)
#'   Default: list(dist = 15, diag_ratio = NULL, asp = "6:4").
#' @param area An sf object to use instead of getting an area,
#'   street, or intersection. Only used if get is NULL.
#' @param fn Function to apply to area after returning it. Useful for applying a
#'   buffer to a street or creating a walking distance isochrone to use as the
#'   bounding box for an intersection.
#' @param batch A character string or named list.
#' - If using `get_area_batch()`, batch must be a character vector or list with
#' the type(s) of area supported by `get_area()`. Any area intersecting with the
#' area or adjusted area is returned. Default: "neighborhood", "council
#' district", "csa", "tract"
#' - If using `get_data_batch()`, batch must be a character vector matching one of
#' the spatial datasets included with the mapbaltimore package or cached in
#' advance. "osm_buildings" is a special supported parameter that calls
#' `get_area_osm_buildings()` to return all building footprints in the bounding
#' box. Default: c("streets", "parks", "zoning", "hmt_2017", "mta_bus_lines",
#' "mta_bus_stops", "trees", "vegetated_area", "unimproved_property"). A named
#' list where list items are sf objects, supported character strings, or valid
#' URLs for ArcGIS FeatureServer or MapServer layers is also supported. Default: NULL
#' @param crop If FALSE, return data that intersects with the bounding box of
#'   the area, street, or intersection but do not crop to the bounding box. This
#'   parameter is not supported for `get_area_batch()`. Default: TRUE.
#' @param trim If TRUE (and if adj is NULL), trim the data to the area, street,
#'   or intersection. Default: FALSE.
#' @param load If TRUE, load the selected areas and datasets to the environment,
#'   Default: FALSE
#' @param save If TRUE, save the selected areas and datasets locally as a file
#'   (using the save_dns parameter as a file extension)., Default: TRUE
#' @param save_dns File extension supported by `sf::write_sf()`, Default:
#'   'geojson'
#' @param ... Parameters passed to `get_area()`, `get_streets()`, or
#'   `get_intersection()` depending on the value of the get parameter.
#' @name get_batch
#' @md
NULL

#' @rdname get_batch
#' @examples
#' \dontrun{
#' if(interactive()){
#' # Load streets and cached edge of pavement data for the Harwood neighborhood
#'  get_data_batch(
#'   get = "area",
#'   label = "harwood",
#'   type = "neighborhood",
#'   area_name = "Harwood",
#'   batch = c("streets", "edge_of_pavement"),
#'   load = TRUE,
#'   save = FALSE)
#'
#'  # Save parks, trees, and vegetated area w/in 800 meters
#'  # of the intersection of E. Pratt and Light Sts. to GeoJSON files
#'  get_data_batch(
#'   get = "intersection",
#'   street_names = "E PRATT ST & LIGHT ST",
#'   adj = list(dist = 0, diag_ratio = NULL, asp = "1:1"),
#'   dist = 800,
#'   batch = c("parks", "trees", "vegetated_area")
#'  )
#'  }
#' }
#' @export
#' @importFrom rlang as_function
#' @importFrom sf st_as_sfc st_as_sf write_sf st_crop
#' @importFrom janitor make_clean_names
#' @importFrom purrr discard walk set_names map_chr map
#' @importFrom glue glue
get_data_batch <- function(get = c("area", "street", "intersection"),
                           area = NULL,
                           label = get,
                           adj = list(dist = 15, diag_ratio = NULL, asp = "6:4"),
                           fn = NULL,
                           batch = NULL,
                           crop = TRUE,
                           trim = FALSE,
                           load = FALSE,
                           save = TRUE,
                           save_dns = "geojson",
                           ...) {
  if (!is.null(get)) {
    get <- match.arg(get)

    if (get == "intersection") {
      area <- get_intersection(..., type = "area")
    } else if (get == "street") {
      area <- get_streets(...)
    } else if (get == "area") {
      area <- get_area(...)
    }
  } else if (is.null(label)) {
    stop("A label is required when using the area parameter.")
  }

  if (!is.null(fn)) {
    fn <- rlang::as_function(fn)
    area <- fn(area)
  }

  if (!is.null(adj)) {
    area <- area |>
      adjust_bbox(dist = adj$dist, diag_ratio = adj$diag_ratio, asp = adj$asp) |>
      sf::st_as_sfc() |>
      sf::st_as_sf()
  }

  slug <- janitor::make_clean_names(label)

  if ("osm_buildings" %in% batch) {
    area_osm_buildings <-
      get_area_osm_data(
        area = area,
        key = "building",
        crop = crop,
        trim = trim
      ) |>
      list() |>
      purrr::set_names(
        nm = glue::glue("{slug}_osm_buildings")
      ) |>
      suppressWarnings()

    # Remove osm_buildings from batch
    batch <- batch[batch != "osm_buildings"]

    save_load_list(area_osm_buildings, load, save)
  }

  if (length(batch) > 0) {
    data <- batch |>
      purrr::map(
        ~ get_area_data(
          area = area,
          data = .x,
          crop = crop,
          trim = trim
        )
      ) |>
      suppressWarnings()

    if (is.null(names(batch))) {
      names(batch) <- batch
    }

    data <- data |>
      purrr::set_names(
        nm = purrr::map_chr(
          names(batch),
          ~ glue::glue("{slug}_{janitor::make_clean_names(.x)}")
        )
      )
  }

  save_load_list(data, load, save)
}

#' @rdname get_batch
#' @export
#' @importFrom rlang as_function
#' @importFrom sf st_as_sfc st_as_sf
#' @importFrom janitor make_clean_names
#' @importFrom purrr set_names map_chr map
#' @importFrom glue glue
get_area_batch <- function(get = c("area", "street", "intersection"),
                           area = NULL,
                           label = get,
                           adj = list(dist = 15, diag_ratio = NULL, asp = "6:4"),
                           fn = NULL,
                           batch = c("neighborhood", "council district", "csa", "tract"),
                           trim = FALSE,
                           load = FALSE,
                           save = TRUE,
                           save_dns = "geojson",
                           ...) {
  if (!is.null(get)) {
    get <- match.arg(get)

    if (get == "intersection") {
      area <- get_intersection(..., type = "area")
    } else if (get == "street") {
      area <- get_streets(...)
    } else if (get == "area") {
      area <- get_area(...)
    }
  }

  if (!is.null(fn)) {
    fn <- rlang::as_function(fn)
    area <- fn(area)
  }

  if (!is.null(adj)) {
    area <- area |>
      adjust_bbox(dist = adj$dist, diag_ratio = adj$diag_ratio, asp = adj$asp) |>
      sf::st_as_sfc() |>
      sf::st_as_sf()
  }

  slug <- janitor::make_clean_names(label)

  # Load/save data with get_area()
  area_data <- batch |>
    purrr::set_names(
      nm = purrr::map_chr(
        batch,
        ~ glue::glue("{slug}_{janitor::make_clean_names(.x)}s")
      )
    ) |>
    purrr::map(
      ~ get_area(
        type = .x,
        location = area
      )
    ) |>
    suppressWarnings()

  save_load_list(area_data, load, save)
}


save_load_list <- function(x, load, save) {
  if (load) {
    x |>
      purrr::discard(~ nrow(.x) == 0) |>
      list2env(envir = .GlobalEnv)
  } else if (save) {
    x |>
      purrr::walk(
        ~ sf::write_sf(.x, glue::glue("{names(.x)}.{save_dns}"))
      )
  }
}
