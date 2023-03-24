test_that("get_streets works", {
  expect_error(
    get_streets()
  )
  expect_error(
    get_streets(1)
  )
  expect_s3_class(
    get_streets("Charles"),
    "sf"
  )
  expect_s3_class(
    get_streets("Charles", "ST PAUL"),
    "sf"
  )
})
