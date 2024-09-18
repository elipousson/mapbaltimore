test_that("get_area_permits works", {
  skip("Test disabled 2024-09-18 - updates needed")
  permits <-
    get_area_permits(
      area = neighborhoods[1, ],
      date_range = c("2022-01-01", "2022-03-30")
    )
  expect_s3_class(
    permits,
    "sf"
  )
})
