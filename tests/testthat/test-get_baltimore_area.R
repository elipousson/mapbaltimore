test_that("get_baltimore_area works", {
  expect_s3_class(
    get_baltimore_area(),
    "sf"
  )
  expect_error(
    get_baltimore_area("block")
  )
  expect_s3_class(
    get_baltimore_area("neighborhoods"),
    "sf"
  )
  expect_s3_class(
    get_baltimore_area("neighborhood"),
    "sf"
  )
})
