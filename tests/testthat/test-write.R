context("write")

test_that("write_sqlite.data.frame checks reserved table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(write_sqlite(local, con, table_name = "readwritesqlite_log"),
               "'readwritesqlite_log' is a reserved table")
  expect_error(write_sqlite(local, con, table_name = toupper("readwritesqlite_log")),
               "'readwritesqlite_log' is a reserved table")
  expect_error(write_sqlite(local, con, table_name = "readwritesqlite_meta"),
               "'readwritesqlite_meta' is a reserved table")
  expect_error(write_sqlite(local, con, table_name = toupper("readwritesqlite_meta")),
               "'readwritesqlite_meta' is a reserved table")
})

test_that("write_sqlite.data.frame checks table exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(write_sqlite(local),
               "table 'local' does not exist")
})

test_that("write_sqlite.data.frame writes", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(write_sqlite(local), "local")
  remote <- dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("write_sqlite.data.frame handling of case", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  DBI::dbCreateTable(con, "`LOCAL`", local)
  expect_identical(write_sqlite(local), "local")
  expect_identical(write_sqlite(local), "local")
  expect_identical(write_sqlite(local, table_name = "local"), "local")
  expect_identical(write_sqlite(local, table_name = "LOCAL"), "local")
  LOCAL <- local
  expect_identical(write_sqlite(LOCAL), "local")
})

test_that("write_sqlite.data.frame checks all columns present", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  local <- local[1]
  expect_error(write_sqlite(local),
               "data column names must include 'x' and 'select'")
})

test_that("write_sqlite.data.frame corrects column order", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 4:6, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(write_sqlite(local), "local")
  expect_identical(write_sqlite(local[2:1], table_name = "local"), "local")
  expect_identical(write_sqlite(local[c(1,1,2)], table_name = "local"), "local")
  remote <- dbReadTable(con, "local")
  expect_identical(remote, rbind(local, local, local))
})

test_that("write_sqlite.data.frame can delete", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(con, "local", local)
  write_sqlite(local)
  write_sqlite(local, delete = TRUE)
  remote <- dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("write_sqlite.data.frame can not commit", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(con, "local", local)
  write_sqlite(local, commit = FALSE)
  remote <- DBI::dbReadTable(con, "local")
  expect_equal(local[integer(0),,drop = FALSE], remote)
  expect_false(DBI::dbExistsTable(con, "readwritesqlite_meta"))
  expect_false(DBI::dbExistsTable(con, "readwritesqlite_log"))
})

test_that("write_sqlite.list returns character(0) with empty list", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))

  write_sqlite(named_list())
})

#   expect_identical(, character(0))
#   local1 <- data.frame(x = 1:3)
#   local2 <- data.frame(y = 2:4)
#   expect_identical(dbWriteTablesSQLite(), character(0))
# })
# 
# test_that("dbWriteTablesSQLite writes 1 table", {
#   con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#   teardown(DBI::dbDisconnect(con))
#   op <- options(readwritesqlite.conn = con)
#   teardown(options(op))
# 
#   local <- data.frame(x = 1:3)
#   local2 <- data.frame(x = 2:6)
#   DBI::dbCreateTable(con, "local", local)
#   expect_identical(dbWriteTablesSQLite(), "local")
#   expect_identical(dbReadLogTableSQLite()$TableLog, "local")
# })
# 
# test_that("dbWriteTablesSQLite writes 2 table", {
#   con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#   teardown(DBI::dbDisconnect(con))
#   op <- options(readwritesqlite.conn = con)
#   teardown(options(op))
# 
#   local <- data.frame(x = 1:3)
#   local2 <- data.frame(x = 2:6)
#   DBI::dbCreateTable(con, "local2", local)
#   DBI::dbCreateTable(con, "local", local)
#   expect_identical(dbWriteTablesSQLite(), c("local", "local2"))
#   expect_identical(dbReadLogTableSQLite()$TableLog, c("local", "local2"))
# })

