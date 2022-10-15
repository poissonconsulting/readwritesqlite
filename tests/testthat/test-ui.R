test_that("ui functions work", {
  expect_type(capture.output(ui_value("hi")), "character")
  expect_type(capture.output(ui_line("hi")), "character")
})
