#' A generalized political boundary for Baltimore City
#'
#' A generalized boundary for Baltimore City, Maryland
#' from statewide dataset of generalized county boundaries.
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{name}{name of the county}
#'   \item{countyfp}{Unique county FIPS code}
#'   \item{geoid}{...}
#'   \item{aland}{...}
#'   \item{awater}{...}
#'   \item{intptlat}{...}
#'   \item{intptlon}{...}
#'   \item{geometry}{multipolygon with the boundary}
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_city"

#' A detailed physical boundary for Baltimore City
#'
#' ...
#'
#' @format A data frame with 1 row and 3 variables:
#' \describe{
#'   \item{name}{name of the county}
#'   \item{countyfp}{Unique county FIPS code}
#'   \item{geometry}{multipolygon with the boundary}
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/maryland-physical-boundaries-county-boundaries-detailed}
"baltimore_city_detailed"


#' Baltimore City Neighborhood Boundaries
#'
#' Baltimore City Neighborhoods or Neighborhood Statistical Areas
#'
#' @format A data frame with 278 rows and 2 variables:
#' \describe{
#'   \item{label}{Label with the name of the neighborhood}
#'   \item{neighborhood}{Neighborhood name capitalized}
#'   \item{geometry}{Multipolygons with boundary of each neighborhood}
#'   ...
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/fc5d183b20a145009eae8f8b171eeb0d_0}
"neighborhoods"


#' Baltimore City Police Districts
#'
#' Baltimore City Police Districts
#'
#' @format A data frame with 9 rows and 3 variables:
#' \describe{
#'   \item{number}{Police district number}
#'   \item{name}{Police district name}
#'   \item{geometry}{Multipolygons with boundary of each district}
#'   ...
#' }
#' @source \url{...}
"police_districts"



#' Baltimore City Community Statistical Areas
#'
#' Baltimore City Community Statistical Areas (CSAs)
#'
#' @format A data frame with 55 rows and 3 variables:
#' \describe{
#'   \item{id}{Community Statistical Area id number}
#'   \item{name}{Community Statistical Area name}
#'   \item{geometry}{Multipolygons with boundary of each area}
#'   ...
#' }
#' @source \url{...}
"csas"



#' U.S. Census Tracts in Baltimore City
#'
#' ...
#'
#' @format A data frame with 200 rows and 9 variables:
#' \describe{
#'   \item{tractce}{...}
#'   \item{geoid}{...}
#'   \item{name}{...}
#'   \item{namelsad}{...}
#'   \item{aland}{...}
#'   \item{awater}{...}
#'   \item{intptlat}{...}
#'   \item{intptlon}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_tracts"


#' U.S. Census Block Groups in Baltimore City
#'
#' ...
#'
#' @format A data frame with 653 rows and 9 variables:
#' \describe{
#'   \item{tractce}{...}
#'   \item{blkgrpce}{...}
#'   \item{geoid}{...}
#'   \item{namelsad}{...}
#'   \item{aland}{...}
#'   \item{awater}{...}
#'   \item{intptlat}{...}
#'   \item{intptlon}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_block_groups"


#' U.S. Census Blocks (2010 Decennial) in Baltimore City
#'
#' ...
#'
#' @format A data frame with 13,598 rows and 9 variables:
#' \describe{
#'   \item{tractce10}{...}
#'   \item{blkgrpce10}{...}
#'   \item{geoid10}{...}
#'   \item{name10}{...}
#'   \item{aland10}{...}
#'   \item{awater10}{...}
#'   \item{intptlat10}{...}
#'   \item{intptlon10}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{https://www.census.gov/geo/maps-data/data/tiger-line.html}
"baltimore_blocks"


#' Baltimore City Real Property Data
#'
#' This dataset represents the City of Baltimore parcel boundaries, with
#' ownership, address, valation and other property information.
#' This data was downloaded on October 6, 2020.
#'
#' @format A data frame with 238,340 rows and 88 variables:
#' \describe{
#'   \item{objectid}{...}
#'   \item{pin}{...}
#'   \item{pinrelate}{...}
#'   \item{blocklot}{...}
#'   \item{block}{...}
#'   \item{lot}{...}
#'   \item{ward}{...}
#'   \item{section}{...}
#'   \item{assessor}{...}
#'   \item{taxbase}{...}
#'   \item{bfcvland}{...}
#'   \item{bfcvimpr}{...}
#'   \item{landexmp}{...}
#'   \item{imprexmp}{...}
#'   \item{citycred}{...}
#'   \item{statcred}{...}
#'   \item{ccredamt}{...}
#'   \item{scredamt}{...}
#'   \item{permhome}{...}
#'   \item{assesgrp}{...}
#'   \item{lot_size}{...}
#'   \item{no_imprv}{...}
#'   \item{currland}{...}
#'   \item{currimpr}{...}
#'   \item{exmpland}{...}
#'   \item{exmpimpr}{...}
#'   \item{fullcash}{...}
#'   \item{exmptype}{...}
#'   \item{exmpcode}{...}
#'   \item{usegroup}{...}
#'   \item{zonecode}{...}
#'   \item{sdatcode}{...}
#'   \item{artaxbas}{...}
#'   \item{distswch}{...}
#'   \item{dist_id}{...}
#'   \item{statetax}{...}
#'   \item{city_tax}{...}
#'   \item{ar_owner}{...}
#'   \item{deedbook}{...}
#'   \item{deedpage}{...}
#'   \item{saledate}{...}
#'   \item{owner_abbr}{...}
#'   \item{owner_1}{...}
#'   \item{owner_2}{...}
#'   \item{owner_3}{...}
#'   \item{fulladdr}{...}
#'   \item{stdirpre}{...}
#'   \item{st_name}{...}
#'   \item{st_type}{...}
#'   \item{bldg_no}{...}
#'   \item{fraction}{...}
#'   \item{unit_num}{...}
#'   \item{span_num}{...}
#'   \item{spanfrac}{...}
#'   \item{zip_code}{...}
#'   \item{extd_zip}{...}
#'   \item{dhcduse1}{...}
#'   \item{dhcduse2}{...}
#'   \item{dhcduse3}{...}
#'   \item{dhcduse4}{...}
#'   \item{dwelunit}{...}
#'   \item{eff_unit}{...}
#'   \item{roomunit}{...}
#'   \item{rpdeltag}{...}
#'   \item{respagcy}{...}
#'   \item{salepric}{...}
#'   \item{propdesc}{...}
#'   \item{neighbor}{...}
#'   \item{srvccntr}{...}
#'   \item{year_build}{...}
#'   \item{structarea}{...}
#'   \item{ldate}{...}
#'   \item{ownmde}{...}
#'   \item{grndrent}{...}
#'   \item{subtype_geodb}{...}
#'   \item{sdatlink}{...}
#'   \item{blockplat}{...}
#'   \item{mailtoadd}{...}
#'   \item{vacind}{...}
#'   \item{shape_st_area}{...}
#'   \item{shape_st_length}{...}
#'   \item{geometry}{...}
#'   \item{neighborhood}{...}
#'   \item{council_district}{...}
#'   \item{police_district}{...}
#'   \item{csa}{...}
#'   \item{block_group}{...}
#'   \item{tract}{...}
#'   ...
#' }
#' @source \url{https://gis-baltimore.opendata.arcgis.com/datasets/real-property}
"real_property"


#' Maryland Transit Administration Summer 2020 Bus Routes
#'
#' Maryland Department of Transportation's Maryland Transit Administration
#' Summer 2020 Bus Routes including CityLink, LocalLink and Commuter Bus.
#' The data reflect bus route changes as of July 12, 2020.
#'
#' @format A data frame with 103 rows and 4 variables:
#' \describe{
#'   \item{route_name}{Name of the bus route}
#'   \item{route_type}{Type of route, CityLink, LocalLink and Commuter Bus}
#'   \item{route_number}{Unique route number or color identifier}
#'   \item{geometry}{multilinestring with the route path}
#'   ...
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/maryland-transit-mta-bus-lines-1}
"mta_bus_lines"


#' Baltimore City Public Schools School Zones or School Attendance Zones
#'
#' Baltimore City Public Schools School Zones also known as School Attendance Zones.
#'
#' @format A data frame with 96 rows and 4 variables:
#' \describe{
#'   \item{program_name}{Program or school name}
#'   \item{program_number}{Program number}
#'   \item{zone_name}{Program name with zone appended}
#'   \item{geometry}{Multipolygons with school zone boundaries}
#'   ...
#' }
#' @source \url{https://services3.arcgis.com/mbYrzb5fKcXcAMNi/ArcGIS/rest/services/BCPSZones_2021/FeatureServer/0}
"bcps_zones"


#' Baltimore City Public School Programs
#'
#' Baltimore City Public Schools School Zones also known as School Attendance Zones.
#'
#' @format A data frame with 165 rows and 6 variables:
#' \describe{
#'   \item{program_name}{Program or school name}
#'   \item{program_number}{Program number}
#'   \item{type}{Program type}
#'   \item{category}{Program category, e.g. E, EM, H, etc.}
#'   \item{zone_name}{Program name with zone appended}
#'   \item{geometry}{Multipolygons with school program location}
#'   ...
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
#'   \item{zoning}{Zoning designation code}
#'   \item{overlay}{Overlay zone designation}
#'   \item{label}{Label combining zoning and overlay zoning codes}
#'   \item{category_zoning}{Zoning code category}
#'   \item{name_zoning}{Zoning code name}
#'   \item{category_overlay}{Overlay code category}
#'   \item{category_name}{Overlay code name}
#'   \item{geometry}{Multipolygons for areas with shared zoning}
#'   ...
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/Planning/Boundaries_and_Plans/MapServer/20}
"zoning"


#' Baltimore City Council Districts
#'
#' ...
#'
#' @format A data frame with 14 rows and 2 variables:
#' \describe{
#'   \item{id}{Number of the City Council district}
#'   \item{name}{Name of the City Council district}
#'   \item{geometry}{Multipolygons for boundaries of City Council districts}
#'   ...
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/CityView/City_Council_Districts/MapServer/0}
"council_districts"


#' Baltimore City Planning Districts
#'
#' Administrative boundaries set by the Baltimore City Department of Planning.
#'
#' @format A data frame with 11 rows and 4 variables:
#' \describe{
#'   \item{id}{Planning district area identifier}
#'   \item{name}{Full name of the planning district}
#'   \item{abb}{Planning district area abbreviation}
#'   \item{geometry}{Multipolygon boundary of the planning district}
#'   ...
#' }
#' @source \url{https://geodata.baltimorecity.gov/egis/rest/services/CityView/PlanningDistricts/MapServer/0}
"planning_districts"


#' Baltimore City State Legislative Districts
#'
#' ...
#'
#' @format A data frame with 6 rows and 4 variables:
#' \describe{
#'   \item{name}{District name}
#'   \item{id}{District number}
#'   \item{label}{District label}
#'   \item{geometry}{Multipolygon data with district boundaries}
#'   ...
#' }
#' @source \url{https://geodata.md.gov/imap/rest/services/Boundaries/MD_ElectionBoundaries/FeatureServer/1}
"legislative_districts"


#' Baltimore City Congressional Districts
#'
#' U.S. Congressional Districts overlapping with Baltimore City. Downloaded with the tigris package.
#'
#' @format A data frame with 3 rows and 15 variables:
#' \describe{
#'   \item{statefp}{...}
#'   \item{cd116fp}{...}
#'   \item{geoid}{...}
#'   \item{namelsad}{...}
#'   \item{lsad}{...}
#'   \item{cdsessn}{...}
#'   \item{mtfcc}{...}
#'   \item{funcstat}{...}
#'   \item{aland}{...}
#'   \item{awater}{...}
#'   \item{intptlat}{...}
#'   \item{intptlon}{...}
#'   \item{label}{...}
#'   \item{name}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"congressional_districts"



#' Baltimore City Parks
#'
#' Spatial data for parks in Baltimore City from the Baltimore City Department of Recreation and Parks.
#'
#' @format A data frame with 297 rows and 6 variables:
#' \describe{
#'   \item{name}{Park name}
#'   \item{id}{Identification number from city GIS data}
#'   \item{address}{Primary street address}
#'   \item{name_alt}{Alternate name}
#'   \item{operator}{Park operator, Baltimore City Department of Recreation and Parks or other}
#'   \item{geometry}{Multipolygon with edges of parks}
#'   ...
#' }
#' @source \url{https://services1.arcgis.com/UWYHeuuJISiGmgXx/ArcGIS/rest/services/Baltimore_City_Recreation_and_Parks/FeatureServer/2}
"parks"


#' Baltimore City Request Types
#'
#' A list of request types based on unique request types used between January 2019 and October 2020.
#'
#' @format A data frame with 320 rows and 1 variables:
#' \describe{
#'   \item{request_type}{...}
#'   ...
#' }
#' @source \url{...}
"request_types"


#' Baltimore City Ward Boundaries, 1797-1918
#'
#' Historic ward boundary data from 1797 to 1918. Derived from KML data provided by the Baltimore City Archives.
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{year}{Earliest effective year of ward boundaries}
#'   \item{name}{Ward name}
#'   \item{number}{Ward number}
#'   \item{geometry}{Multipolygons with the ward boundaries}
#'   ...
#' }
#' @source \url{https://msa.maryland.gov/bca/wards/index.html}
"wards_1797_1918"

#' Maryland Inventory of Historic Properties in Baltimore City
#'
#' ...
#'
#' @format A data frame with 5,203 rows and 14 variables:
#' \describe{
#'   \item{num_polys}{...}
#'   \item{mihp_id}{...}
#'   \item{property_id}{...}
#'   \item{mihp_num}{...}
#'   \item{name}{...}
#'   \item{alternate_name}{...}
#'   \item{full_address}{...}
#'   \item{town}{...}
#'   \item{county}{...}
#'   \item{pdflink}{...}
#'   \item{xcoord}{...}
#'   \item{ycoord}{...}
#'   \item{do_erecord}{...}
#'   \item{geoms}{...}
#'   ...
#' }
#' @source \url{...}
"baltimore_mihp"


#' Baltimore City Street Center lines
#'
#' ...
#'
#' @format Simple feature collection with 48,473 features and 23 fields.
#' \describe{
#'   \item{type}{...}
#'   \item{subtype}{...}
#'   \item{subtype_label}{...}
#'   \item{dirpre}{...}
#'   \item{feanme}{...}
#'   \item{featype}{...}
#'   \item{dirsuf}{...}
#'   \item{fraddl}{...}
#'   \item{toaddl}{...}
#'   \item{fraddr}{...}
#'   \item{toaddr}{...}
#'   \item{fraddla}{...}
#'   \item{toaddla}{...}
#'   \item{fraddra}{...}
#'   \item{toaddra}{...}
#'   \item{leftzip}{...}
#'   \item{rightzip}{...}
#'   \item{fullname}{...}
#'   \item{sha_class}{...}
#'   \item{sha_class_label}{...}
#'   \item{blocktext}{...}
#'   \item{block_num}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{https://dotgis.baltimorecity.gov/arcgis/rest/services/DOT_Map_Services/DOT_Basemap/MapServer/7}
"streets"


#' Baltimore Water
#'
#' Detailed multipolygon data for streams, lakes, and other water in Baltimore City.
#'
#' @format A data frame with 468 rows and 6 variables:
#' \describe{
#'   \item{name}{Name if available}
#'   \item{type}{Water type}
#'   \item{subtype}{Water subtype}
#'   \item{symbol}{Symbol}
#'   \item{water}{Water indicator}
#'   \item{geometry}{Multipolygon geometry}
#'   ...
#' }
#' @source \url{https://data.imap.maryland.gov/datasets/maryland-waterbodies-rivers-and-streams-detailed}
"baltimore_water"


#' Explore Baltimore Heritage
#'
#' A table of public stories on the Explore Baltimore Heritage website.
#'
#' @format A data frame with 459 rows and 10 variables:
#' \describe{
#'   \item{id}{...}
#'   \item{featured}{...}
#'   \item{modified}{...}
#'   \item{title}{...}
#'   \item{address}{...}
#'   \item{thumbnail}{...}
#'   \item{fullsize}{...}
#'   \item{url}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{https://explore.baltimoreheritage.org/}
"explore_baltimore"


#' Housing Market Typology 2017
#'
#' The 2017 update of the City’s Housing Market Typology was jointly developed
#' by the Baltimore City Planning Department, Department of Housing & Community Development,
#' and The Reinvestment Fund.
#'
#' @format A data frame with 663 rows and 15 variables:
#' \describe{
#'   \item{geoid}{U.S. Census Block Group GeoID}
#'   \item{geoid_part}{Identifier for U.S. Census Block Group GeoID including part identifier}
#'   \item{cluster}{Housing market cluster}
#'   \item{cluster_group}{Housing market cluster}
#'   \item{median_sales_price}{Median sales price, Q3 2015 - Q2 2017}
#'   \item{sales_price_variation}{Sales price variation, Q3 2015 - Q2 2017}
#'   \item{num_sales}{Number of residential sales, Q3 2015 - Q2 2017}
#'   \item{num_foreclosure_filings}{Number of foreclosure filings, Q3 2015 - Q2 2017}
#'   \item{perc_foreclosure_sales}{Percent of sales through foreclosure, Q3 2015 - Q2 2017}
#'   \item{perc_permits_over10k}{Percent of residential building permits over $10,000, Q3 2015 - Q2 2017}
#'   \item{vacant_lots_bldgs_per_acre_res}{Vacant lots and buildings per residential acre, July 2017}
#'   \item{units_per_acre_res}{Housing units per residential acre, July 2017}
#'   \item{geometry}{Multipolygon geometry matching Census blocks groups or parts of block groups}
#'   ...
#' }
#' @source \url{https://explore.baltimoreheritage.org/}
"hmt_2017"
