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
#' @source \url{}
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
#' @source \url{}
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
#' @source \url{...}
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
#' @source \url{...}
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
#' @source \url{...}
"baltimore_blocks"


#' Baltimore City Real Property Data
#'
#' This dataset represents the City of Baltimore parcel boundaries, with
#' ownership, address, vaulation and other property information.
#' This data was downloaded on October 6, 2020.
#'
#' @format A data frame with 238,340 rows and 82 variables:
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
#'   \item{name}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"council_districts"


#' Baltimore City Planning Districts
#'
#' ...
#'
#' @format A data frame with 11 rows and 3 variables:
#' \describe{
#'   \item{name}{...}
#'   \item{abb}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"planning_districts"


#' Baltimore City State Legislative Districts
#'
#' ...
#'
#' @format A data frame with 6 rows and 2 variables:
#' \describe{
#'   \item{name}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"legislative_districts"


#' Baltimore City Parks
#'
#' ...
#'
#' @format A data frame with 297 rows and 6 variables:
#' \describe{
#'   \item{park_id}{...}
#'   \item{name}{...}
#'   \item{address}{...}
#'   \item{name_alt}{...}
#'   \item{bcrp}{...}
#'   \item{geoms}{...}
#'   ...
#' }
#' @source \url{...}
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
#' ...
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{year}{...}
#'   \item{name}{...}
#'   \item{number}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"wards_1797_1918"


#' Baltimore City Ward Boundaries, 1797-1918
#'
#' ...
#'
#' @format A data frame with 245 rows and 4 variables:
#' \describe{
#'   \item{year}{...}
#'   \item{name}{...}
#'   \item{number}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
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
#' @format Simple feature collection with 48,473 features and 34 fields.
#' \describe{
#'   \item{objectid_1}{...}
#'   \item{objectid}{...}
#'   \item{tag}{...}
#'   \item{last_org}{...}
#'   \item{capture_me}{...}
#'   \item{last_user}{...}
#'   \item{edit_date}{...}
#'   \item{type}{...}
#'   \item{subtype}{...}
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
#'   \item{flag}{...}
#'   \item{comments}{...}
#'   \item{sha_class}{...}
#'   \item{shape_leng}{...}
#'   \item{place}{...}
#'   \item{blocktext}{...}
#'   \item{block_num}{...}
#'   \item{zipcode}{...}
#'   \item{global_id}{...}
#'   \item{url}{...}
#'   \item{geometry}{...}
#'   ...
#' }
#' @source \url{...}
"streets"
