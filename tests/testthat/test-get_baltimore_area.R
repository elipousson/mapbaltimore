test_that("get_baltimore_area works", {
  expect_error(
    get_baltimore_area()
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
