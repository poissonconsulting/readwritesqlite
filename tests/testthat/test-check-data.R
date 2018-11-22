context("check-data")

test_that("test dbCheckTableSQLite checks table exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  expect_error(dbCheckDataSQLite(con, "data", local[1]),
               "'data' is not an existing table")
})

test_that("test dbCheckTableSQLite checks all columns present", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  dbWriteTable(con, "data", local)
  expect_error(dbCheckDataSQLite(con, "data", local[1]),
               "value column names must include 'x' and 'select'")
})

test_that("test dbCheckTableSQLite corrects column order", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  dbWriteTable(con, "data", local)
  expect_identical(dbCheckDataSQLite(con, "data", local), local)
  expect_identical(dbCheckDataSQLite(con, "data", local[2:1]), local)
  expect_identical(dbCheckDataSQLite(con, "data", local[c(1,1,2)]), local)
})

test_that("test dbCheckTableSQLite converts factor to character", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)

  local2 <- local
  local2$x <- factor(local2$x)
  dbWriteTable(con, "data", local)
  expect_identical(dbCheckDataSQLite(con, "data", local2), local2)
  expect_identical(dbCheckDataSQLite(con, "data", local2, convert = TRUE), local)
})
