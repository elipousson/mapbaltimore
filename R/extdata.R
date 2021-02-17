#' Baltimore City Real Property Data
#'
#' This dataset represents the City of Baltimore parcel boundaries, with
#' ownership, address, valuation and other property information.
#' This data was downloaded on October 6, 2020.
#' Additional use, construction, and building type variables were added by
#' matching city real property polygon data to real property data that was
#' combined with data from the Maryland Department of Planning: \url{https://data.imap.maryland.gov/datasets/maryland-property-data-parcel-points}
#'
#' @format A data frame with 238,306 rows and 103 variables:
#' \describe{
#'   \item{objectid}{...}
#'   \item{pin}{...}
#'   \item{pinrelate}{...}
#'   \item{blocklot}{Block lot}
#'   \item{block}{Block}
#'   \item{lot}{Lot}
#'   \item{ward}{Ward}
#'   \item{section}{Section}
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
#'   \item{lot_size}{Lot size, typically width by depth in feet}
#'   \item{no_imprv}{Indicator for unimmproved property}
#'   \item{currland}{...}
#'   \item{currimpr}{...}
#'   \item{exmpland}{...}
#'   \item{exmpimpr}{...}
#'   \item{fullcash}{Full cash value}
#'   \item{exmptype}{...}
#'   \item{exmpcode}{...}
#'   \item{usegroup}{...}
#'   \item{zonecode}{Zoning code}
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
#'   \item{zip_code}{Zip code}
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
#'   \item{year_build}{Year built}
#'   \item{structarea}{Structure area}
#'   \item{ldate}{...}
#'   \item{ownmde}{...}
#'   \item{grndrent}{Annual ground rent}
#'   \item{subtype_geodb}{...}
#'   \item{sdatlink}{URL for SDAT }
#'   \item{blockplat}{...}
#'   \item{mailtoadd}{Mailing address}
#'   \item{vacind}{Indicator for vacant property}
#'   \item{shape_st_area}{...}
#'   \item{shape_st_length}{...}
#'   \item{geometry}{Multipolygon parcel boundaries}
#'   \item{neighborhood}{Neighborhood}
#'   \item{council_district}{Baltimore City Council District}
#'   \item{police_district}{Baltimore Police District}
#'   \item{csa}{Community Statistical Area}
#'   \item{block_group}{U.S. Census Block Group}
#'   \item{tract}{U.S. Census Tract}
#'   \item{acctid}{Maryland state tax account ID}
#'   \item{resityp}{...}
#'   \item{descciuse}{...}
#'   \item{descciuse_cat}{...}
#'   \item{descciuse_subcat}{...}
#'   \item{desclu}{...}
#'   \item{desccnst}{...}
#'   \item{desccnst_cat}{...}
#'   \item{desccnst_subcat}{...}
#'   \item{descstyl}{...}
#'   \item{descstyl_cat}{...}
#'   \item{descstyl_subcat}{...}
#'   \item{descbldg}{...}
#'   \item{descbldg_cat}{...}
#'   \item{descbldg_subcat}{...}
#'   ...
#' }
#' @source \url{https://gis-baltimore.opendata.arcgis.com/datasets/real-property}
# "real_property"
NULL



#' Street center lines located within counties included in the Baltimore–Columbia–Towson Metropolitan Statistical Area
#'
#' Counties in the metro area include Baltimore City, Baltimore County,
#' Carroll County, Anne Arundel County, Howard County, Queen Anne's County,
#' and Harford County.
#'
#' @format A data frame with 38,144 rows and 23 variables:
#' \describe{
#'   \item{objectid}{...}
#'   \item{from_measure}{...}
#'   \item{to_measure}{...}
#'   \item{functional_class}{...}
#'   \item{urban_area}{...}
#'   \item{road_name}{...}
#'   \item{id_prefix}{...}
#'   \item{mun_sort}{...}
#'   \item{county}{...}
#'   \item{id_rte_no}{...}
#'   \item{mp_suffix}{...}
#'   \item{cardinality}{...}
#'   \item{exit_number}{...}
#'   \item{ramp_number}{...}
#'   \item{routeid}{...}
#'   \item{county_name}{...}
#'   \item{functional_class_desc}{...}
#'   \item{urban_area_desc}{...}
#'   \item{municipality_name}{...}
#'   \item{routeid_rh}{...}
#'   \item{shape_st_length}{...}
#'   \item{sha_class}{...}
#'   \item{geometry}{...}
#' }
#' @source \url{...}
# "baltimore_msa_streets"
NULL
