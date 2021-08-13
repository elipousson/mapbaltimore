#' @title Batch load or save data for an area, street, or intersection
#' @description This batch loading/saving function is less flexible than
#'   get_area_data() can reduce the need for repetitive calls to get_area_data()
#'   when gathering area-level data for mapping.
#' @param get_type Type of geography to use in setting the area of data to load
#'   or save, Default: c("area", "street", "intersection", "other")
#' @param label Label to use for the loaded objects or saved files, Defaults to
#'   the same as the get_type parameter.
#' @param bbox_adj Named list with parameters used by adjust_bbox() to create a
#'   bounding box for the area, street, or intersection. Set to NULL if to use
#'   the area as is (or to use another sf object with the other_area parameter)
#'   Default: list(dist = 15, diag_ratio = NULL, asp = "6:4").
#' @param other_area A custom sf object to use instead of getting an area,
#'   street, or intersection. Only used if get_type is set to "other".
#' @param fn Function to apply to area after returning it. Useful for applying a
#'   buffer to a street or creating a walking distance isochrone to use as the
#'   bounding box for an intersection.
#' @param area_batch Type(s) of area intersecting with the bounding box to
#'   return. The areas returned are not cropped or trimmed. Default:
#'   c("neighborhood", "council district", "csa", "tract")
#' @param data_batch Data in bounding box. All spatial  datasets included with
#'   the mapbaltimore package and any values supported by the extdata parameter
#'   of get_area_data() are supported. "osm_buildings" is a special supported
#'   parameter that calls get_area_osm_buildings() to return all building
#'   footprints in the bounding box. Default: c("streets", "parks", "zoning",
#'   "hmt_2017", "mta_bus_lines", "mta_bus_stops", "trees", "vegetated_area",
#'   "unimproved_property")
#' @param trim If TRUE (and if bbox_adj is NULL), trim the data to the area,
#'   street, or intersection.
#' @param load If TRUE, load the selected areas and datasets to the environment,
#'   Default: FALSE
#' @param save If TRUE, save the selected areas and datasets locally as a file
#'   (using the save_dns parameter as a file extension)., Default: TRUE
#' @param save_dns File extension supported by `sf::write_sf()`, Default:
#'   'geojson'
#' @param ... Parameters passed to get_area(), get_street(), or
#'   get_intersection() depending on the value of the get_type parameter.
#' @examples
#' \dontrun{
#' if(interactive()){
#' # Load council districts and streets for the Harwood neighborhood
#'  get_data_batch(
#'   get_type = "area",
#'   label = "harwood",
#'   type = "neighborhood",
#'   area_name = "Harwood",
#'   area_batch = c("council district", "planning district"),
#'   data_batch = c("streets"),
#'   load = TRUE,
#'   save = FALSE)
#'
#'  # Save neighborhoods, parks, trees, and vegetated area w/in 800 meters
#'  # of the intersection of E. Pratt and Light Sts. to GeoJSON files
#'  get_data_batch(
#'   get_type = "intersection",
#'   street_names = "E PRATT ST & LIGHT ST",
#'   bbox_adj = list(dist = 0, diag_ratio = NULL, asp = "1:1")
#'   dist = 800
#'   area_batch = c("neighborhood"),
#'   data_batch = c("parks", "trees", "vegetated_area")
#'  )
#'  }
#' }
#' @rdname get_data_batch
#' @export
#' @importFrom sf st_as_sfc st_as_sf write_sf st_crop
#' @importFrom janitor make_clean_names
#' @importFrom purrr discard walk set_names map_chr map
#' @importFrom glue glue
get_data_batch <- function(get_type = c("area", "street", "intersection", "other"),
                           other_area = NULL,
                           label = get_type,
                           bbox_adj = list(dist = 15, diag_ratio = NULL, asp = "6:4"),
                           fn = NULL,
                           area_batch = c("neighborhood", "council district", "csa", "tract"),
                           data_batch = c("streets", "parks", "zoning", "hmt_2017", "mta_bus_lines", "mta_bus_stops", "trees", "vegetated_area", "unimproved_property"),
                           trim = FALSE,
                           load = FALSE,
                           save = TRUE,
                           save_dns = "geojson",
                           ...) {
  get_type <- match.arg(get_type)

  if (get_type == "intersection") {
    area <- get_intersection(..., type = "area")
  } else if (get_type == "street") {
    area <- get_streets(...)
  } else if (get_type == "area") {
    area <- get_area(...)
  } else if ((get_type == "other") && !is.null(other_area)) {
    area <- other_area
  }

  if (!is.null(fn)) {
    fn <- rlang::as_function(fn)
    area <- fn(area)
  }

  if (!is.null(bbox_adj)) {
    area <- area |>
      adjust_bbox(dist = bbox_adj$dist, diag_ratio = bbox_adj$diag_ratio, asp = bbox_adj$asp) |>
      sf::st_as_sfc() |>
      sf::st_as_sf()
  }

  slug <- janitor::make_clean_names(label)

  save_load_list <- function(x) {
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

  if (!is.null(area_batch) && is.character(1)) {
    # Load/save data with get_area()
    area_data <- area_batch |>
      purrr::set_names(
        nm = purrr::map_chr(
          area_batch,
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

    save_load_list(area_data)
  }

  if (!is.null(data_batch)) {
    pkgdata_batch <- data_batch[data_batch %in% data(package = "mapbaltimore")$results[, "Item"]]
    extdata_batch <- data_batch[data_batch %in% c("trees", "unimproved_property", "vegetated_area")]
    cachedata_batch <- data_batch[data_batch %in% c("edge_of_pavement", "baltimore_msa_streets")]

    if (length(pkgdata_batch) > 0) {
      area_pkgdata <- pkgdata_batch |>
        purrr::map(
          ~ eval(parse(text = .x))
        ) |>
        purrr::map(
          ~ get_area_data(
            area = area,
            data = .x,
            crop = TRUE,
            trim = trim
          )
        ) |>
        purrr::set_names(
          nm = purrr::map_chr(
            pkgdata_batch,
            ~ glue::glue("{slug}_{janitor::make_clean_names(.x)}")
          )
        ) |>
        suppressWarnings()

      save_load_list(area_pkgdata)
    }

    if (length(extdata_batch) > 0) {
      area_extdata <-
        extdata_batch |>
        purrr::set_names(
          nm = purrr::map_chr(
            extdata_batch,
            ~ glue::glue("{slug}_{janitor::make_clean_names(.x)}")
          )
        ) |>
        purrr::map(
          ~ get_area_data(
            area = area,
            extdata = .x,
            crop = TRUE,
            trim = trim
          )
        ) |>
        suppressWarnings()

      save_load_list(area_extdata)
    }

    if (length(cachedata_batch) > 0) {
      area_cachedata <-
        cachedata_batch |>
        purrr::set_names(
          nm = purrr::map_chr(
            cachedata_batch,
            ~ glue::glue("{slug}_{janitor::make_clean_names(.x)}")
          )
        ) |>
        purrr::map(
          ~ get_area_data(
            area = area,
            cachedata = .x,
            crop = TRUE,
            trim = trim
          )
        ) |>
        suppressWarnings()

      save_load_list(area_cachedata)
    }

    if ("osm_buildings" %in% data_batch) {
      area_osm_buildings <-
        get_area_osm_data(
          area = area,
          key = "building",
          value = c("yes", "garage", "house", "commercial", "library", "post_office", "university", "parking", "hospital", "central_office", "school", "church", "industrial", "apartments"),
          trim = trim
        ) |>
        sf::st_crop(area) |>
        list() |>
        purrr::set_names(
          nm = glue::glue("{slug}_osm_buildings")
        ) |>
        suppressWarnings()

      save_load_list(area_osm_buildings)
    }
  }
}
