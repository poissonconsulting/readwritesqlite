context("write-table")

test_that("dbWriteTable", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  expect_is(con, "SQLiteConnection")
})


