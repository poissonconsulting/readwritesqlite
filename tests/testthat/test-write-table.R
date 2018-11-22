context("write-table")

test_that("dbWriteTable", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = 1:3, select = 1:3)
  dbWriteTable(con, "data", local)
  remote <- dbReadTable(con, "data", check.names = FALSE)

  expect_equal(local, remote)
})


