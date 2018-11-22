context("write-table")

test_that("dbWriteTable requires existing table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  expect_error(dbWriteTableSQLite(con, "data", local),
               "'data' is not an existing table")
})

test_that("dbWriteTable commit = FALSE does not commit", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  DBI::dbCreateTable(con, "data", local)
  dbWriteTableSQLite(con, "data", local, commit = FALSE)
  remote <- DBI::dbReadTable(con, "data", check.names = FALSE)
  expect_equal(local[integer(0),], remote)
})
