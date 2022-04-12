#' Generalized political boundary for Baltimore City
#'
#' A generalized boundary for Baltimore City, Maryland
#' from statewide dataset of generalized county boundaries.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{\code{name}}{County name}
#'   \item{\code{countyfp}}{3-character county FIPS code}
#'   \item{\code{geoid}}{county identifier; a concatenation of state FIPS code and county FIPS code}
#'   \item{\code{aland}}{land area (square meters)}
#'   \item{\code{awater}}{water area (square meters)}
#'   \item{\code{intptlat}}{latitude of the internal point}
#'   \item{\code{intptlon}}{longitude of the internal point}
#'   \item{\code{geometry}}{Multipolygon with the boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_city"

#' Detailed physical boundary for Baltimore City
#'
#' A detailed physical boundary of Baltimore City.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{\code{name}}{County name}
#'   \item{\code{countyfp}}{3-character county FIPS code}
#'   \item{\code{geometry}}{Multipolygon with the physical boundary}
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/maryland-physical-boundaries-county-boundaries-detailed}
"baltimore_city_detailed"

#' Neighborhood boundaries for Baltimore City
#'
#' Baltimore City Neighborhoods or Neighborhood Statistical Areas
#'
#' @format A data frame with 278 rows and 2 variables:
#' \describe{
#'   \item{\code{name}}{Neighborhood name}
#'   \item{\code{type}}{Type of area, with options including residential, industrial area, park/open space, institutionl area and business park)}
#'   \item{\code{acres}}{Area of the neighborhood (acres)}
#'   \item{\code{osm_id}}{Open Street Map (OSM) relation identifier}
#'   \item{\code{wikidata}}{Wikidata entity identifier}
#'   \item{\code{geometry}}{Multipolygons with neighborhood boundary}
#' }
#' @source \href{https://data.imap.maryland.gov/datasets/fc5d183b20a145009eae8f8b171eeb0d_0}{Maryland Baltimore City Neighborhoods (MD iMap)}
"neighborhoods"

#' @title U.S. Census Block-to-Tract Crosswalk with 2010 Block Household Population
#' @description Used to generate xwalk_neighborhood2tract.
#' @format A data frame with 13598 rows and 3 variables:
#' \describe{
#'   \item{\code{block}}{Block GeoID}
#'   \item{\code{tract}}{Tract GeoID}
#'   \item{\code{households}}{Block household population}
#' }
"xwalk_block2tract"

#' @title Neighborhood-to-U.S. Census Tract Crosswalk
#' @description Share of total households is based on the proportion of U.S.
#'   Census tract population within the named neighborhood based on overlapping
#'   U.S. Census Block groups.
#' @format A data frame with 551 rows and 4 variables:
#' \describe{
#'   \item{\code{name}}{Neighborhood name}
#'   \item{\code{geoid}}{GeoID for U.S. Census tract}
#'   \item{\code{tract}}{Tract number}
#'   \item{\code{weight_households}}{Share of total households in neighborhood and U.S. Census tract (based on 2010 decennial Census). Variable code is "H013001".}
#'   \item{\code{weight_units}}{Share of occupied housing units in neighborhood and U.S. Census tract (based on 2020 decennial Census PL-94171 redistricting data). Variable code is "H1_002N".}
#' }
"xwalk_neighborhood2tract"

#' Baltimore City Police Districts
#'
#' Baltimore City Police Districts
#'
#' @format A data frame with 9 rows and 3 variables:
#' \describe{
#'   \item{\code{number}}{Police district number}
#'   \item{\code{name}}{Police district name}
#'   \item{\code{geometry}}{Multipolygons with district boundary}
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7}
"police_districts"

#' Community Statistical Areas (2010)
#'
#' Community Statistical Areas (CSAs) are clusters of neighborhoods and are
#' organized around U.S. Census tract boundaries by the Baltimore Neighborhood
#' Indicators Alliance. In some cases, CSA boundaries may cross neighborhood
#' boundaries. There are 55 CSAs in Baltimore City. Neighborhood lines often do
#' not fall along CSA boundaries. The CSAs were originally created in 2002 and
#' were revised for the publication of Vital Signs 10 using new 2010 Census
#' Tract boundaries. There are no anticipated boundary revisions in 2020.
#'
#' @format A data frame with 55 rows and 3 variables:
#' \describe{
#'   \item{\code{id}}{Community Statistical Area id number}
#'   \item{\code{name}}{Community Statistical Area name}
#'   \item{\code{url}}{URL to BNIA-JFI webpage on Community Statistical Area}
#'   \item{\code{geometry}}{Multipolygon with area boundary}
#' }
#' @source \url{https://bniajfi.org/mapping-resources/}
"csas"

#' @title Community Statistical Area (CSA)-to-Neighborhood Statistical Area (NSA) Crosswalk
#' @description  A crosswalk to match Community Statistical Areas to
#'   Neighborhood Statistical Areas. Both a Neighborhood Statistical Area name
#'   and neighborhood name are provided, with the NSA name matching the
#'   crosswalk file provided by BNIA-JFI and the neighborhood name matching the
#'   neighborhoods data included with the mapbaltimore package. NSA boundaries
#'   may overlap over several CSAs. When more than 50% of a NSA falls within a
#'   particular community it is assigned to that community. No NSAs in these
#'   files are assigned to more than one community.
#' @format A data frame with 278 rows and 4 variables:
#' \describe{
#'   \item{\code{id}}{Community Statistical Area id number}
#'   \item{\code{csa}}{Community Statistical Area name}
#'   \item{\code{nsa}}{Neighborhood Statistical Area name}
#'   \item{\code{neighborhood}}{Neighborhood name}
#' }
#' @source \url{https://bniajfi.org/mapping-resources/}
"xwalk_csa2nsa"

#' @title Zipcode-to-Community Statistical Area (NSA) Crosswalk
#' @description A crosswalk to match zipcodes to Community Statistical Areas.
#' @format A data frame with 119 rows and 3 variables:
#' \describe{
#'   \item{\code{zip}}{Zipcode}
#'   \item{\code{csa}}{Community Statistical Area name}
#'   \item{\code{id}}{Community Statistical Area id number}
#' }
#' @source \url{https://bniajfi.org/mapping-resources/}
"xwalk_zip2csa"

#' County boundaries for the Baltimore–Columbia–Towson MSA
#'
#' Counties boundaries in the Baltimore–Columbia–Towson Metropolitan Statistical Area (MSA)
#' include Baltimore City, Baltimore County, Carroll County, Anne Arundel County,
#' Howard County, Queen Anne's County, and Harford County.
#'
#' @format A data frame with 7 rows and 18 variables:
#' \describe{
#'   \item{\code{statefp}}{State FIPS code for Maryland}
#'   \item{\code{countyfp}}{County FIPS code}
#'   \item{\code{countyns}}{County GNIS code}
#'   \item{\code{geoid}}{Unique county FIPS code (concatenation of state and county FIPS codes)}
#'   \item{\code{name}}{County name}
#'   \item{\code{namelsad}}{Concatenated variable length geographic area name and legal/statistical area description (LSAD)}
#'   \item{\code{lsad}}{Legal/statistical area description (LSAD)}
#'   \item{\code{classfp}}{FIPS class code}
#'   \item{\code{mtfcc}}{MAF/TIGER Feature Class Code (MTFCC)}
#'   \item{\code{csafp}}{Combined statistical area code}
#'   \item{\code{cbsafp}}{Metropolitan statistical area/micropolitan statistical area code}
#'   \item{\code{metdivfp}}{Metropolitan division code}
#'   \item{\code{funcstat}}{Functional status}
#'   \item{\code{aland}}{Land area (square meters)}
#'   \item{\code{awater}}{Water area (square meters)}
#'   \item{\code{intptlat}}{Latitude of the internal point}
#'   \item{\code{intptlon}}{Longitude of the internal point}
#'   \item{\code{geometry}}{Multipolygon with the county boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_msa_counties"

#'  Public Use Microdata Areas (PUMAS)
#'
#'  The U.S. Census Bureau explains that "Public Use Microdata Areas
#'  (PUMAs) are non-overlapping, statistical geographic areas that partition
#'  each state or equivalent entity into geographic areas containing no fewer
#'  than 100,000 people each... The Census Bureau defines PUMAs for the
#'  tabulation and dissemination of decennial census and American Community
#'  Survey (ACS) Public Use Microdata Sample (PUMS) data."
#' @format A data frame with 5 rows and 11 variables:
#' \describe{
#'  \item{\code{statefp10}}{State FIPS code for Maryland}
#'  \item{\code{pumace10}}{PUMA code}
#'  \item{\code{geoid10}}{GeoID}
#'  \item{\code{namelsad10}}{name and the translated legal/statistical area description code for census tract}
#'  \item{\code{mtfcc10}}{MAF/TIGER Feature Class Code (MTFCC)}
#'  \item{\code{funcstat10}}{functional status}
#'  \item{\code{aland10}}{land area (square meters)}
#'  \item{\code{awater10}}{water area (square meters)}
#'  \item{\code{intptlat10}}{latitude of the internal point}
#'  \item{\code{intptlon10}}{longitude of the internal point}
#'  \item{\code{geometry}}{Polygon with PUMA boundary}
#'  }
"baltimore_pumas"

#' U.S. Census Tracts
#'
#' ...
#'
#' @format A data frame with 200 rows and 9 variables:
#' \describe{
#'   \item{\code{tractce}}{census tract code}
#'   \item{\code{geoid}}{nation-based census tract identifier; a concatenation of state FIPS code, county FIPS code, and census tract number}
#'   \item{\code{name}}{Variable length geographic area name}
#'   \item{\code{namelsad}}{name and the translated legal/statistical area description code for census tract}
#'   \item{\code{aland}}{land area (square meters)}
#'   \item{\code{awater}}{water area (square meters)}
#'   \item{\code{intptlat}}{latitude of the internal point}
#'   \item{\code{intptlon}}{longitude of the internal point}
#'   \item{\code{geometry}}{Polygon with tract boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_tracts"


#' U.S. Census Block Groups
#'
#' ...
#'
#' @format A data frame with 653 rows and 9 variables:
#' \describe{
#'   \item{\code{tractce}}{census tract code}
#'   \item{\code{blkgrpce}}{block group number}
#'   \item{\code{geoid}}{Census block group identifier; a concatenation of the state FIPS code, county FIPS code, census tract code, and block group number}
#'   \item{\code{namelsad}}{translated legal/statistical area description and the block group number}
#'   \item{\code{aland}}{land area (square meters)}
#'   \item{\code{awater}}{water area (square meters)}
#'   \item{\code{intptlat}}{latitude of the internal point}
#'   \item{\code{intptlon}}{longitude of the internal point}
#'   \item{\code{geometry}}{Polygon with block group boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_block_groups"


#' U.S. Census Blocks (2010 Decennial)
#'
#' ...
#'
#' @format A data frame with 13,598 rows and 9 variables:
#' \describe{
#'   \item{\code{tractce10}}{Tract FIPS}
#'   \item{\code{blockce10}}{Block FIPS}
#'   \item{\code{geoid10}}{Block GeoID}
#'   \item{\code{name10}}{Block name}
#'   \item{\code{aland10}}{Land area}
#'   \item{\code{awater10}}{Water area}
#'   \item{\code{intptlat10}}{Interior center point latitude}
#'   \item{\code{intptlon10}}{Interior center point longitude}
#'   \item{\code{geometry}}{Multipolygon with block boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_blocks"


#' Maryland Transit Administration (MTA) Bus Routes
#'
#' Maryland Department of Transportation's Maryland Transit Administration
#' Summer 2020 Bus Routes including CityLink, LocalLink and Commuter Bus.
#' The data reflect bus route changes as of July 12, 2020.
#'
#' @format A data frame with 103 rows and 4 variables:
#' \describe{
#'   \item{\code{route_name}}{Name of the bus route}
#'   \item{\code{route_type}}{Type of route, CityLink, LocalLink and Commuter Bus}
#'   \item{\code{route_number}}{Unique route number or color identifier}
#'   \item{\code{route_abb}}{Route abbreviation (only different for color CityLink routes)}
#'   \item{\code{frequent}}{Logical indicator of route inclusion in MTA BaltimoreLink's Frequent Transit Network.}
#'   \item{\code{geometry}}{Multilinestring with the bus route path}
#' }
#' @source \href{https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1}{Maryland Transit - MTA Bus Lines (MD iMap)}
"mta_bus_lines"

#' @title Maryland Transit Administration (MTA) Bus Stops
#' @description Maryland Department of Transportation's Maryland Transit
#'   Administration Bus Stops including CityLink, LocalLink and Commuter Bus.
#'   This data is based on the Summer 2020 schedule effective July 12, 2020.
#'   Ridership data is based upon Automatic Passenger Counting (APC) system
#'   average daily weekday bus stop ridership (boarding, alighting, and total)
#'   from the Spring 2019 schedule period and does not exclude outliers.
#' @format A data frame with 4426 rows and 11 variables:
#' \describe{
#'   \item{\code{stop_id}}{Stop identification number}
#'   \item{\code{stop_name}}{Stop name}
#'   \item{\code{rider_on}}{Average daily weekday count of riders boarding transit at stop}
#'   \item{\code{rider_off}}{Average daily weekday count of riders alighting transit at stop}
#'   \item{\code{rider_total}}{Average daily weekday count of total riders served at stop}
#'   \item{\code{stop_ridership_rank}}{Stop rank for ridership}
#'   \item{\code{routes_served}}{Routes served at stop}
#'   \item{\code{mode}}{Mode served at stop}
#'   \item{\code{shelter}}{Logical indicator of bus shelter availability}
#'   \item{\code{county}}{County where stop is located}
#'   \item{\code{geometry}}{Point with location of stop}
#' }
#' @source \href{https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-stops-1}{Maryland Transit - MTA Bus Stops (MD iMap)}
"mta_bus_stops"

#' @title Maryland Transit Administration (MTA) SubwayLink Metro Lines
#' @description DATASET_DESCRIPTION
#' @format A data frame with 34 rows and 8 variables:
#' \describe{
#'   \item{\code{id}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{rail_name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{tunnel}}{character COLUMN_DESCRIPTION}
#'   \item{\code{direction}}{character COLUMN_DESCRIPTION}
#'   \item{\code{miles}}{double COLUMN_DESCRIPTION}
#'   \item{\code{status}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
"mta_subway_lines"

#' @title Maryland Transit Administration (MTA) SubwayLink Metro Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 14 rows and 10 variables:
#' \describe{
#'   \item{\code{id}}{integer Station identification number}
#'   \item{\code{name}}{Station name}
#'   \item{\code{address}}{Station street address}
#'   \item{\code{city}}{City}
#'   \item{\code{state}}{State}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{avg_wkdy}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{avg_wknd}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{facility_type}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
"mta_subway_stations"

#' @title Maryland Transit Administration (MTA) Light RailLink Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 84 rows and 8 variables:
#' \describe{
#'   \item{\code{id}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{rail_name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{tunnel}}{character COLUMN_DESCRIPTION}
#'   \item{\code{direction}}{character COLUMN_DESCRIPTION}
#'   \item{\code{miles}}{double COLUMN_DESCRIPTION}
#'   \item{\code{status}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source \href{https://data.imap.maryland.gov/datasets/maryland-transit-light-rail-lines/}{Maryland Transit - Light Rail Lines (MD iMap)}
"mta_light_rail_lines"

#' @title Maryland Transit Administration (MTA) Light RailLink Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 33 rows and 11 variables:
#' \describe{
#'   \item{\code{id}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{address}}{character COLUMN_DESCRIPTION}
#'   \item{\code{city}}{character COLUMN_DESCRIPTION}
#'   \item{\code{state}}{character COLUMN_DESCRIPTION}
#'   \item{\code{zipcode}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{avg_wkdy}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{avg_wknd}}{character COLUMN_DESCRIPTION}
#'   \item{\code{facility_type}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source \href{https://data.imap.maryland.gov/datasets/maryland-transit-light-raillink-stations/}{Maryland Transit - Light RailLink Stations (MD iMap)}
"mta_light_rail_stations"

#' @title MTA MARC Train Lines
#' @description DATASET_DESCRIPTION
#' @format A data frame with 162 rows and 8 variables:
#' \describe{
#'   \item{\code{id}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{rail_name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{tunnel}}{character COLUMN_DESCRIPTION}
#'   \item{\code{direction}}{character COLUMN_DESCRIPTION}
#'   \item{\code{miles}}{double COLUMN_DESCRIPTION}
#'   \item{\code{status}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source \href{https://data.imap.maryland.gov/datasets/de0efbe9f8884ac5aa69864b6b3ff633_10/}{Maryland Transit - MARC Train Lines (MD iMap)}
"mta_marc_lines"

#' @title MTA MARC Train Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 44 rows and 12 variables:
#' \describe{
#'   \item{\code{id}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{address}}{character COLUMN_DESCRIPTION}
#'   \item{\code{city}}{character COLUMN_DESCRIPTION}
#'   \item{\code{state}}{character COLUMN_DESCRIPTION}
#'   \item{\code{zipcode}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{line_name}}{character COLUMN_DESCRIPTION}
#'   \item{\code{mode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{avg_wkdy}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{avg_wknd}}{integer COLUMN_DESCRIPTION}
#'   \item{\code{facility_type}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source \href{https://data.imap.maryland.gov/datasets/maryland-transit-marc-trains-stations/}{Maryland Transit - MARC Trains Stations (MD iMap)}
"mta_marc_stations"

#' Baltimore City Public Schools School Zones or School Attendance Zones
#'
#' Baltimore City Public Schools School Zones also known as School Attendance Zones.
#'
#' @format A data frame with 96 rows and 4 variables:
#' \describe{
#'   \item{\code{program_name}}{Program or school name}
#'   \item{\code{program_number}}{Program number}
#'   \item{\code{zone_name}}{Program name with zone appended}
#'   \item{\code{geometry}}{Multipolygons with school zone boundaries}
#' }
#' @source \url{https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/BCPSZones_2021/FeatureServer/0}
"bcps_zones"


#' Baltimore City Public School Programs
#'
#' Locations of school buildings/school programs.
#'
#' @format A data frame with 165 rows and 6 variables:
#' \describe{
#'   \item{\code{program_name}}{Program or school name}
#'   \item{\code{program_number}}{Program number}
#'   \item{\code{type}}{Program type}
#'   \item{\code{category}}{Program category, e.g. E, EM, H, etc.}
#'   \item{\code{zone_name}}{Program name with zone appended}
#'   \item{\code{geometry}}{Multipolygons with school program location}
#' }
#' @source \url{https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2021_Programs/FeatureServer/0}
"bcps_programs"


#' Baltimore City Zoning Code
#'
#' The Baltimore City Zoning Code is administered by the Baltimore City
#' Department of Housing and Community Development (HCD) Office of the
#' Zoning Administrator. This office supports the Board of Municipal Zoning Appeals (BMZA).
#'
#' @format A data frame with 2,406 rows and 4 variables:
#' \describe{
#'   \item{\code{zoning}}{Zoning designation code}
#'   \item{\code{overlay}}{Overlay zone designation}
#'   \item{\code{label}}{Label combining zoning and overlay zoning codes}
#'   \item{\code{category_zoning}}{Zoning code category}
#'   \item{\code{name_zoning}}{Zoning code name}
#'   \item{\code{category_overlay}}{Overlay code category}
#'   \item{\code{name_overlay}}{Overlay zoning name}
#'   \item{\code{geometry}}{Multipolygons for areas with shared zoning}
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/20}
"zoning"

#' Baltimore City Council Districts
#'
#' Baltimore City Council Districts used since 2012 (following boundary
#' revisions completed in 2011).
#'
#' @format A data frame with 14 rows and 2 variables:
#' \describe{
#'   \item{\code{id}}{Number of the City Council district}
#'   \item{\code{name}}{Name of the City Council district}
#'   \item{\code{geometry}}{Multipolygons for boundaries of City Council districts}
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/CityView/City_Council_Districts/MapServer/0}
"council_districts"


#' Baltimore City Planning Districts
#'
#' Administrative boundaries set by the Baltimore City Department of Planning.
#'
#' @format A data frame with 11 rows and 4 variables:
#' \describe{
#'   \item{\code{id}}{Planning district area identifier}
#'   \item{\code{name}}{Full name of the planning district}
#'   \item{\code{abb}}{Planning district area abbreviation}
#'   \item{\code{geometry}}{Multipolygon boundary of the planning district}
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0}
"planning_districts"


#' Maryland Legislative Districts for Baltimore City
#'
#' ...
#'
#' @format A data frame with 6 rows and 4 variables:
#' \describe{
#'   \item{\code{name}}{District name}
#'   \item{\code{id}}{District number}
#'   \item{\code{label}}{District label}
#'   \item{\code{geometry}}{Multipolygon data with district boundaries}
#' }
#' @source \url{https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1}
"legislative_districts"


#' U.S. Congressional Districts for Baltimore City
#'
#' U.S. Congressional Districts overlapping with Baltimore City. Downloaded with
#' the tigris package.
#'
#' @format A data frame with 3 rows and 15 variables:
#' \describe{
#'   \item{\code{statefp}}{2-character state FIPS code}
#'   \item{\code{cd116fp}}{116th congressional district FIPS code}
#'   \item{\code{geoid}}{GeoID}
#'   \item{\code{namelsad}}{concatenated variable length geographic area name and legal/statistical area description (LSAD)}
#'   \item{\code{lsad}}{Legal/statistical area description (LSAD)}
#'   \item{\code{cdsessn}}{Congressional session code}
#'   \item{\code{mtfcc}}{MAF/TIGER Feature Class Code (MTFCC)}
#'   \item{\code{funcstat}}{functional status}
#'   \item{\code{aland}}{land area (square meters)}
#'   \item{\code{awater}}{water area (square meters)}
#'   \item{\code{intptlat}}{latitude of the internal point}
#'   \item{\code{intptlon}}{longitude of the internal point}
#'   \item{\code{label}}{Congressional District label}
#'   \item{\code{name}}{Congressional District name}
#'   \item{\code{geometry}}{Multipolygon with Congressional district boundary}
#' }
#' @source \url{...}
"congressional_districts"



#' Baltimore City Parks
#'
#' Spatial data for parks in Baltimore City from the Baltimore City Department of Recreation and Parks.
#'
#' @format A data frame with 297 rows and 6 variables:
#' \describe{
#'   \item{\code{name}}{Park name}
#'   \item{\code{id}}{Identification number from city data}
#'   \item{\code{address}}{Primary street address}
#'   \item{\code{name_alt}}{Alternate name}
#'   \item{\code{operator}}{Park operator, Baltimore City Department of Recreation and Parks (BCRP) or other}
#'   \item{\code{park_district}}{Park maintenance district for BCRP}
#'   \item{\code{acres}}{Area of the park property (acres)}
#'   \item{\code{geometry}}{Multipolygon with park edges}
#' }
#' @source \url{https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2}
"parks"


#' 311 Service Request Types for Baltimore City
#'
#' A list of request types based on unique request types used between January 2019 and October 2020.
#'
#' @format A data frame with 320 rows and 1 variables:
#' \describe{
#'   \item{\code{request_type}}{Service request type}
#' }
#' @source \url{...}
"request_types"


#' Historic Ward Boundaries, 1797-1918 for Baltimore City
#'
#' Historic ward boundary data from 1797 to 1918. Derived from KML data provided by the Baltimore City Archives.
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{\code{year}}{Earliest effective year of ward boundary}
#'   \item{\code{name}}{Ward name}
#'   \item{\code{number}}{Ward number}
#'   \item{\code{geometry}}{Multipolygons with ward boundary for year}
#' }
#' @source \url{https://msa.maryland.gov/bca/wards/index.html}
"wards_1797_1918"

#' Maryland Inventory of Historic Properties in Baltimore City
#'
#' ...
#'
#' @format A data frame with 5,203 rows and 14 variables:
#' \describe{
#'   \item{\code{num_polys}}{...}
#'   \item{\code{mihp_id}}{...}
#'   \item{\code{property_id}}{...}
#'   \item{\code{mihp_num}}{...}
#'   \item{\code{name}}{...}
#'   \item{\code{alternate_name}}{...}
#'   \item{\code{full_address}}{...}
#'   \item{\code{town}}{...}
#'   \item{\code{county}}{...}
#'   \item{\code{pdflink}}{...}
#'   \item{\code{xcoord}}{...}
#'   \item{\code{ycoord}}{...}
#'   \item{\code{do_erecord}}{...}
#'   \item{\code{geoms}}{...}
#' }
#' @source \url{...}
"baltimore_mihp"


#' Baltimore City Street Center lines
#'
#' ...
#'
#' @format Simple feature collection with 48,473 features and 23 fields.
#' \describe{
#'   \item{\code{type}}{...}
#'   \item{\code{subtype}}{...}
#'   \item{\code{subtype_label}}{...}
#'   \item{\code{dirpre}}{...}
#'   \item{\code{feanme}}{...}
#'   \item{\code{featype}}{...}
#'   \item{\code{dirsuf}}{...}
#'   \item{\code{fraddl}}{...}
#'   \item{\code{toaddl}}{...}
#'   \item{\code{fraddr}}{...}
#'   \item{\code{toaddr}}{...}
#'   \item{\code{fraddla}}{...}
#'   \item{\code{toaddla}}{...}
#'   \item{\code{fraddra}}{...}
#'   \item{\code{toaddra}}{...}
#'   \item{\code{leftzip}}{...}
#'   \item{\code{rightzip}}{...}
#'   \item{\code{fullname}}{...}
#'   \item{\code{sha_class}}{...}
#'   \item{\code{sha_class_label}}{...}
#'   \item{\code{blocktext}}{...}
#'   \item{\code{block_num}}{...}
#'   \item{\code{geometry}}{...}
#' }
#' @source \url{https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/7}
"streets"


#' Baltimore Water
#'
#' Detailed multipolygon data for streams, lakes, and other water in Baltimore City.
#'
#' @format A data frame with 468 rows and 6 variables:
#' \describe{
#'   \item{\code{name}}{Water feature name, if available}
#'   \item{\code{type}}{Water type}
#'   \item{\code{subtype}}{Water subtype}
#'   \item{\code{symbol}}{Symbol}
#'   \item{\code{water}}{Water indicator}
#'   \item{\code{geometry}}{Multipolygon geometry}
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/maryland-waterbodies-rivers-and-streams-detailed}
"baltimore_water"


#' Stories from Explore Baltimore Heritage
#'
#' A table of public stories on the Explore Baltimore Heritage website.
#'
#' @format A data frame with 459 rows and 10 variables:
#' \describe{
#'   \item{\code{id}}{Story identifier}
#'   \item{\code{featured}}{Featured indicator}
#'   \item{\code{modified}}{Modified date/time}
#'   \item{\code{title}}{Story title}
#'   \item{\code{address}}{Street address for story location}
#'   \item{\code{thumbnail}}{URL for thumbnail-size featured image}
#'   \item{\code{fullsize}}{URL for full-size featured image}
#'   \item{\code{url}}{URL for story}
#'   \item{\code{geometry}}{Point for story location}
#' }
#' @source \url{https://explore.baltimoreheritage.org/}
"explore_baltimore"


#' Housing Market Typology 2017
#'
#' The 2017 update of the City’s Housing Market Typology was jointly developed
#' by the Baltimore City Planning Department, Department of Housing & Community
#' Development, and The Reinvestment Fund.
#'
#' @format A data frame with 663 rows and 15 variables:
#' \describe{
#'   \item{\code{geoid}}{U.S. Census Block Group GeoID}
#'   \item{\code{geoid_part}}{Identifier for U.S. Census Block Group GeoID including part identifier}
#'   \item{\code{part}}{Part identifier}
#'   \item{\code{cluster}}{Housing market cluster}
#'   \item{\code{cluster_group}}{Housing market cluster}
#'   \item{\code{median_sales_price}}{Median sales price, Q3 2015 - Q2 2017}
#'   \item{\code{sales_price_variation}}{Sales price variation, Q3 2015 - Q2 2017}
#'   \item{\code{num_sales}}{Number of residential sales, Q3 2015 - Q2 2017}
#'   \item{\code{num_foreclosure_filings}}{Number of foreclosure filings, Q3 2015 - Q2 2017}
#'   \item{\code{perc_foreclosure_sales}}{Percent of sales through foreclosure, Q3 2015 - Q2 2017}
#'   \item{\code{perc_homeowners}}{Percent owner occupied, July 2017}
#'   \item{\code{perc_permits_over10k}}{Percent of residential building permits over $10,000, Q3 2015 - Q2 2017}
#'   \item{\code{vacant_lots_bldgs_per_acre_res}}{Vacant lots and buildings per residential acre, July 2017}
#'   \item{\code{units_per_acre_res}}{Housing units per residential acre, July 2017}
#'   \item{\code{geometry}}{Multipolygon geometry matching Census blocks groups or parts of block groups}
#' }
#' @source \url{https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Housing_Market_Typology_2017/FeatureServer/0}
"hmt_2017"

#' Adopted city plans, accepted community-initiated plans, and LINCS corridors
#'
#' Combined area plans and LINCS corridor data from the Baltimore City
#' Department of Planning.
#'
#' @format A data frame with 58 rows and 5 variables:
#' \describe{
#'   \item{\code{plan_name}}{Plan or area name}
#'   \item{\code{year_adopted}}{Year adopted or initiated}
#'   \item{\code{program}}{Planning program}
#'   \item{\code{url}}{URL of plan website or document}
#'   \item{\code{geometry}}{Multipolygon for plan areas and multilinestring for LINCS corridors}
#' }
#' @source \url{...}
"adopted_plans"

#' @title Baltimore Park Districts
#' @description Park districts for the Baltimore City Department of Recreation and Parks.
#' @format A data frame with 5 rows and 2 variables:
#' \describe{
#'   \item{\code{name}}{Park district name}
#'   \item{\code{geometry}}{Multipolygon geometry with park district boundaries}
#' }
"park_districts"

#' @title Baltimore City street intersection names
#' @description Index of Baltimore City intersections with names from streets
#'   within 20 meters of the intersection boundaries.
#' @format A data frame with 11506 rows and 3 variables:
#' \describe{
#'   \item{\code{id}}{Intersection identifier matching id in `edge_of_pavement` data}
#'   \item{\code{name}}{Intersection name}
#'   \item{\code{geometry}}{Points with center of intersections}
#' }
"named_intersections"

#' @title Charm City Circulator Routes
#' @description The Baltimore City Department of Transportation explains: "The
#'   Charm City Circulator (CCC), a fleet of 24 free shuttles that travel four
#'   routes in the central business district of Baltimore City, Maryland. The
#'   Harbor Connector (HC) is an extension of the CCC and is the City’s free
#'   maritime transit service connecting 6 piers through four vessels."
#' @format A data frame with 6 rows and 3 variables:
#' \describe{
#'   \item{\code{route_name}}{character Route name}
#'   \item{\code{alt_route_name}}{character Alternate route name}
#'   \item{\code{geometry}}{list Route geometry}
#' }
#' @source \href{https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/1}{Baltimore CityView - Charm City Circulator Routes}
"circulator_routes"

#' @title Charm City Circulator Stops
#' @description The Baltimore City Department of Transportation explains: "The
#'   Charm City Circulator (CCC), a fleet of 24 free shuttles that travel four
#'   routes in the central business district of Baltimore City, Maryland. The
#'   Harbor Connector (HC) is an extension of the CCC and is the City’s free
#'   maritime transit service connecting 6 piers through four vessels."
#' @format A data frame with 111 rows and 5 variables:
#' \describe{
#'   \item{\code{stop_num}}{integer Stop number}
#'   \item{\code{stop_location}}{character Intersection location (address, intersection, or landmark)}
#'   \item{\code{corner}}{character Intersection corner}
#'   \item{\code{route_name}}{character Route name}
#'   \item{\code{geometry}}{list Stop points}
#' }
#' @source \href{https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/0}{Baltimore CityView - Charm City Circulator Stops}
"circulator_stops"


#' @title Baltimore MSA water
#' @description Downloaded using tigris package.
#' @format A data frame with 3491 rows and 9 variables:
#' \describe{
#'   \item{\code{ansicode}}{American National Standards Institute codes (ANSI codes)}
#'   \item{\code{hydroid}}{Unique key for hydrographic features}
#'   \item{\code{fullname}}{Full name}
#'   \item{\code{mtfcc}}{MAF/TIGER Feature Class Code}
#'   \item{\code{aland}}{land area (square meters)}
#'   \item{\code{awater}}{water area (square meters)}
#'   \item{\code{intptlat}}{latitude of the internal point}
#'   \item{\code{intptlon}}{longitude of the internal point}
#'   \item{\code{geometry}}{Polygon geometry}
#' }
"baltimore_msa_water"

#' Baltimore public art works and monuments
#'
#' Placeholder documentation. Data created by Eli Poussona and C. Ryan Patterson
#' with contributions from staff and volunteers at CHAP, Baltimore Heritage, and
#' BOPA.
#'
#' @format A data frame with 1007 rows and 31 variables:
#' \describe{
#'   \item{\code{id}}{character COLUMN_DESCRIPTION}
#'   \item{\code{osm_id}}{character COLUMN_DESCRIPTION}
#'   \item{\code{title}}{character COLUMN_DESCRIPTION}
#'   \item{\code{primary_artist}}{character COLUMN_DESCRIPTION}
#'   \item{\code{location}}{character COLUMN_DESCRIPTION}
#'   \item{\code{type}}{character COLUMN_DESCRIPTION}
#'   \item{\code{medium}}{character COLUMN_DESCRIPTION}
#'   \item{\code{status}}{character COLUMN_DESCRIPTION}
#'   \item{\code{subject_person}}{character COLUMN_DESCRIPTION}
#'   \item{\code{creation_dedication_date}}{character COLUMN_DESCRIPTION}
#'   \item{\code{year_accuracy}}{character COLUMN_DESCRIPTION}
#'   \item{\code{street_address}}{character COLUMN_DESCRIPTION}
#'   \item{\code{city}}{character COLUMN_DESCRIPTION}
#'   \item{\code{state}}{character COLUMN_DESCRIPTION}
#'   \item{\code{zipcode}}{character COLUMN_DESCRIPTION}
#'   \item{\code{dimensions}}{character COLUMN_DESCRIPTION}
#'   \item{\code{program}}{character COLUMN_DESCRIPTION}
#'   \item{\code{funding}}{character COLUMN_DESCRIPTION}
#'   \item{\code{artist_assistants}}{character COLUMN_DESCRIPTION}
#'   \item{\code{architect}}{character COLUMN_DESCRIPTION}
#'   \item{\code{fabricator}}{character COLUMN_DESCRIPTION}
#'   \item{\code{neighborhood}}{character COLUMN_DESCRIPTION}
#'   \item{\code{council_district}}{character COLUMN_DESCRIPTION}
#'   \item{\code{location_desc}}{character COLUMN_DESCRIPTION}
#'   \item{\code{indoor_outdoor_access}}{character COLUMN_DESCRIPTION}
#'   \item{\code{related_property}}{character COLUMN_DESCRIPTION}
#'   \item{\code{property_ownership}}{character COLUMN_DESCRIPTION}
#'   \item{\code{agency_or_insitution}}{character COLUMN_DESCRIPTION}
#'   \item{\code{wikipedia_url}}{character COLUMN_DESCRIPTION}
#'   \item{\code{primary_artist_gender}}{character COLUMN_DESCRIPTION}
#'   \item{\code{geometry}}{list COLUMN_DESCRIPTION}
#'}
#' @details DETAILS
"public_art"
