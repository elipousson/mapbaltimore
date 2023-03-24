test_that("filter_streets works", {
  expect_s3_class(
    filter_streets(streets, sha_class = "FWY"),
    "sf"
  )
  expect_s3_class(
    filter_streets(streets, sha_class = "FWY", union = TRUE),
    "sf"
  )
  expect_s3_class(
    filter_streets(streets, street_type = "STRPRD"),
    "sf"
  )
})
