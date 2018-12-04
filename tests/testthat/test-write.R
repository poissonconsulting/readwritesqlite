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

test_that("rws_write_sqlite.list issues warning with no data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(x = 1)
  expect_warning(rws_write_sqlite(y), "x has no data frames")
})

test_that("rws_write_sqlite.list requires named list", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(data.frame(x = 1:3))
  expect_error(rws_write_sqlite(y), "x must be named")
})

test_that("rws_write_sqlite requires existing table by default", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(local = data.frame(x = 1:3))
  
  expect_error(rws_write_sqlite(y), "table 'local' does not exist")
})

test_that("rws_write_sqlite writes list with 1 data frame", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(local = data.frame(x = 1:3))
  
  DBI::dbCreateTable(con, "local", y$local)
  expect_identical(rws_write_sqlite(y), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, y$local)
})

test_that("rws_write_sqlite writes list with 2 data frame", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:4))
  
  DBI::dbCreateTable(con, "local", y$local)
  DBI::dbCreateTable(con, "local2", y$local2)
  expect_identical(rws_write_sqlite(y), c("local", "local2"))
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, y$local)
  remote2 <- DBI::dbReadTable(con, "local2")
  expect_identical(remote2, y$local2)
})

test_that("rws_write_sqlite writes list with 2 identically named data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  DBI::dbCreateTable(con, "LOCAL", y$local)
  expect_identical(rws_write_sqlite(y), c("local", "LOCAL"))
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})
