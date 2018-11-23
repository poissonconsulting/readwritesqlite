context("write")

test_that("dbWriteTableSQLite checks reserved table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(dbWriteTableSQLite(local, "dbWriteSQLiteLog", con),
               "'dbWriteSQLiteLog' is a reserved table")
})

test_that("dbWriteTableSQLite checks table exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(dbWriteTableSQLite(local),
               "table 'local' does not exist")
})

test_that("dbWriteTableSQLite checks all columns present", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  local <- local[1]
  expect_error(dbWriteTableSQLite(local),
               "data column names must include 'x' and 'select'")
})

test_that("dbWriteTableSQLite corrects column order", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), select = 1:3, stringsAsFactors = FALSE)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(dbWriteTableSQLite(local), local)
  expect_identical(dbWriteTableSQLite(local[2:1], "local"), local)
  expect_identical(dbWriteTableSQLite(local[c(1,1,2)], "local"), local)
  DBI::dbReadTable(con, "dbWriteSQLiteLog")
})

test_that("dbWriteTableSQLite deletes and logs commands", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  DBI::dbCreateTable(con, "local", local)
  expect_identical(nrow(dbReadLogTableSQLite(con)), 0L)
  expect_identical(dbWriteTableSQLite(local), local)
  expect_identical(nrow(dbReadLogTableSQLite(con)), 1L)
  expect_identical(dbWriteTableSQLite(local), local)
  expect_identical(nrow(dbReadLogTableSQLite(con)), 2L)
  expect_identical(dbWriteTableSQLite(local, delete = TRUE), local)
  log <- dbReadLogTableSQLite(con)
  expect_identical(colnames(log),
                   c("DateTimeUTCLog", "UserLog", "TableLog", "CommandLog",
                     "NRowLog"))
  expect_identical(attr(log$DateTimeUTCLog, "tzone"), "UTC")
  expect_identical(log$TableLog,
                   rep("local", 4L))
  expect_identical(log$CommandLog,
                   c("INSERT", "INSERT", "DELETE", "INSERT"))
  expect_identical(log$NRowLog, c(3L, 3L, 6L, 3L))
  ## need to read back in...
})

test_that("dbWriteTableSQLite commit = FALSE does not commit", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbCreateTable(con, "local", local)
  dbWriteTableSQLite(local, commit = FALSE)
  remote <- DBI::dbReadTable(con, "local")
  expect_equal(local[integer(0),,drop = FALSE], remote)
  expect_false(DBI::dbExistsTable(con, "dbWriteSQLiteLog"))
})

test_that("dbWriteTablesSQLite returns character(0) with no data and/or tables", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  expect_identical(dbWriteTablesSQLite(), character(0))
  local1 <- data.frame(x = 1:3)
  local2 <- data.frame(y = 2:4)
  expect_identical(dbWriteTablesSQLite(), character(0))
})

test_that("dbWriteTablesSQLite writes 1 table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  local2 <- data.frame(x = 2:6)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(dbWriteTablesSQLite(), "local")
  expect_identical(dbReadLogTableSQLite()$TableLog, "local")
})

test_that("dbWriteTablesSQLite writes 2 table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  local2 <- data.frame(x = 2:6)
  DBI::dbCreateTable(con, "local2", local)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(dbWriteTablesSQLite(), c("local", "local2"))
  expect_identical(dbReadLogTableSQLite()$TableLog, c("local", "local2"))
})

