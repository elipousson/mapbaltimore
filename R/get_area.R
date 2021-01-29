#' Return geography for selected area type and name.
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
  type <- paste0(gsub(" ", "_", type), "s")

  if (is.character(area_name)) {
    area <- dplyr::filter(eval(as.name(type)), name %in% area_name)
  } else if (!is.null(area_id)) {
    area <- dplyr::filter(eval(as.name(type)), id %in% area_id)
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

#' Get GIS data from an ArcGIS FeatureServer or MapServer
#'
#' Wraps the esri2sf::esri2sf() function to download an ArcGIS FeatureServer or MapServer.
#' Some of the data (e.g. Liquor Licenses) is missing data important data.
#'
#' @param area sf object. Optional. Only used if trim is TRUE.
#' @param bbox bbox object. Optional but suggested to avoid downloading entire layer. See sf::st_bbox() for more information.
#' @param type Type of data to get. Options include "md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", and "edge of pavement"
#' @param trim Logical. Default FALSE. If TRUE, area is required.
#' @export
get_area_esri_data <- function(area = NULL,
                               bbox = NULL,
                               type = c("md food stores 2017 2018", "farmers markets 2020", "baltimore food stores 2016", "baltimore demolitions", "contour 2ft", "contours 10ft", "open vacant building notices", "liquor licenses", "fixed speed cameras", "red light cameras", "edge of pavement"),
                               trim = FALSE,
                               crs = 2804) {

  # Convert type into unqiue slug
  type <- gsub(" ", "_", type)

  # Load list of MapServer and FeatureLayer sources
  esri_sources <- tibble::tribble(
    ~name,                          ~slug,                                                                                                          ~url,                    ~source,                                                                     ~source_url,    ~esri_server,
    "Maryland Food Stores 2017-2018",     "md_food_stores_2017_2018",          "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/218/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/c4a2bd61eaac4425b3e2e9c40735a7ae_218",     "MapServer",
    "Farmers Markets 2020",         "farmers_markets_2020",          "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/481/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/a62650c0ae6d46ecbe199108c1125019_239",     "MapServer",
    "Baltimore City Food Stores 2016",   "baltimore_food_stores_2016",          "https://gis.mdfoodsystemmap.org/server/rest/services/FoodMapMD/MD_Food_Map_Services/MapServer/217/", "Maryland Food System Map", "https://data-clf.hub.arcgis.com/datasets/650fa48f80ae46ef9843171703ff96f0_217",     "MapServer",
    "Completed City Demo",        "baltimore_demolitions", "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/0/",           "Open Baltimore",                   "https://data.baltimorecity.gov/datasets/completed-city-demo", "FeatureServer",
    "Contour 2ft",                  "contour_2ft",                   "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/dmxBoundaries/MapServer/26/",           "Open Baltimore",                         "https://data.baltimorecity.gov/datasets/contour-2ft-1",     "MapServer",
    "Contours 10ft",                "contours_10ft",                 "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Contours_10ft/FeatureServer/0/",           "Open Baltimore",                       "https://data.baltimorecity.gov/datasets/contours-10ft-1", "FeatureServer",
    "Vacant Building Notices Open", "open_vacant_building_notices", "https://egisdata.baltimorecity.gov/egis/rest/services/Housing/DHCD_Open_Baltimore_Datasets/FeatureServer/1/",           "Open Baltimore",          "https://data.baltimorecity.gov/datasets/vacant-building-notices-open", "FeatureServer",
    "Liquor Licenses",              "liquor_licenses",              "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Liquor_Licenses/FeatureServer/0/",           "Open Baltimore",                       "https://data.baltimorecity.gov/datasets/liquor-licenses", "FeatureServer",
    "Fixed Speed Cameras",          "fixed_speed_cameras",           "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Fixed_Speed_Cameras/FeatureServer/0/",           "Open Baltimore",                   "https://data.baltimorecity.gov/datasets/fixed-speed-cameras", "FeatureServer",
    "Red Light Cameras",            "red_light_cameras",             "https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Red_Light_Cameras/FeatureServer/0/",           "Open Baltimore",                   "https://data.baltimorecity.gov/datasets/red-light-cameras-1", "FeatureServer",
    "Edge of Pavement",             "edge_of_pavement",               "https://maps.baltimorecity.gov/egis/rest/services/OpenBaltimore/Edge_of_Pavement/MapServer/0/",                         NA,                                                                              NA,     "MapServer"
  )


  # Get URL for FeatureServer or MapServer
  esri_url <- esri_sources %>%
    dplyr::filter(slug == type) %>%
    dplyr::pull(url)

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
