#' Generalized political boundary for Baltimore City
#'
#' A generalized boundary for Baltimore City, Maryland
#' from statewide dataset of generalized county boundaries.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{`name`}{County name}
#'   \item{`countyfp`}{3-character county FIPS code}
#'   \item{`geoid`}{county identifier; a concatenation of state FIPS code and county FIPS code}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`geometry`}{Multipolygon with the boundary}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_city"

#' Detailed physical boundary for Baltimore City
#'
#' A detailed physical boundary of Baltimore City.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{`name`}{County name}
#'   \item{`countyfp`}{3-character county FIPS code}
#'   \item{`geometry`}{Multipolygon with the physical boundary}
#' }
#' @source <https://data.imap.maryland.gov/datasets/maryland-physical-boundaries-county-boundaries-detailed>
"baltimore_city_detailed"

#' Neighborhood boundaries for Baltimore City
#'
#' Baltimore City Neighborhoods or Neighborhood Statistical Areas
#'
#' @format A data frame with 278 rows and 2 variables:
#' \describe{
#'   \item{`name`}{Neighborhood name}
#'   \item{`type`}{Type of area, with options including residential, industrial area, park/open space, institutionl area and business park)}
#'   \item{`acres`}{Area of the neighborhood (acres)}
#'   \item{`osm_id`}{Open Street Map (OSM) relation identifier}
#'   \item{`wikidata`}{Wikidata entity identifier}
#'   \item{`geometry`}{Multipolygons with neighborhood boundary}
#' }
#' @source [Maryland Baltimore City Neighborhoods (MD iMap)](https://data.imap.maryland.gov/datasets/fc5d183b20a145009eae8f8b171eeb0d_0)
"neighborhoods"

#' @title U.S. Census Block-to-Tract Crosswalk with 2010 Block Household Population
#' @description Used to generate xwalk_neighborhood2tract.
#' @format A data frame with 13598 rows and 3 variables:
#' \describe{
#'   \item{`block`}{Block GeoID}
#'   \item{`tract`}{Tract GeoID}
#'   \item{`households`}{Block household population}
#' }
"xwalk_block2tract"

#' @title Neighborhood-to-U.S. Census Tract Crosswalk
#' @description Share of total households is based on the proportion of U.S.
#'   Census tract population within the named neighborhood based on overlapping
#'   U.S. Census Block groups.
#' @format A data frame with 551 rows and 4 variables:
#' \describe{
#'   \item{`name`}{Neighborhood name}
#'   \item{`geoid`}{GeoID for U.S. Census tract}
#'   \item{`tract`}{Tract number}
#'   \item{`weight_households`}{Share of total households in neighborhood and U.S. Census tract (based on 2010 decennial Census). Variable code is "H013001".}
#'   \item{`weight_units`}{Share of occupied housing units in neighborhood and U.S. Census tract (based on 2020 decennial Census PL-94171 redistricting data). Variable code is "H1_002N".}
#' }
"xwalk_neighborhood2tract"

#' Baltimore City Police Districts
#'
#' Baltimore City Police Districts
#'
#' @format A data frame with 9 rows and 3 variables:
#' \describe{
#'   \item{`number`}{Police district number}
#'   \item{`name`}{Police district name}
#'   \item{`geometry`}{Multipolygons with district boundary}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries/MapServer/7>
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
#'   \item{`id`}{Community Statistical Area id number}
#'   \item{`name`}{Community Statistical Area name}
#'   \item{`url`}{URL to BNIA-JFI webpage on Community Statistical Area}
#'   \item{`geometry`}{Multipolygon with area boundary}
#' }
#' @source <https://bniajfi.org/mapping-resources/>
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
#'   \item{`id`}{Community Statistical Area id number}
#'   \item{`csa`}{Community Statistical Area name}
#'   \item{`nsa`}{Neighborhood Statistical Area name}
#'   \item{`neighborhood`}{Neighborhood name}
#' }
#' @source <https://bniajfi.org/mapping-resources/>
"xwalk_csa2nsa"

#' @title Zipcode-to-Community Statistical Area (NSA) Crosswalk
#' @description A crosswalk to match zipcodes to Community Statistical Areas.
#' @format A data frame with 119 rows and 3 variables:
#' \describe{
#'   \item{`zip`}{Zipcode}
#'   \item{`csa`}{Community Statistical Area name}
#'   \item{`id`}{Community Statistical Area id number}
#' }
#' @source <https://bniajfi.org/mapping-resources/>
"xwalk_zip2csa"

#' County boundaries for the Baltimore–Columbia–Towson MSA
#'
#' Counties boundaries in the Baltimore–Columbia–Towson Metropolitan Statistical Area (MSA)
#' include Baltimore City, Baltimore County, Carroll County, Anne Arundel County,
#' Howard County, Queen Anne's County, and Harford County.
#'
#' @format A data frame with 7 rows and 18 variables:
#' \describe{
#'   \item{`statefp`}{State FIPS code for Maryland}
#'   \item{`countyfp`}{County FIPS code}
#'   \item{`countyns`}{County GNIS code}
#'   \item{`geoid`}{Unique county FIPS code (concatenation of state and county FIPS codes)}
#'   \item{`name`}{County name}
#'   \item{`namelsad`}{Concatenated variable length geographic area name and legal/statistical area description (LSAD)}
#'   \item{`lsad`}{Legal/statistical area description (LSAD)}
#'   \item{`classfp`}{FIPS class code}
#'   \item{`mtfcc`}{MAF/TIGER Feature Class Code (MTFCC)}
#'   \item{`csafp`}{Combined statistical area code}
#'   \item{`cbsafp`}{Metropolitan statistical area/micropolitan statistical area code}
#'   \item{`metdivfp`}{Metropolitan division code}
#'   \item{`funcstat`}{Functional status}
#'   \item{`aland`}{Land area (square meters)}
#'   \item{`awater`}{Water area (square meters)}
#'   \item{`intptlat`}{Latitude of the internal point}
#'   \item{`intptlon`}{Longitude of the internal point}
#'   \item{`geometry`}{Multipolygon with the county boundary}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
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
#'  \item{`statefp10`}{State FIPS code for Maryland}
#'  \item{`pumace10`}{PUMA code}
#'  \item{`geoid10`}{GeoID}
#'  \item{`namelsad10`}{name and the translated legal/statistical area description code for census tract}
#'  \item{`mtfcc10`}{MAF/TIGER Feature Class Code (MTFCC)}
#'  \item{`funcstat10`}{functional status}
#'  \item{`aland10`}{land area (square meters)}
#'  \item{`awater10`}{water area (square meters)}
#'  \item{`intptlat10`}{latitude of the internal point}
#'  \item{`intptlon10`}{longitude of the internal point}
#'  \item{`geometry`}{Polygon with PUMA boundary}
#'  }
"baltimore_pumas"

#' U.S. Census Tracts
#'
#' ...
#'
#' @format A data frame with 200 rows and 9 variables:
#' \describe{
#'   \item{`tractce`}{census tract code}
#'   \item{`geoid`}{nation-based census tract identifier; a concatenation of state FIPS code, county FIPS code, and census tract number}
#'   \item{`name`}{Variable length geographic area name}
#'   \item{`namelsad`}{name and the translated legal/statistical area description code for census tract}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`geometry`}{Polygon with tract boundary}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_tracts"


#' U.S. Census Block Groups
#'
#' ...
#'
#' @format A data frame with 653 rows and 9 variables:
#' \describe{
#'   \item{`tractce`}{census tract code}
#'   \item{`blkgrpce`}{block group number}
#'   \item{`geoid`}{Census block group identifier; a concatenation of the state FIPS code, county FIPS code, census tract code, and block group number}
#'   \item{`namelsad`}{translated legal/statistical area description and the block group number}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`geometry`}{Polygon with block group boundary}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_block_groups"


#' U.S. Census Blocks (2010 Decennial)
#'
#' ...
#'
#' @format A data frame with 13,598 rows and 9 variables:
#' \describe{
#'   \item{`tractce10`}{Tract FIPS}
#'   \item{`blockce10`}{Block FIPS}
#'   \item{`geoid10`}{Block GeoID}
#'   \item{`name10`}{Block name}
#'   \item{`aland10`}{Land area}
#'   \item{`awater10`}{Water area}
#'   \item{`intptlat10`}{Interior center point latitude}
#'   \item{`intptlon10`}{Interior center point longitude}
#'   \item{`geometry`}{Multipolygon with block boundary}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_blocks"


#' Maryland Transit Administration (MTA) Bus Routes
#'
#' Maryland Department of Transportation's Maryland Transit Administration
#' Summer 2020 Bus Routes including CityLink, LocalLink and Commuter Bus.
#' The data reflect bus route changes as of July 12, 2020.
#'
#' @format A data frame with 103 rows and 4 variables:
#' \describe{
#'   \item{`route_name`}{Name of the bus route}
#'   \item{`route_type`}{Type of route, CityLink, LocalLink and Commuter Bus}
#'   \item{`route_number`}{Unique route number or color identifier}
#'   \item{`route_abb`}{Route abbreviation (only different for color CityLink routes)}
#'   \item{`frequent`}{Logical indicator of route inclusion in MTA BaltimoreLink's Frequent Transit Network.}
#'   \item{`geometry`}{Multilinestring with the bus route path}
#' }
#' @source [Maryland Transit - MTA Bus Lines (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1)
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
#'   \item{`stop_id`}{Stop identification number}
#'   \item{`stop_name`}{Stop name}
#'   \item{`rider_on`}{Average daily weekday count of riders boarding transit at stop}
#'   \item{`rider_off`}{Average daily weekday count of riders alighting transit at stop}
#'   \item{`rider_total`}{Average daily weekday count of total riders served at stop}
#'   \item{`stop_ridership_rank`}{Stop rank for ridership}
#'   \item{`routes_served`}{Routes served at stop}
#'   \item{`mode`}{Mode served at stop}
#'   \item{`shelter`}{Logical indicator of bus shelter availability}
#'   \item{`county`}{County where stop is located}
#'   \item{`geometry`}{Point with location of stop}
#' }
#' @source [Maryland Transit - MTA Bus Stops (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-stops-1)
"mta_bus_stops"

#' @title Maryland Transit Administration (MTA) SubwayLink Metro Lines
#' @description DATASET_DESCRIPTION
#' @format A data frame with 34 rows and 8 variables:
#' \describe{
#'   \item{`id`}{integer COLUMN_DESCRIPTION}
#'   \item{`rail_name`}{character COLUMN_DESCRIPTION}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`tunnel`}{character COLUMN_DESCRIPTION}
#'   \item{`direction`}{character COLUMN_DESCRIPTION}
#'   \item{`miles`}{double COLUMN_DESCRIPTION}
#'   \item{`status`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
"mta_subway_lines"

#' @title Maryland Transit Administration (MTA) SubwayLink Metro Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 14 rows and 10 variables:
#' \describe{
#'   \item{`id`}{integer Station identification number}
#'   \item{`name`}{Station name}
#'   \item{`address`}{Station street address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`avg_wkdy`}{integer COLUMN_DESCRIPTION}
#'   \item{`avg_wknd`}{integer COLUMN_DESCRIPTION}
#'   \item{`facility_type`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
"mta_subway_stations"

#' @title Maryland Transit Administration (MTA) Light RailLink Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 84 rows and 8 variables:
#' \describe{
#'   \item{`id`}{integer COLUMN_DESCRIPTION}
#'   \item{`rail_name`}{character COLUMN_DESCRIPTION}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`tunnel`}{character COLUMN_DESCRIPTION}
#'   \item{`direction`}{character COLUMN_DESCRIPTION}
#'   \item{`miles`}{double COLUMN_DESCRIPTION}
#'   \item{`status`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source [Maryland Transit - Light Rail Lines (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-light-rail-lines/)
"mta_light_rail_lines"

#' @title Maryland Transit Administration (MTA) Light RailLink Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 33 rows and 11 variables:
#' \describe{
#'   \item{`id`}{integer COLUMN_DESCRIPTION}
#'   \item{`name`}{character COLUMN_DESCRIPTION}
#'   \item{`address`}{character COLUMN_DESCRIPTION}
#'   \item{`city`}{character COLUMN_DESCRIPTION}
#'   \item{`state`}{character COLUMN_DESCRIPTION}
#'   \item{`zipcode`}{integer COLUMN_DESCRIPTION}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`avg_wkdy`}{integer COLUMN_DESCRIPTION}
#'   \item{`avg_wknd`}{character COLUMN_DESCRIPTION}
#'   \item{`facility_type`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source [Maryland Transit - Light RailLink Stations (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-light-raillink-stations/)
"mta_light_rail_stations"

#' @title MTA MARC Train Lines
#' @description DATASET_DESCRIPTION
#' @format A data frame with 162 rows and 8 variables:
#' \describe{
#'   \item{`id`}{integer COLUMN_DESCRIPTION}
#'   \item{`rail_name`}{character COLUMN_DESCRIPTION}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`tunnel`}{character COLUMN_DESCRIPTION}
#'   \item{`direction`}{character COLUMN_DESCRIPTION}
#'   \item{`miles`}{double COLUMN_DESCRIPTION}
#'   \item{`status`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source [Maryland Transit - MARC Train Lines (MD iMap)](https://data.imap.maryland.gov/datasets/de0efbe9f8884ac5aa69864b6b3ff633_10/)
"mta_marc_lines"

#' @title MTA MARC Train Stations
#' @description DATASET_DESCRIPTION
#' @format A data frame with 44 rows and 12 variables:
#' \describe{
#'   \item{`id`}{integer COLUMN_DESCRIPTION}
#'   \item{`name`}{character COLUMN_DESCRIPTION}
#'   \item{`address`}{character COLUMN_DESCRIPTION}
#'   \item{`city`}{character COLUMN_DESCRIPTION}
#'   \item{`state`}{character COLUMN_DESCRIPTION}
#'   \item{`zipcode`}{integer COLUMN_DESCRIPTION}
#'   \item{`line_name`}{character COLUMN_DESCRIPTION}
#'   \item{`mode`}{character COLUMN_DESCRIPTION}
#'   \item{`avg_wkdy`}{integer COLUMN_DESCRIPTION}
#'   \item{`avg_wknd`}{integer COLUMN_DESCRIPTION}
#'   \item{`facility_type`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
#' @source [Maryland Transit - MARC Trains Stations (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-marc-trains-stations/)
"mta_marc_stations"

#' Baltimore City Public Schools School Zones or School Attendance Zones
#'
#' Baltimore City Public Schools School Zones also known as School Attendance Zones.
#'
#' @format A data frame with 96 rows and 4 variables:
#' \describe{
#'   \item{`program_name`}{Program or school name}
#'   \item{`program_number`}{Program number}
#'   \item{`zone_name`}{Program name with zone appended}
#'   \item{`geometry`}{Multipolygons with school zone boundaries}
#' }
#' @source <https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/BCPSZones_2021/FeatureServer/0>
"bcps_zones"


#' Baltimore City Public School Programs
#'
#' Locations of school buildings/school programs.
#'
#' @format A data frame with 165 rows and 6 variables:
#' \describe{
#'   \item{`program_name`}{Program or school name}
#'   \item{`program_number`}{Program number}
#'   \item{`type`}{Program type}
#'   \item{`category`}{Program category, e.g. E, EM, H, etc.}
#'   \item{`zone_name`}{Program name with zone appended}
#'   \item{`geometry`}{Multipolygons with school program location}
#' }
#' @source <https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2021_Programs/FeatureServer/0>
"bcps_programs"


#' Baltimore City Zoning Code
#'
#' The Baltimore City Zoning Code is administered by the Baltimore City
#' Department of Housing and Community Development (HCD) Office of the
#' Zoning Administrator. This office supports the Board of Municipal Zoning Appeals (BMZA).
#'
#' @format A data frame with 2,406 rows and 4 variables:
#' \describe{
#'   \item{`zoning`}{Zoning designation code}
#'   \item{`overlay`}{Overlay zone designation}
#'   \item{`label`}{Label combining zoning and overlay zoning codes}
#'   \item{`category_zoning`}{Zoning code category}
#'   \item{`name_zoning`}{Zoning code name}
#'   \item{`category_overlay`}{Overlay code category}
#'   \item{`name_overlay`}{Overlay zoning name}
#'   \item{`geometry`}{Multipolygons for areas with shared zoning}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/20>
"zoning"

#' Baltimore City Council Districts
#'
#' Baltimore City Council Districts used since 2012 (following boundary
#' revisions completed in 2011).
#'
#' @format A data frame with 14 rows and 2 variables:
#' \describe{
#'   \item{`id`}{Number of the City Council district}
#'   \item{`name`}{Name of the City Council district}
#'   \item{`geometry`}{Multipolygons for boundaries of City Council districts}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/CityView/City_Council_Districts/MapServer/0>
"council_districts"


#' Baltimore City Planning Districts
#'
#' Administrative boundaries set by the Baltimore City Department of Planning.
#'
#' @format A data frame with 11 rows and 4 variables:
#' \describe{
#'   \item{`id`}{Planning district area identifier}
#'   \item{`name`}{Full name of the planning district}
#'   \item{`abb`}{Planning district area abbreviation}
#'   \item{`geometry`}{Multipolygon boundary of the planning district}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0>
"planning_districts"


#' Maryland Legislative Districts for Baltimore City
#'
#' ...
#'
#' @format A data frame with 6 rows and 4 variables:
#' \describe{
#'   \item{`name`}{District name}
#'   \item{`id`}{District number}
#'   \item{`label`}{District label}
#'   \item{`geometry`}{Multipolygon data with district boundaries}
#' }
#' @source <https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1>
"legislative_districts"


#' U.S. Congressional Districts for Baltimore City
#'
#' U.S. Congressional Districts overlapping with Baltimore City. Downloaded with
#' the tigris package.
#'
#' @format A data frame with 3 rows and 15 variables:
#' \describe{
#'   \item{`statefp`}{2-character state FIPS code}
#'   \item{`cd116fp`}{116th congressional district FIPS code}
#'   \item{`geoid`}{GeoID}
#'   \item{`namelsad`}{concatenated variable length geographic area name and legal/statistical area description (LSAD)}
#'   \item{`lsad`}{Legal/statistical area description (LSAD)}
#'   \item{`cdsessn`}{Congressional session code}
#'   \item{`mtfcc`}{MAF/TIGER Feature Class Code (MTFCC)}
#'   \item{`funcstat`}{functional status}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`label`}{Congressional District label}
#'   \item{`name`}{Congressional District name}
#'   \item{`geometry`}{Multipolygon with Congressional district boundary}
#' }
#' @source <...>
"congressional_districts"



#' Baltimore City Parks
#'
#' Spatial data for parks and public recreation centers in Baltimore City from
#' the Baltimore City Department of Recreation and Parks. A few names have been
#' updated to use common names or recent new official names so the package
#' version may not match the city data in all cases.
#'
#' @format A data frame with 297 rows and 6 variables:
#' \describe{
#'   \item{`name`}{Park name}
#'   \item{`id`}{Identification number from city data}
#'   \item{`address`}{Primary street address}
#'   \item{`name_alt`}{Alternate name}
#'   \item{`operator`}{Park operator, Baltimore City Department of Recreation and Parks (BCRP) or other}
#'   \item{`park_district`}{Park maintenance district for BCRP}
#'   \item{`acres`}{Area of the park property (acres)}
#'   \item{`geometry`}{Multipolygon with park edges}
#' }
#' @source <https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2>
"parks"


#' 311 Service Request Types for Baltimore City
#'
#' A list of request types based on unique request types used between January 2019 and October 2020.
#'
#' @format A data frame with 320 rows and 1 variables:
#' \describe{
#'   \item{`request_type`}{Service request type}
#' }
#' @source <...>
"request_types"


#' Historic Ward Boundaries, 1797-1918 for Baltimore City
#'
#' Historic ward boundary data from 1797 to 1918. Derived from KML data provided by the Baltimore City Archives.
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{`year`}{Earliest effective year of ward boundary}
#'   \item{`name`}{Ward name}
#'   \item{`number`}{Ward number}
#'   \item{`geometry`}{Multipolygons with ward boundary for year}
#' }
#' @source <https://msa.maryland.gov/bca/wards/index.html>
"wards_1797_1918"

#' Maryland Inventory of Historic Properties in Baltimore City
#'
#' ...
#'
#' @format A data frame with 5,203 rows and 14 variables:
#' \describe{
#'   \item{`num_polys`}{...}
#'   \item{`mihp_id`}{...}
#'   \item{`property_id`}{...}
#'   \item{`mihp_num`}{...}
#'   \item{`name`}{...}
#'   \item{`alternate_name`}{...}
#'   \item{`full_address`}{...}
#'   \item{`town`}{...}
#'   \item{`county`}{...}
#'   \item{`pdflink`}{...}
#'   \item{`xcoord`}{...}
#'   \item{`ycoord`}{...}
#'   \item{`do_erecord`}{...}
#'   \item{`geoms`}{...}
#' }
#' @source <...>
"baltimore_mihp"


#' Baltimore City Street Center lines
#'
#' ...
#'
#' @format Simple feature collection with 48,473 features and 23 fields.
#' \describe{
#'   \item{`type`}{...}
#'   \item{`subtype`}{...}
#'   \item{`subtype_label`}{...}
#'   \item{`dirpre`}{...}
#'   \item{`feanme`}{...}
#'   \item{`featype`}{...}
#'   \item{`dirsuf`}{...}
#'   \item{`fraddl`}{...}
#'   \item{`toaddl`}{...}
#'   \item{`fraddr`}{...}
#'   \item{`toaddr`}{...}
#'   \item{`fraddla`}{...}
#'   \item{`toaddla`}{...}
#'   \item{`fraddra`}{...}
#'   \item{`toaddra`}{...}
#'   \item{`leftzip`}{...}
#'   \item{`rightzip`}{...}
#'   \item{`fullname`}{...}
#'   \item{`sha_class`}{...}
#'   \item{`sha_class_label`}{...}
#'   \item{`blocktext`}{...}
#'   \item{`block_num`}{...}
#'   \item{`geometry`}{...}
#' }
#' @source <https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/7>
"streets"


#' Baltimore Water
#'
#' Detailed multipolygon data for streams, lakes, and other water in Baltimore City.
#'
#' @format A data frame with 468 rows and 6 variables:
#' \describe{
#'   \item{`name`}{Water feature name, if available}
#'   \item{`type`}{Water type}
#'   \item{`subtype`}{Water subtype}
#'   \item{`symbol`}{Symbol}
#'   \item{`water`}{Water indicator}
#'   \item{`geometry`}{Multipolygon geometry}
#' }
#' @source <https://data.imap.maryland.gov/datasets/maryland-waterbodies-rivers-and-streams-detailed>
"baltimore_water"


#' Stories from Explore Baltimore Heritage
#'
#' A table of public stories on the Explore Baltimore Heritage website.
#'
#' @format A data frame with 459 rows and 10 variables:
#' \describe{
#'   \item{`id`}{Story identifier}
#'   \item{`featured`}{Featured indicator}
#'   \item{`modified`}{Modified date/time}
#'   \item{`title`}{Story title}
#'   \item{`address`}{Street address for story location}
#'   \item{`thumbnail`}{URL for thumbnail-size featured image}
#'   \item{`fullsize`}{URL for full-size featured image}
#'   \item{`url`}{URL for story}
#'   \item{`geometry`}{Point for story location}
#' }
#' @source <https://explore.baltimoreheritage.org/>
"explore_baltimore"


#' Housing Market Typology 2017
#'
#' The 2017 update of the City’s Housing Market Typology was jointly developed
#' by the Baltimore City Planning Department, Department of Housing & Community
#' Development, and The Reinvestment Fund.
#'
#' @format A data frame with 663 rows and 15 variables:
#' \describe{
#'   \item{`geoid`}{U.S. Census Block Group GeoID}
#'   \item{`geoid_part`}{Identifier for U.S. Census Block Group GeoID including part identifier}
#'   \item{`part`}{Part identifier}
#'   \item{`cluster`}{Housing market cluster}
#'   \item{`cluster_group`}{Housing market cluster}
#'   \item{`median_sales_price`}{Median sales price, Q3 2015 - Q2 2017}
#'   \item{`sales_price_variation`}{Sales price variation, Q3 2015 - Q2 2017}
#'   \item{`num_sales`}{Number of residential sales, Q3 2015 - Q2 2017}
#'   \item{`num_foreclosure_filings`}{Number of foreclosure filings, Q3 2015 - Q2 2017}
#'   \item{`perc_foreclosure_sales`}{Percent of sales through foreclosure, Q3 2015 - Q2 2017}
#'   \item{`perc_homeowners`}{Percent owner occupied, July 2017}
#'   \item{`perc_permits_over10k`}{Percent of residential building permits over $10,000, Q3 2015 - Q2 2017}
#'   \item{`vacant_lots_bldgs_per_acre_res`}{Vacant lots and buildings per residential acre, July 2017}
#'   \item{`units_per_acre_res`}{Housing units per residential acre, July 2017}
#'   \item{`geometry`}{Multipolygon geometry matching Census blocks groups or parts of block groups}
#' }
#' @source <https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Housing_Market_Typology_2017/FeatureServer/0>
"hmt_2017"

#' Adopted city plans, accepted community-initiated plans, and LINCS corridors
#'
#' Combined area plans and LINCS corridor data from the Baltimore City
#' Department of Planning.
#'
#' @format A data frame with 58 rows and 5 variables:
#' \describe{
#'   \item{`plan_name`}{Plan or area name}
#'   \item{`year_adopted`}{Year adopted or initiated}
#'   \item{`program`}{Planning program}
#'   \item{`url`}{URL of plan website or document}
#'   \item{`geometry`}{Multipolygon for plan areas and multilinestring for LINCS corridors}
#' }
#' @source <...>
"adopted_plans"

#' @title Baltimore Park Districts
#' @description Park districts for the Baltimore City Department of Recreation and Parks.
#' @format A data frame with 5 rows and 2 variables:
#' \describe{
#'   \item{`name`}{Park district name}
#'   \item{`geometry`}{Multipolygon geometry with park district boundaries}
#' }
"park_districts"

#' @title Baltimore City street intersection names
#' @description Index of Baltimore City intersections with names from streets
#'   within 20 meters of the intersection boundaries.
#' @format A data frame with 11506 rows and 3 variables:
#' \describe{
#'   \item{`id`}{Intersection identifier matching id in `edge_of_pavement` data}
#'   \item{`name`}{Intersection name}
#'   \item{`geometry`}{Points with center of intersections}
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
#'   \item{`route_name`}{character Route name}
#'   \item{`alt_route_name`}{character Alternate route name}
#'   \item{`geometry`}{list Route geometry}
#' }
#' @source [Baltimore CityView - Charm City Circulator Routes](https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/1)
"circulator_routes"

#' @title Charm City Circulator Stops
#' @description The Baltimore City Department of Transportation explains: "The
#'   Charm City Circulator (CCC), a fleet of 24 free shuttles that travel four
#'   routes in the central business district of Baltimore City, Maryland. The
#'   Harbor Connector (HC) is an extension of the CCC and is the City’s free
#'   maritime transit service connecting 6 piers through four vessels."
#' @format A data frame with 111 rows and 5 variables:
#' \describe{
#'   \item{`stop_num`}{integer Stop number}
#'   \item{`stop_location`}{character Intersection location (address, intersection, or landmark)}
#'   \item{`corner`}{character Intersection corner}
#'   \item{`route_name`}{character Route name}
#'   \item{`geometry`}{list Stop points}
#' }
#' @source [Baltimore CityView - Charm City Circulator Stops](https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/0)
"circulator_stops"


#' @title Baltimore MSA water
#' @description Downloaded using tigris package.
#' @format A data frame with 3491 rows and 9 variables:
#' \describe{
#'   \item{`ansicode`}{American National Standards Institute codes (ANSI codes)}
#'   \item{`hydroid`}{Unique key for hydrographic features}
#'   \item{`fullname`}{Full name}
#'   \item{`mtfcc`}{MAF/TIGER Feature Class Code}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`geometry`}{Polygon geometry}
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
#'   \item{`id`}{character COLUMN_DESCRIPTION}
#'   \item{`osm_id`}{character COLUMN_DESCRIPTION}
#'   \item{`title`}{character COLUMN_DESCRIPTION}
#'   \item{`primary_artist`}{character COLUMN_DESCRIPTION}
#'   \item{`location`}{character COLUMN_DESCRIPTION}
#'   \item{`type`}{character COLUMN_DESCRIPTION}
#'   \item{`medium`}{character COLUMN_DESCRIPTION}
#'   \item{`status`}{character COLUMN_DESCRIPTION}
#'   \item{`subject_person`}{character COLUMN_DESCRIPTION}
#'   \item{`creation_dedication_date`}{character COLUMN_DESCRIPTION}
#'   \item{`year_accuracy`}{character COLUMN_DESCRIPTION}
#'   \item{`street_address`}{character COLUMN_DESCRIPTION}
#'   \item{`city`}{character COLUMN_DESCRIPTION}
#'   \item{`state`}{character COLUMN_DESCRIPTION}
#'   \item{`zipcode`}{character COLUMN_DESCRIPTION}
#'   \item{`dimensions`}{character COLUMN_DESCRIPTION}
#'   \item{`program`}{character COLUMN_DESCRIPTION}
#'   \item{`funding`}{character COLUMN_DESCRIPTION}
#'   \item{`artist_assistants`}{character COLUMN_DESCRIPTION}
#'   \item{`architect`}{character COLUMN_DESCRIPTION}
#'   \item{`fabricator`}{character COLUMN_DESCRIPTION}
#'   \item{`neighborhood`}{character COLUMN_DESCRIPTION}
#'   \item{`council_district`}{character COLUMN_DESCRIPTION}
#'   \item{`location_desc`}{character COLUMN_DESCRIPTION}
#'   \item{`indoor_outdoor_access`}{character COLUMN_DESCRIPTION}
#'   \item{`related_property`}{character COLUMN_DESCRIPTION}
#'   \item{`property_ownership`}{character COLUMN_DESCRIPTION}
#'   \item{`agency_or_insitution`}{character COLUMN_DESCRIPTION}
#'   \item{`wikipedia_url`}{character COLUMN_DESCRIPTION}
#'   \item{`primary_artist_gender`}{character COLUMN_DESCRIPTION}
#'   \item{`geometry`}{list COLUMN_DESCRIPTION}
#' }
#' @details DETAILS
"public_art"


#' Baltimore data table labels
#'
#' From [Google Sheet](https://docs.google.com/spreadsheets/d/1FXEJlhccnhoQmSO2WydBidXIw-f2lpomURDGy9KBgJw/edit?usp=sharing)
#'
#' @format A data frame with 9 rows and 7 variables:
#' \describe{
#'   \item{\code{fn_name}}{character Function name}
#'   \item{\code{table}}{character Table name}
#'   \item{\code{col}}{character Column name}
#'   \item{\code{label}}{character Column label}
#'   \item{\code{definition}}{logical Column variable definition}
#'   \item{\code{source}}{logical Column variable data source}
#'   \item{\code{fmt}}{character Column data format}
#' }
"balt_tbl_labs"
