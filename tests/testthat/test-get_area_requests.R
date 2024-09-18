test_that("get_area_requests works", {
  skip("Test disabled 2024-09-18 - updates needed")
  requests <-
    get_area_requests(
      area = neighborhoods[1, ],
      date_range = c("2022-01-01", "2022-01-15"),
      agency = "Solid Waste"
    )
  expect_s3_class(
    requests,
    "sf"
  )
})
