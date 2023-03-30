#' Generalized political boundary for Baltimore City
#'
#' A generalized boundary for Baltimore City, Maryland using TIGER/Line
#' Shapefiles data from the U.S. Census Bureau downloaded with
#' [tigris::county_subdivisions()].
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
#'   \item{`geometry`}{MULITPOLYGON boundary geometry}
#' }
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_city"

#' Baltimore City WGS84 Bounding Box
#'
#' A generalized boundary for Baltimore City, Maryland (`baltimore_city`)
#' converted to a bounding box object using a EPSG:4326 coordinate reference
#' system.
#'
#' @format A `bbox` class object.
#' @source <https://www.census.gov/geo/maps-data/data/tiger-line.html>
"baltimore_bbox"

#' Detailed physical boundary for Baltimore City
#'
#' A detailed physical boundary of Baltimore City filtered from statewide
#' detailed boundary data available through Maryland iMap.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{`name`}{County name}
#'   \item{`countyfp`}{3-character county FIPS code}
#'   \item{`geometry`}{MULITPOLYGON boundary geometry}
#' }
#' @source [Maryland Physical Boundaries - County Boundaries (Detailed)](https://data.imap.maryland.gov/datasets/maryland-physical-boundaries-county-boundaries-detailed)
"baltimore_city_detailed"

#' Neighborhood Boundaries for Baltimore City (2010)
#'
#' Baltimore City neighborhoods (officially known as Neighborhood Statistical
#' Areas) established by the Baltimore City Department of Planning based on the
#' 2010 U.S. Decennial Census. Note that these boundaries may or may not be used
#' by local community or neighborhood associations as an area of responsibility
#' or membership recruitment.
#'
#' @format A data frame with 278 rows and 2 variables:
#' \describe{
#'   \item{`name`}{Neighborhood name}
#'   \item{`type`}{Type of area, with options including residential, industrial area, park/open space, institutionl area and business park)}
#'   \item{`acres`}{Area of the neighborhood (acres)}
#'   \item{`osm_id`}{Open Street Map (OSM) relation identifier}
#'   \item{`wikidata`}{Wikidata entity identifier}
#'   \item{`geometry`}{MULITPOLYGON boundary geometry}
#' }
#' @source [Maryland Baltimore City Neighborhoods (MD iMap)](https://data.imap.maryland.gov/datasets/fc5d183b20a145009eae8f8b171eeb0d_0)
"neighborhoods"

#' U.S. Census Block-to-Tract Crosswalk with 2010 Block Household Population
#'
#' A crosswalk file used to generate `xwalk_neighborhood2tract`.
#'
#' @format A data frame with 13598 rows and 3 variables:
#' \describe{
#'   \item{`block`}{Block GeoID}
#'   \item{`tract`}{Tract GeoID}
#'   \item{`households`}{Block household population}
#' }
"xwalk_block2tract"

#' Neighborhood-to-U.S. Census Tract Crosswalk
#'
#' Share of total households is based on the proportion of U.S.
#'   Census tract population within the named neighborhood based on overlapping
#'   U.S. Census Block groups.
#'
#' @format A data frame with 551 rows and 4 variables:
#' \describe{
#'   \item{`name`}{Neighborhood name}
#'   \item{`geoid`}{GeoID for U.S. Census tract}
#'   \item{`tract`}{Tract number}
#'   \item{`weight_households`}{Share of total households in neighborhood and
#'   U.S. Census tract (based on 2010 decennial Census). Variable code is
#'   "H013001".}
#'   \item{`weight_units`}{Share of occupied housing units in neighborhood and
#'   U.S. Census tract (based on 2020 decennial Census PL-94171 redistricting
#'   data). Variable code is "H1_002N".}
#' }
"xwalk_neighborhood2tract"

#' Baltimore City Police Districts (1959-2022)
#'
#' Baltimore City Police Districts established in 1959 and used through 2022.
#' Note this data will be moved to a separate object for historic district
#' boundaries in 2023.
#'
#' @format A data frame with 9 rows and 3 variables:
#' \describe{
#'   \item{`number`}{Police district number}
#'   \item{`name`}{Police district name}
#'   \item{`geometry`}{MULITPOLYGON boundary geometry}
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
#'   \item{`geometry`}{MULITPOLYGON boundary geometry}
#' }
#' @source <https://bniajfi.org/mapping-resources/>
"csas"

#' Community Statistical Area (CSA)-to-Neighborhood Statistical Area (NSA) Crosswalk
#'
#' A crosswalk to match Community Statistical Areas to Neighborhood Statistical
#' Areas. Both a Neighborhood Statistical Area name and neighborhood name are
#' provided, with the NSA name matching the crosswalk file provided by BNIA-JFI
#' and the neighborhood name matching the neighborhoods data included with the
#' mapbaltimore package. NSA boundaries may overlap over several CSAs. When more
#' than 50% of a NSA falls within a particular community it is assigned to that
#' community. No NSAs in these files are assigned to more than one community.
#'
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

#' Maryland Transit Administration (MTA) Bus Routes (2022)
#'
#' Maryland Department of Transportation's Maryland Transit Administration
#' Summer 2022 Bus Routes including CityLink, LocalLink, Express BusLink and
#' Commuter Bus services and reflects bus route changes as of June 19, 2022. For
#' full details of service change visit:
#' <https://www.mta.maryland.gov/servicechanges/summer2022>
#'
#' @format A data frame with 103 rows and 4 variables:
#' \describe{
#'   \item{`route_name`}{Bus route name}
#'   \item{`route_type`}{Route type (CityLink, LocalLink, or Commuter Bus)}
#'   \item{`route_number`}{Unique route number or color identifier}
#'   \item{`route_abb`}{Route abbreviation (only different from `route_number`
#'   for color CityLink routes)}
#'   \item{`frequent`}{Logical indicator of route inclusion in MTA
#'   BaltimoreLink's Frequent Transit Network.}
#'   \item{`school`}{Indicator for school routes}
#'   \item{`geometry`}{MULTILINESTRING bus route geometry}
#' }
#' @source [Maryland Transit - MTA Bus Lines (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1)
"mta_bus_lines"

#' Maryland Transit Administration (MTA) Bus Stops (2022)
#'
#' Maryland Department of Transportation's Maryland Transit
#'   Administration Bus Stops including CityLink, LocalLink, Express BusLink,
#'   and Commuter Bus. This data is based on the Summer 2022 schedule and
#'   reflects bus stop changes as of June 19, 2022. Ridership data is based on
#'   Automatic Passenger Counting (APC) system average daily weekday bus stop
#'   ridership (boarding, alighting, and total) from the Winter 2022 period and
#'   does not exclude outliers. For full details of service change visit:
#'   <https://www.mta.maryland.gov/servicechanges/summer2022>
#'
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
#'   \item{`geometry`}{POINT stop location geometry}
#' }
#' @source [Maryland Transit - MTA Bus Stops (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-stops-1)
"mta_bus_stops"

#' Maryland Transit Administration (MTA) SubwayLink Metro Lines
#'
#' Route of MTA SubwayLink Metro Line.
#'
#' @format A data frame with 34 rows and 8 variables:
#' \describe{
#'   \item{`id`}{Feature id number as integer}
#'   \item{`rail_name`}{Subway line name (Metro Line)}
#'   \item{`mode`}{Travel mode (Metro)}
#'   \item{`tunnel`}{Section tunnel indicator}
#'   \item{`direction`}{Travel direction}
#'   \item{`miles`}{Section mileage}
#'   \item{`status`}{Section status}
#'   \item{`geometry`}{MULTILINESTRING geometry for lines}
#' }
#' @source [Baltimore Metro Subway Line](https://geodata.md.gov/imap/rest/services/Transportation/MD_Transit/FeatureServer/5)
"mta_subway_lines"

#' Maryland Transit Administration (MTA) SubwayLink Metro Stations
#'
#' Location of MTA SubwayLink Metro Stations.
#'
#' @format A data frame with 14 rows and 10 variables:
#' \describe{
#'   \item{`id`}{Station identification number as integer}
#'   \item{`name`}{Station name}
#'   \item{`address`}{Station street address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`mode`}{Travel mode (Metro)}
#'   \item{`avg_wkdy`}{Average weekday passengers}
#'   \item{`avg_wknd`}{Average weekend passengers}
#'   \item{`facility_type`}{Facility type (Station)}
#'   \item{`geometry`}{POINT station location geometry}
#' }
#' @source [Baltimore Metro SubwayLink Stations](https://geodata.md.gov/imap/rest/services/Transportation/MD_Transit/FeatureServer/4)
"mta_subway_stations"

#' Maryland Transit Administration (MTA) Light RailLink Stations
#'
#' Location of MTA Light Rail Stations.
#'
#' @format A data frame with 84 rows and 8 variables:
#' \describe{
#'   \item{`id`}{Feature ID}
#'   \item{`rail_name`}{Line name (Light Rail Line)}
#'   \item{`mode`}{Facility mode (Light Rail)}
#'   \item{`tunnel`}{Tunnel indicator}
#'   \item{`direction`}{Travel direction}
#'   \item{`miles`}{Section mileage}
#'   \item{`status`}{Section status}
#'   \item{`geometry`}{LINESTRING line geometry}
#' }
#' @source [Maryland Transit - Light Rail Lines (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-light-rail-lines/)
"mta_light_rail_lines"

#' Maryland Transit Administration (MTA) Light RailLink Stations
#'
#' Locations for stations on the Baltimore Light RailLink (Baltimore Light Rail)
#' line operated by the Maryland Transit Administration.
#'
#' @format A data frame with 33 rows and 11 variables:
#' \describe{
#'   \item{`id`}{Feature ID}
#'   \item{`name`}{Station name}
#'   \item{`address`}{Station address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`zipcode`}{Zipcode}
#'   \item{`mode`}{Facility mode (Light Rail)}
#'   \item{`avg_wkdy`}{Average weekday passengers}
#'   \item{`avg_wknd`}{Average weekend passengers}
#'   \item{`facility_type`}{Facility type}
#'   \item{`geometry`}{POINT geometry with station locations}
#' }
#' @source [Maryland Transit - Light RailLink Stations (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-light-raillink-stations/)
"mta_light_rail_stations"

#' Maryland Transit Administration (MTA) MARC Train Lines
#'
#' MARC (Maryland Area Regional Commuter) Rail system lines operated by the
#' Maryland Transit Administration.
#'
#' @format A data frame with 162 rows and 8 variables:
#' \describe{
#'   \item{`id`}{Feature ID}
#'   \item{`rail_name`}{Rail line name}
#'   \item{`mode`}{Facility mode and line name (MARC)}
#'   \item{`tunnel`}{Tunnel indicator}
#'   \item{`direction`}{Travel direction}
#'   \item{`miles`}{Section mileage}
#'   \item{`status`}{Section status}
#'   \item{`geometry`}{LINESTRING geometry with rail lines}
#' }
#' @source [Maryland Transit - MARC Train Lines (MD iMap)](https://data.imap.maryland.gov/datasets/de0efbe9f8884ac5aa69864b6b3ff633_10/)
"mta_marc_lines"

#' Maryland Transit Administration (MTA) MARC Train Stations
#'
#' Locations of MARC (Maryland Area Regional Commuter) Rail stations operated by the
#' Maryland Transit Administration.
#'
#' @format A data frame with 44 rows and 12 variables:
#' \describe{
#'   \item{`id`}{Feature ID}
#'   \item{`name`}{Station name}
#'   \item{`address`}{Station address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`zipcode`}{Zipcode}
#'   \item{`line_name`}{Line name}
#'   \item{`mode`}{Facility mode and line name (MARC)}
#'   \item{`avg_wkdy`}{Average weekday passengers}
#'   \item{`avg_wknd`}{Average weekend passengers}
#'   \item{`facility_type`}{Facility type (Station)}
#'   \item{`geometry`}{POINT geometry with station locations}
#' }
#' @source [Maryland Transit - MARC Trains Stations (MD iMap)](https://data.imap.maryland.gov/datasets/maryland-transit-marc-trains-stations/)
"mta_marc_stations"

#' Baltimore City Public Schools School Zones or School Attendance Zones  (SY
#' 2021-2022)
#'
#' Baltimore City Public Schools School Zones also known as School Attendance
#' Zones.
#'
#' @format A data frame with 96 rows and 4 variables:
#' \describe{
#'   \item{`zone_name`}{Program name with zone appended}
#'   \item{`program_number`}{Program number}
#'   \item{`program_name_short`}{Program or school name (short)}
#'   \item{`type`}{Program type}
#'   \item{`category`}{Program category or grade band, e.g. E, EM, H, etc.}
#'   \item{`geometry`}{Multipolygons with school zone boundaries}
#' }
#' @source <https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2122_Ezones_and_Programs/FeatureServer/15>
"bcps_zones"


#' Baltimore City Public School Programs (SY 2021-2022)
#'
#' Locations of school buildings/school programs from SY 2021-2022 joined by
#' location to OpenStreetMap polygons tagged with "amenity:school".
#'
#' @format A data frame with 164 rows and 7 variables:
#' \describe{
#'   \item{`program_name_short`}{Program or school name (short)}
#'   \item{`program_number`}{Program number}
#'   \item{`osm_name`}{OpenStreetMap name}
#'   \item{`osm_id`}{OpenStreetMap identifier}
#'   \item{`type`}{Program type}
#'   \item{`category`}{Program category or grade band, e.g. E, EM, H, etc.}
#'   \item{`swing_space`}{Program located in a temporary swing space; logical}
#'   \item{`geometry`}{Multipolygons with school program location}
#' }
#' @source <https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/SY2122_Ezones_and_Programs/FeatureServer/11>
"bcps_programs"


#' Baltimore City Zoning Code
#'
#' The Baltimore City Zoning Code is administered by the Baltimore City
#' Department of Housing and Community Development (HCD) Office of the Zoning
#' Administrator. This office supports the Board of Municipal Zoning Appeals
#' (BMZA).
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
#' Boundaries for the Baltimore City Council Districts used since 2012
#' (following boundary revisions completed in 2011 based on the 2010 Decennial
#' Census).
#'
#' @format A data frame with 14 rows and 2 variables:
#' \describe{
#'   \item{`id`}{Number of the City Council district}
#'   \item{`name`}{Name of the City Council district}
#'   \item{`geometry`}{MULTIPOLYGON geometry with boundaries of City Council districts}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/CityView/City_Council_Districts/MapServer/0>
"council_districts"


#' Baltimore City Planning Districts
#'
#' Administrative boundaries set by the Baltimore City Department of Planning.
#' District planning staff are assigned to each of the planning districts.
#'
#' @format A data frame with 11 rows and 4 variables:
#' \describe{
#'   \item{`id`}{Planning district area identifier}
#'   \item{`name`}{Full name of the planning district}
#'   \item{`abb`}{Planning district area abbreviation}
#'   \item{`geometry`}{MULTIPOLYGON geometry of the Baltimore City Planning Districts}
#' }
#' @source <https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0>
"planning_districts"


#' Maryland Legislative Districts for Baltimore City (2022)
#'
#' A subset of Maryland legislative districts from Maryland iMap.
#'
#' @format A data frame with 6 rows and 4 variables:
#' \describe{
#'   \item{`name`}{District name}
#'   \item{`id`}{District number}
#'   \item{`label`}{District label}
#'   \item{`geometry`}{Multipolygon data with district boundaries}
#' }
#' @source <https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries_2022/FeatureServer/1>
"legislative_districts"


#' Maryland Legislative Districts for Baltimore City (2012)
#'
#' A subset of Maryland legislative districts from Maryland iMap.
#'
#' @format A data frame with 6 rows and 4 variables:
#' \describe{
#'   \item{`name`}{District name}
#'   \item{`id`}{District number}
#'   \item{`label`}{District label}
#'   \item{`geometry`}{Multipolygon data with district boundaries}
#' }
#' @source <https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1>
"legislative_districts_2012"

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
#'   \item{`namelsad`}{concatenated variable length geographic area name and
#'   legal/statistical area description (LSAD)}
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
#' the [Baltimore City Department of Recreation and
#' Parks](https://bcrp.baltimorecity.gov/). A few names have been updated to use
#' common names or recent new official names so the package version may not
#' match the city data in all cases. The parks have been matched to
#' corresponding entities on OpenStreetMap indicated by the osm_id column.
#'
#' @format A data frame with 297 rows and 9 variables:
#' \describe{
#'   \item{`name`}{Park name}
#'   \item{`id`}{Identification number from city data}
#'   \item{`address`}{Primary street address}
#'   \item{`name_alt`}{Alternate name}
#'   \item{`operator`}{Park operator, Baltimore City Department of Recreation and Parks (BCRP) or other}
#'   \item{`park_district`}{Park maintenance district for BCRP}
#'   \item{`acres`}{Area of the park property (acres)}
#'   \item{`osm_id`}{OpenStreetMap ID (node, way, or relation)}
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
#' Historic ward boundary data from 1797 to 1918. Derived from KML data provided
#' by the Baltimore City Archives.
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{`year`}{Earliest effective year of ward boundary}
#'   \item{`name`}{Ward name}
#'   \item{`number`}{Ward number}
#'   \item{`geometry`}{MULTIPOLYGON geometry with ward boundary for year}
#' }
#' @source <https://msa.maryland.gov/bca/wards/index.html>
"wards_1797_1918"

#' Maryland Inventory of Historic Properties in Baltimore City
#'
#' Baltimore City properties included in the [Maryland Inventory of Historic
#' Properties](https://mht.maryland.gov/research_mihp.shtml) (MIHP). The MIHP is
#' an administrative inventory maintained by the [Maryland Historical
#' Trust](https://mht.maryland.gov/), Maryland's statewide historic preservation
#' office and an agency within the Maryland Department of Planning. The
#' boundaries represent property boundaries and district boundaries depending on
#' the type of MIHP record. Updated 2023 March 29.
#'
#' @format A data frame with 5,203 rows and 14 variables:
#' \describe{
#'   \item{`num_polys`}{Number of polygons}
#'   \item{`mihp_id`}{MIHP ID}
#'   \item{`property_id`}{Property ID}
#'   \item{`mihp_num`}{MIHP Number}
#'   \item{`name`}{Property name}
#'   \item{`alternate_name`}{Alternate property name}
#'   \item{`full_address`}{Full street address}
#'   \item{`town`}{Town name}
#'   \item{`county`}{County}
#'   \item{`pdflink`}{URL for PDF MIHP form}
#'   \item{`xcoord`}{Longitude}
#'   \item{`ycoord`}{Latitude}
#'   \item{`do_erecord`}{Indicator for electronic records.}
#'   \item{`geometry`}{MULTIPOLYGON geometry with property/district boundaries.}
#' }
#' @source [Maryland Inventory Historic Properties (MD iMap)](https://data.imap.maryland.gov/datasets/maryland::maryland-inventory-historic-properties-maryland-inventory-of-historic-properties/about)
"baltimore_mihp"


#' Baltimore City Street Center Lines
#'
#' Street center line data for public streets in Baltimore City, Maryland. Data
#' is used by the [get_streets()] function.
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


#' Baltimore City Water
#'
#' Detailed MULTIPOLYGON data for area of streams, lakes, and other water bodies
#' in Baltimore City.
#'
#' @format A data frame with 468 rows and 6 variables:
#' \describe{
#'   \item{`name`}{Water feature name, if available}
#'   \item{`type`}{Water type}
#'   \item{`subtype`}{Water subtype}
#'   \item{`symbol`}{Symbol}
#'   \item{`water`}{Water indicator}
#'   \item{`geometry`}{MULTIPOLYGON geometry}
#' }
#' @source <https://data.imap.maryland.gov/datasets/maryland-waterbodies-rivers-and-streams-detailed>
"baltimore_water"


#' Explore Baltimore Heritage Stories
#'
#' A table of public stories on the [Explore Baltimore Heritage
#' website](https://explore.baltimoreheritage.org/) published by [Baltimore
#' Heritage](https://baltimoreheritage.org/). The text of stories on Explore
#' Baltimore Heritage is licensed under a [CC BY 4.0
#' license](https://creativecommons.org/licenses/by/4.0/). Updated on 2023 March
#' 29.
#'
#' @format A data frame with 491 rows and 10 variables:
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
#'   \item{`geometry`}{MULTIPOLYGON geometry matching Census blocks groups or parts of block groups}
#' }
#' @source <https://opendata.baltimorecity.gov/egis/rest/services/Hosted/Housing_Market_Typology_2017/FeatureServer/0>
"hmt_2017"

#' Adopted city plans, accepted community-initiated plans, and LINCS corridors
#'
#' Combined area plans and LINCS corridor data from the [Baltimore City
#' Department of Planning](https://planning.baltimorecity.gov/).
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

#' Baltimore Park Districts
#'
#' Park districts for the [Baltimore City Department of Recreation and
#' Parks](https://bcrp.baltimorecity.gov/). District boundaries are used for
#' park maintenance administration.
#'
#' @format A data frame with 5 rows and 2 variables:
#' \describe{
#'   \item{`name`}{Park district name}
#'   \item{`geometry`}{MULTIPOLYGON geometry with park district boundaries}
#' }
"park_districts"

#' Baltimore City Street Intersection Names
#'
#' Index of Baltimore City intersections using names from street centerlines
#' within 20 meters of the intersection boundaries. Data supports the for
#' [get_intersection()] function. Updated 2022 October 13.
#'
#' @format A data frame with 11506 rows and 3 variables:
#' \describe{
#'   \item{`id`}{Intersection identifier matching id in `edge_of_pavement` data}
#'   \item{`name`}{Intersection name}
#'   \item{`geometry`}{Points with center of intersections}
#' }
"named_intersections"

#' Charm City Circulator Routes
#'
#' The Baltimore City Department of Transportation describes the Charm City
#' Circulator (CCC) as "a fleet of 24 free shuttles that travel four routes in
#' the central business district of Baltimore City, Maryland." The Harbor
#' Connector (HC) is "an extension of the CCC and is the City’s free maritime
#' transit service connecting 6 piers through four vessels."
#'
#' @format A data frame with 6 rows and 3 variables:
#' \describe{
#'   \item{`route_name`}{Route name}
#'   \item{`alt_route_name`}{Alternate route name}
#'   \item{`geometry`}{MULTILINESTRING geometry with routes}
#' }
#' @source [Baltimore CityView - Charm City Circulator Routes](https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/1)
"circulator_routes"

#' Charm City Circulator and Harbor Connector Stops
#'
#' The Baltimore City Department of Transportation describes the Charm City
#' Circulator (CCC) as "a fleet of 24 free shuttles that travel four routes in
#' the central business district of Baltimore City, Maryland." The Harbor
#' Connector (HC) is "an extension of the CCC and is the City’s free maritime
#' transit service connecting 6 piers through four vessels."
#'
#' @format A data frame with 111 rows and 5 variables:
#' \describe{
#'   \item{`stop_num`}{Stop number as integer }
#'   \item{`stop_location`}{Intersection location (address, intersection, or landmark)}
#'   \item{`corner`}{Intersection corner}
#'   \item{`route_name`}{Route name}
#'   \item{`geometry`}{POINT geometry for stop location}
#' }
#' @source [Baltimore CityView - Charm City Circulator Stops](https://egisdata.baltimorecity.gov/egis/rest/services/CityView/Charm_City_Circulator/MapServer/0)
"circulator_stops"


#' Baltimore Metropolitan Statistical Area (MSA) Water Polygons
#'
#' Downloaded using tigris package.
#'
#' @format A data frame with 3,491 rows and 9 variables:
#' \describe{
#'   \item{`ansicode`}{American National Standards Institute codes (ANSI codes)}
#'   \item{`hydroid`}{Unique key for hydrographic features}
#'   \item{`fullname`}{Full name}
#'   \item{`mtfcc`}{MAF/TIGER Feature Class Code}
#'   \item{`aland`}{land area (square meters)}
#'   \item{`awater`}{water area (square meters)}
#'   \item{`intptlat`}{latitude of the internal point}
#'   \item{`intptlon`}{longitude of the internal point}
#'   \item{`geometry`}{POLYGON geometry}
#' }
"baltimore_msa_water"

#' Baltimore public art works and monuments
#'
#' Data created by Eli Pousson and C. Ryan Patterson with contributions from
#' staff and volunteers at Baltimore City Commission on Historical and
#' Architectural Preservation, Baltimore Heritage, and the Baltimore Office of
#' Promotion and the Arts. Updated January 18, 2023. See
#' <https://publicartbaltimore.github.io/inventory/> for more information.
#'
#' @format A data frame with 1140 rows and 35 variables:
#' \describe{
#'   \item{`id`}{incomplete unique id column}
#'   \item{`osm_id`}{OpenStreetMap identifier}
#'   \item{`title`}{Artwork title}
#'   \item{`location`}{Location name}
#'   \item{`type`}{Artwork type}
#'   \item{`medium`}{Artwork medium}
#'   \item{`status`}{Artwork status}
#'   \item{`year`}{Artwork status}
#'   \item{`year_accuracy`}{Artwork status}
#'   \item{`creation_dedication_date`}{Creation/dedication date}
#'   \item{`primary_artist`}{Primary artist}
#'   \item{`primary_artist_gender`}{Primary artist gender (based on
#'   name and biographical information if available)}
#'   \item{`street_address`}{Street address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`zipcode`}{Zipcode}
#'   \item{`dimensions`}{Artwork dimensions}
#'   \item{`program`}{Commissioning program}
#'   \item{`funding`}{Primary funding source}
#'   \item{`artist_assistants`}{Artist assistants}
#'   \item{`architect`}{Architect}
#'   \item{`fabricator`}{Fabricator}
#'   \item{`neighborhood`}{Neighborhood}
#'   \item{`council_district`}{Baltimore City Council District}
#'   \item{`legislative_district`}{character Maryland State Legislative
#'   District}
#'   \item{`location_desc`}{character Location description}
#'   \item{`indoor_outdoor_access`}{Indoor/outdoor accessible}
#'   \item{`subject_person`}{Subject of artworks (if work depicts a person)}
#'   \item{`related_property`}{Related property name}
#'   \item{`property_ownership`}{Related property ownership}
#'   \item{`agency_or_insitution`}{Agency/institution responsible}
#'   \item{`wikipedia_url`}{Wikipedia URL}
#'   \item{`geometry`}{POINT location}
#' }
"public_art"

#' Baltimore 21st Century Schools
#'
#' Schools with buildings in the [21st Century Schools
#' Program](https://baltimore21stcenturyschools.org/). Updated 2022 October 13.
#' This data may contain some inaccurate information.
#'
#' @format A data frame with 29 rows and 24 variables:
#' \describe{
#'   \item{`school_name`}{School name}
#'   \item{`school_number`}{School number}
#'   \item{`nces_number`}{NCES number}
#'   \item{`grade_band`}{Grade bane}
#'   \item{`url`}{School website URL}
#'   \item{`year`}{21st Century School renovation/replacement complete}
#'   \item{`type`}{21st Century School project type}
#'   \item{`bldg_budget_approx`}{Approximate building budget}
#'   \item{`status_21c`}{21st Century School project status}
#'   \item{`status_inspire`}{INSPRE Plan status}
#'   \item{`inspire_plan`}{Related INSPIRE Plan}
#'   \item{`occupancy_month`}{Building occupancy month}
#'   \item{`occupancy_year`}{Building occupancy year}
#'   \item{`address`}{Street address}
#'   \item{`city`}{City}
#'   \item{`state`}{State}
#'   \item{`zip`}{Zipcode}
#'   \item{`phone`}{School phone number}
#'   \item{`alt_school_name`}{Alternate school name}
#'   \item{`bldg_name`}{Building name (if applicable)}
#'   \item{`alt_name`}{character COLUMN_DESCRIPTION}
#'   \item{`lon`}{Longitude}
#'   \item{`lat`}{Latitude}
#'   \item{`geometry`}{POINT geometry for school location}
#' }
#' @details <https://baltimore21stcenturyschools.org/school-projects>
"schools_21stc"

#' INSPIRE Plans
#'
#' Data frame and boundary geometry for INSPIRE Plans adopted and in progress.
#'
#' @format A data frame with 24 rows and 19 variables:
#' \describe{
#'   \item{`plan_name`}{Plan name}
#'   \item{`plan_name_short`}{Plan name (short)}
#'   \item{`overall_status`}{Overall status}
#'   \item{`inspire_lead_planner`}{Lead INSPIRE Planner}
#'   \item{`plan_url`}{Baltimore City Department of Planning plan webpage url}
#'   \item{`year_launched`}{Year launched}
#'   \item{`year_adopted`}{Year adopted by Planning Commission}
#'   \item{`adoption_status`}{Planning Commission adoption status}
#'   \item{`adoption_date`}{Planning Commission adoption data}
#'   \item{`document_url`}{Adopted plan PDF url}
#'   \item{`recommendation_report_status`}{Recommendation report status}
#'   \item{`recommendation_report_url`}{Draft recommendation report PDF url}
#'   \item{`kick_off_presentation_date`}{Kick-off presentation date}
#'   \item{`launch_date_target`}{Target launch date}
#'   \item{`walking_route_id_target_date`}{Primary walking route identification date}
#'   \item{`recommendations_date_target`}{Target draft recommendation report publication date}
#'   \item{`commission_review_date_target`}{Target Planning Commission review date}
#'   \item{`implementation_status`}{Plan implementation status}
#'   \item{`planning_districts`}{Planning Districts}
#'   \item{`neighborhoods`}{Neighborhoods}
#'   \item{`council_districts`}{Baltimore City Council Districts}
#'   \item{`geometry`}{MULTIPOLYGON boundary geometry}
#' }
#' @details DETAILS
"inspire_plans"

#' Baltimore Data Table Labels
#'
#' A data.frame with labels to use with tables created using mapbaltimore data.
#' The Housing Market Typology 2017 data is the only set of labels included and
#' the preset table functions are not yet implemented.
#'
#' @format A data frame with 9 rows and 7 variables:
#' \describe{
#'   \item{`fn_name`}{character Function name}
#'   \item{`table`}{character Table name}
#'   \item{`col`}{character Column name}
#'   \item{`label`}{character Column label}
#'   \item{`definition`}{logical Column variable definition}
#'   \item{`source`}{logical Column variable data source}
#'   \item{`fmt`}{character Column data format}
#' }
#' @source <https://docs.google.com/spreadsheets/d/1FXEJlhccnhoQmSO2WydBidXIw-f2lpomURDGy9KBgJw/edit?usp=sharing>
"balt_tbl_labs"


#' Baltimore ArcGIS Server index data
#'
#' A data.frame indexing the layers, services, and folders on four ArcGIS
#' Servers maintained by the Baltimore City Mayor's Office of Information
#' Technology (MOIT) Enterprise GIS (EGIS) program. A limited number of
#' potential sensitive and unresponsive server layers have been excluded. Used
#' by the [get_baltimore_data()] function. Updated December 23, 2022.
#'
#' @format A data frame with 1,286 rows and 17 variables:
#' \describe{
#'   \item{`name`}{Name}
#'   \item{`nm`}{Name with snake case}
#'   \item{`type`}{Service/layer type}
#'   \item{`url`}{Folder/service/layer URL}
#'   \item{`urlType`}{URL type}
#'   \item{`folderPath`}{Index type}
#'   \item{`serviceName`}{Service name}
#'   \item{`serviceType`}{Service type}
#'   \item{`id`}{integer Layer ID number}
#'   \item{`parentLayerId`}{integer Parent layer ID number}
#'   \item{`defaultVisibility`}{logical Layer default visibility}
#'   \item{`minScale`}{double Minimum scale}
#'   \item{`maxScale`}{integer Maximum scale}
#'   \item{`geometryType`}{Geometry type}
#'   \item{`subLayerIds`}{list Sublayer ID numbers}
#'   \item{`supportsDynamicLegends`}{logical Supports dynamic legends}
#' }
"baltimore_gis_index"

#' CHAP Historic Districts
#'
#' Historic districts designated by the [Baltimore City Commission on Historical
#' and Architectural Preservation](https://chap.baltimorecity.gov/) (CHAP) which
#' is the local historic preservation office for Baltimore City, Maryland.
#' Updated 2023 February 10.
#'
#' @format A data frame with 39 rows and 7 variables:
#' \describe{
#'   \item{`name`}{Historic district name}
#'   \item{`contact_name`}{CHAP Staff contact name}
#'   \item{`url`}{URL for CHAP website}
#'   \item{`deed_covenant`}{Design review required under deed covenants}
#'   \item{`overlaps_nr_district`}{District is also designated as or overlaps
#'   some or entirely with a designated National Register Historic District}
#'   \item{`acres`}{Acreage}
#'   \item{`geometry`}{MULTIPOLYGON boundary geometry}
#' }
"chap_districts"


#' Baltimore City Real Property Responsible Agency Codes
#'
#' A reference table of responsible agency codes appearing in the Baltimore City
#' real property data used by [get_area_property()]. Updated 2023 March 29.
#'
#' @format A data frame with 37 rows and 7 variables:
#' \describe{
#'   \item{`name`}{Responsible agency name}
#'   \item{`code`}{Responsible agency code}
#'   \item{`agency_name`}{Baltimore City agency/commission name}
#'   \item{`agency_abb`}{Baltimore City agency/commission abbreviation}
#'   \item{`division_name`}{Agency division name}
#'   \item{`active_code`}{Active code indicator (`FALSE` for codes that do not appear in data)}
#'   \item{`notes`}{Notes on code/agency}
#' }
#' @source <https://docs.google.com/spreadsheets/d/1Dnyp4-AZxvFPpt5Vci4NRWR9tGP99R8RaHuPCbzcGCA/edit?usp=sharing>
"respagency_codes"
