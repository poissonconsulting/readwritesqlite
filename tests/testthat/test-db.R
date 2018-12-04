context("db")

test_that("table_column_names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3))

  expect_identical(table_column_names(con), 
                   data.frame(Table = character(0), Column = character(0), stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_identical(table_column_names(con), data.frame(Table = "loCal",
                                                       Column = "x",
                                                       stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal2", local))
  expect_identical(table_column_names(con), data.frame(Table = c("loCal", "loCal2"),
                                                       Column = c("x", "x"),
                                                       stringsAsFactors = FALSE))
})

test_that("unquoted table names case insensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))

  local <- data.frame(x = as.character(1:3))

  expect_false(tables_exists("loCal", con))
  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_true(tables_exists("loCal", con))
  expect_true(tables_exists("LOCAL", con))
  expect_identical(tables_exists(c("loCal", "LOCAL"), con), c(TRUE, TRUE))
  expect_true(DBI::dbCreateTable(con, "`loCal`", local))
  expect_true(tables_exists("`loCal`", con))
  # this is why need own internal tables_exists
  expect_false(dbExistsTable(con, "`loCal`"))
  expect_false(tables_exists("`LOCAL`", con))
})

test_that("foreign keys", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  
  # by default foreign keys are not switched on
  expect_false(foreign_keys(con))
  expect_true(foreign_keys(con))
  expect_true(foreign_keys(con))
  expect_true(foreign_keys(con, FALSE))
  expect_false(foreign_keys(con))
  expect_true(foreign_keys(con))
})
