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
#'
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


#' Get nearby areas
#'
#' Return data for all areas of a specified type within a specified distance of another area.
#'
#' @param area sf object. Must have a name column unless an \code{area_label} is provided.
#' @param type Length 1 character vector. Required to match one of the supported area types (excluding U.S. Census types). This is the area type for the areas to return and is not required to be the same type as the provided area.
#' @param dist Distance in meters for matching nearby areas. Default is 1 meter.
#'
#' @export
#'
get_nearby_areas <- function(area,
                             type = c(
                               "neighborhood",
                               "council district",
                               "legislative district",
                               "congressional district",
                               "planning district",
                               "police district",
                               "csa"
                             ),
                             dist = 1) {
  check_area(area)

  type <- match.arg(type)
  type <- paste0(gsub(" ", "_", type), "s")

  dist <- units::set_units(dist, "m")

  # Check what type of nearby area to return
  return_type <- eval(as.name(type))

  # Select areas within provided distance of the area
  nearby_areas <- sf::st_join(
    return_type,
    sf::st_buffer(
      dplyr::select(area, area_name = name),
      dist
    ),
    by = "st_intersects"
  ) %>%
    dplyr::filter(
      # Filter to areas within 2 meters of the provided area
      area_name %in% area$name
    ) %>%
    dplyr::filter(
      # Remove area that was matched (only return nearby areas)
      # This is only necessary if multiple areas are provided
      !(name %in% area$name)
    ) %>%
    # Remove provided area name
    dplyr::select(-area_name)

  return(nearby_areas)
}

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
get_buffered_area <- function(area,
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

#' Get U.S. Census geography overlapping with an area.
#'
#' Return an sf object with the U.S. Census blocks, block groups, or tracts overlapping with an area. By default, at least 25% of the tract area or 30% of the block group area, or 50% of the block area must be within the provided area to be returned.
#' Returned sf object includes new columns with the combined land and water area of the Census geography, the Census geography area within the provided area, the percent of Census geography area within the provided area, and the percent of the provided area within the Census geography area.
#'
#' @param area sf object.
#' @param geography Character vector with type of U.S. Census
#' @param area_overlap Optional. A numeric value less than 1 and greater than 0 representing the physical area of the geography that should be within the provided area to return.
#'
#' @export
#'
get_area_census_geography <- function(area,
                                      geography = c("block", "block group", "tract"),
                                      area_overlap = NULL) {
  check_area(area)

  geography <- match.arg(geography)

  # Check what type of nearby area to return
  if (geography == "block") {
    overlap <- 0.5
    geography_citywide <- dplyr::rename(baltimore_blocks, aland = aland10, awater = awater10)
  } else if (geography == "block group") {
    overlap <- 0.3
    geography_citywide <- baltimore_block_groups
  } else if (geography == "tract") {
    overlap <- 0.25
    geography_citywide <- baltimore_tracts
  }

  if (!is.null(area_overlap) && is.numeric(area_overlap) && area_overlap < 1 && area_overlap > 0) {
    overlap <- area_overlap
  } else if (!is.null(area_overlap)) {
    stop("The area_overlap must be a numeric value less than 1 and greater than 0. The area_overlap represents the share of the Census geography that must be located within the area to be included.")
  }

  return_geography <- sf::st_intersection(geography_citywide, dplyr::select(area, name = name)) %>%
    dplyr::select(-name) # Remove area name

  return_geography <- return_geography %>%
    dplyr::mutate(
      # Combine land and water area for the Census geography
      geoid_area = (aland + awater),
      # Calculate the Census geography area after intersection function was applied
      geoid_area_in_area = as.numeric(sf::st_area(geometry)),
      perc_geoid_in_area = geoid_area_in_area / geoid_area,
      perc_area_in_geoid = geoid_area_in_area / as.numeric(sf::st_area(area))
    )

  # Filter to areas with the specified percent area overlap or greater
  return_geography <- dplyr::filter(return_geography, perc_geoid_in_area >= overlap)

  # Switch area columns back to orignal names for block data
  if (geography == "block") {
    return_geography <- return_geography %>%
      dplyr::rename(aland10 = aland, awater10 = awater) %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid10, geometry),
        by = "geoid10"
      ) %>%
      sf::st_as_sf()
  } else {
    return_geography <- return_geography %>%
      sf::st_drop_geometry() %>%
      dplyr::left_join(
        dplyr::select(geography_citywide, geoid, geometry),
        by = "geoid"
      ) %>%
      sf::st_as_sf()
  }

  return(return_geography)
}


#' Get local or cached data for an area
#'
#' Returns data for a selected area or areas with an optional buffer.
#' If both crop and trim are FALSE, the function uses \code{\link[sf]{st_join()}} to return provided data without any changes to geometry.
#'
#' @param area `sf` object. If multiple areas are provided, they are unioned into a single sf object using \code{\link[sf]{st_union()}}
#' @param data `sf` object including data in area
#' @param bbox `bbox` object defining area used to filter data. If an area is provided, the bounding box is ignored.
#' @param extdata Character. Name of an external geopackage (.gpkg) file included with the package where selected data is available. Available data includes "trees", "unimproved_property", and "vegetated_area"
#' @param cachedata Character. Name of a cached geopackage (.gpkg) file where selected data is available. Running `cache_mapbaltimore_data()` caches data for "real_property", "baltimore_msa_streets", and "edge_of_pavement"
#' @inheritParams get_adjusted_bbox
#' @param crop  If TRUE, data cropped to area or bounding box \code{\link[sf]{st_crop()}} adjusted by the `dist`, `diag_ratio`, and `asp` provided. Default `TRUE`.
#' @param trim  If TRUE, data trimmed to area with \code{\link[sf]{st_intersection()}}. This option is not supported for any adjusted areas that use the `dist`, `diag_ratio`, or `asp` parameters. Default `FALSE`.
#' @param crs Coordinate Reference System (CRS) to use for the returned data. The CRS of the provided data and bounding box or area must match one another but are not required to match the CRS provided by this parameter.
#'
#' @export
#'
get_area_data <- function(area = NULL,
                          bbox = NULL,
                          data,
                          extdata = NULL,
                          cachedata = NULL,
                          diag_ratio = NULL,
                          dist = NULL,
                          asp = NULL,
                          crop = TRUE,
                          trim = FALSE,
                          crs = NULL) {

  if (!is.null(area) && length(area$geometry) > 1) {
    # Collapse multiple areas into a single geometry
    area_name <- paste(area$name, collapse = " & ")

    area <- area %>%
      sf::st_union() %>%
      sf::st_as_sf() %>%
      dplyr::rename(geometry = x)

    area$name <- area_name
  }

  # Get adjusted bounding box if any adjustment variables provided
  if (!is.null(dist) | !is.null(diag_ratio) | !is.null(asp)) {
    bbox <- get_adjusted_bbox(area = area,
                              bbox = bbox,
                              dist = dist,
                              diag_ratio = diag_ratio,
                              asp = asp)
  } else {
    bbox <- sf::st_bbox(area)
  }

  # Get data from extdata or cached folder if filename is provided
  if (!is.null(extdata) | !is.null(cachedata)) {

    # Convert bbox to well known text
    area_wkt_filter <- bbox %>%
      sf::st_as_sfc() %>% # Convert to sfc
      sf::st_as_text()

    # Set path to external or cached data
    if (!is.null(extdata)) {
      path <- glue::glue("inst/extdata/{extdata}.gpkg")
    } else {
      path <- glue::glue(rappdirs::user_cache_dir("mapbaltimore"), "/{cachedata}.gpkg")
    }

    data <- sf::st_read(path,
      wkt_filter = area_wkt_filter
    )
  }

  if (crop) {
    data <- sf::st_crop(data, bbox)
  } else if (!is.null(area)) {
    if (trim) {
      data <- sf::st_intersection(data, area)
    } else {
      area <- dplyr::rename(area, area_name = name)

      # Join area to data
      data <- data %>%
        sf::st_join(area) %>%
        dplyr::filter(!is.na(area_name)) %>%
        dplyr::select(-area_name)
    }
  } else if (!is.null(bbox)) {
    # Convert bbox to sf object
    area <- bbox %>%
      sf::st_as_sfc() %>%
      sf::st_as_sf() %>%
      tibble::add_column(area_name = "name")

    # Join to data
    data <- data %>%
      sf::st_join(area) %>%
      dplyr::filter(!is.na(area_name)) %>%
      dplyr::select(-area_name)

    # Warn user that the option for trim is ignored when a bbox is provided w/ no area
    if (trim) {
      warning("Trim is not a supported option when a bounding box is provided instead of an area sf object.")
      }
    }

  if (!is.null(crs)) {
    data <- sf::st_transform(data, crs)
  }

  return(data)
}

#' Get data from an ArcGIS FeatureServer or MapServer
#'
#' Wraps the `esri2sf::esri2sf()` function to download an ArcGIS FeatureServer or MapServer.
#' Some of the data (e.g. Liquor Licenses) is missing data important data.
#'
#' @param area `sf` object. Optional. Only used if trim is TRUE.
#' @param bbox `bbox` object. Optional but suggested to avoid downloading entire layer. See `sf::st_bbox()` for more information.
#' @param url FeatureServer or MapServer url to retrieve data from. Passed to `url` parameter of `esri2sf::esri2sf()` function.
#' @param type Type of data to get. Options include "md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", and "edge of pavement"
#' @param trim Logical. Default `FALSE.` If `TRUE`, area is required.
#' @param crs Coordinate reference system. Default 2804.
#' @export
get_area_esri_data <- function(area = NULL,
                               bbox = NULL,
                               url = NULL,
                               type = c("md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", "edge of pavement"),
                               trim = FALSE,
                               crs = 2804) {

  # Convert type into unqiue slug
  type <- gsub(" ", "_", type)

  if(is.null(url)) {
    # Get URL for FeatureServer or MapServer from internal esri_sources data
    esri_url <- esri_sources %>%
      dplyr::filter(slug == type) %>%
      dplyr::pull(url)
  } else {
    esri_url <- url
  }

  # Get bbox if area is provided
  if (!is.null(area)) {
    bbox <- sf::st_bbox(area)
  }

  # Get spatial data as sf using bbox if provided
  if (is.null(bbox)) {
    esri_data <- esri2sf::esri2sf(url = esri_url)
  } else if (class(bbox) == "bbox") {
    esri_data <- esri2sf::esri2sf(url = esri_url, bbox = bbox)
  } else {
    stop("The value for bbox is not a class 'bbox' object. Use sf::st_bbox() to create the bbox.")
  }

  # Rename geometry field
  esri_data <- esri_data %>%
    janitor::clean_names("snake") %>%
    dplyr::rename(geometry = geoms) %>%
    sf::st_transform(crs)

  # Optionally trim to area
  if (trim & !is.null(area)) {
    esri_data <- esri_data %>%
      sf::st_intersection(area)
  } else if (trim) {
    warning("trim is TRUE but no area is provided so the data is not trimmed.")
  }

  return(esri_data)
}
