test_that("get_area_911_calls works", {
  call_df <-
    get_area_911_calls(
      area_type = "neighborhood",
      area_name = "Barclay",
      description = "DISCHRG FIREARM",
      start_date = "2023-01-01",
      end_date = "2023-01-31"
    )

  expect_s3_class(
    call_df,
    "data.frame"
  )

  expect_error(
    get_area_911_calls(year = 2016)
  )
})
