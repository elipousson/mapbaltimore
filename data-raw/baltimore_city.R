## code to prepare `baltimore_city` dataset

# Import generalized Maryland county boundaries from iMap
# https://data.imap.maryland.gov/datasets/maryland-physical-boundaries-county-boundaries-generalized

maryland_county_boundaries <- sf::read_sf('https://opendata.arcgis.com/datasets/4c172f80b626490ea2cff7b699febedb_1.geojson')

# Filter county boundaries to Baltimore city
baltimore_city <- dplyr::filter(maryland_county_boundaries, county == "Baltimore City")

# Rename columns to match original data
baltimore_city <- dplyr::rename(baltimore_city,
                                county_fips = county_fip)

# Remove unused columns
baltimore_city <- dplyr::select(baltimore_city, -c(OBJECTID, district, countynum, creation_d, last_updat))

# Transform CRS
baltimore_city <- sf::st_transform(baltimore_city, 2804)

usethis::use_data(baltimore_city, overwrite = TRUE)
