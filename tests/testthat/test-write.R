context("write")

test_that("rws_write_sqlite.data.frame checks reserved table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local, table_name =  "readwritesqlite_log"),
               "'readwritesqlite_log' is a reserved table")
  expect_error(rws_write_sqlite(local, table_name =  "readwritesqlite_LOG"),
               "'readwritesqlite_LOG' is a reserved table")
  expect_error(rws_write_sqlite(local, table_name = "readwritesqlite_meta"),
               "'readwritesqlite_meta' is a reserved table")
  expect_error(rws_write_sqlite(local, table_name = "READwritesqlite_meta"),
               "'READwritesqlite_meta' is a reserved table")
})

test_that("rws_write_sqlite.data.frame checks table exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local),
               "table 'local' does not exist")
})

test_that("rws_write_sqlite.data.frame writes to existing table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(rws_write_sqlite(local), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame errors if exists = FALSE and already exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_error(rws_write_sqlite(local, exists = FALSE), "table 'local' already exists")
})

test_that("rws_write_sqlite.data.frame creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame handling of case", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  DBI::dbCreateTable(con, "`LOCAL`", local)
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(local, table_name = "LOCAL"), "LOCAL")
  LOCAL <- local
  expect_identical(rws_write_sqlite(LOCAL), "LOCAL")
  expect_identical(rws_write_sqlite(LOCAL, table_name = "`LOCAL`"), "`LOCAL`")

  remote <- DBI::dbReadTable(con, "LOCAL")
  expect_identical(remote, rbind(local, local, local))
  
  REMOTE <- DBI::dbReadTable(con, "`LOCAL`")
  expect_identical(REMOTE, LOCAL)
})

test_that("rws_write_sqlite.data.frame checks all columns present", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  local <- local[1]
  expect_error(rws_write_sqlite(local),
               "data column names must include 'x' and 'select'")
})

test_that("rws_write_sqlite.data.frame corrects column order", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 4:6, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(local[2:1], table_name = "local"), "local")
  expect_identical(rws_write_sqlite(local[c(1,1,2)], table_name = "local"), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, rbind(local, local, local))
})

test_that("rws_write_sqlite.data.frame can delete", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(con, "local", local)
  rws_write_sqlite(local)
  rws_write_sqlite(local, delete = TRUE)
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite.data.frame can not commit", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  DBI::dbCreateTable(con, "local", local)
  rws_write_sqlite(local, commit = FALSE)
  remote <- DBI::dbReadTable(con, "local")
  expect_equal(local[integer(0),,drop = FALSE], remote)
  expect_false(DBI::dbExistsTable(con, "readwritesqlite_meta"))
  expect_false(DBI::dbExistsTable(con, "readwritesqlite_log"))
})

test_that("rws_write_sqlite.list returns character(0) with empty list", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  rws_write_sqlite(named_list())
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
#   op <- options(rws.conn = con)
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
#   op <- options(rws.conn = con)
#   teardown(options(op))
# 
#   local <- data.frame(x = 1:3)
#   local2 <- data.frame(x = 2:6)
#   DBI::dbCreateTable(con, "local2", local)
#   DBI::dbCreateTable(con, "local", local)
#   expect_identical(dbWriteTablesSQLite(), c("local", "local2"))
#   expect_identical(dbReadLogTableSQLite()$TableLog, c("local", "local2"))
# })

