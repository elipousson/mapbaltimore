test_that("get_area_property works", {
  property <-
    get_area_property(
      area = neighborhoods[1, ],
      dist = -150,
      unit = "m"
    )
  expect_s3_class(
    property,
    "sf"
  )
})
