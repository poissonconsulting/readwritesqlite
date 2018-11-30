context("check")

test_that("check_sqlite_connection", {
  expect_error(check_sqlite_connection(1), 
               "1 must inherit from class SQLiteConnection")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  expect_identical(check_sqlite_connection(con), con)
  expect_identical(check_sqlite_connection(con, connected = TRUE), con)
  expect_error(check_sqlite_connection(con, connected = FALSE), 
               "con must be disconnected")
  DBI::dbDisconnect(con)

  expect_identical(check_sqlite_connection(con), con)
  expect_error(check_sqlite_connection(con, connected = TRUE), 
               "con must be connected")
  expect_identical(check_sqlite_connection(con, connected = FALSE), con)
})