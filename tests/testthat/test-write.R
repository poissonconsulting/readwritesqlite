context("write")

test_that("rws_write_sqlite.data.frame checks reserved table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local, x_name =  "readwritesqlite_log"),
               "'readwritesqlite_log' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name =  "readwritesqlite_LOG"),
               "'readwritesqlite_LOG' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name = "readwritesqlite_meta"),
               "'readwritesqlite_meta' is a reserved table")
  expect_error(rws_write_sqlite(local, x_name = "READwritesqlite_meta"),
               "'READwritesqlite_meta' is a reserved table")
})

test_that("rws_write_sqlite.data.frame checks table exists", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))
  expect_error(rws_write_sqlite(local, exists = TRUE),
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
  expect_identical(rws_write_sqlite(local, x_name = "LOCAL"), "LOCAL")
  LOCAL <- local
  expect_identical(rws_write_sqlite(LOCAL), "LOCAL")
  expect_identical(rws_write_sqlite(LOCAL, x_name = "`LOCAL`"), "`LOCAL`")
  
  remote <- DBI::dbReadTable(con, "LOCAL")
  expect_identical(remote, rbind(local, local, local))
  
  REMOTE <- DBI::dbReadTable(con, "`LOCAL`")
  expect_identical(REMOTE, LOCAL)
})

test_that("rws_write_sqlite.data.frame deals with \" quoted table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(con, "local", local)
  DBI::dbCreateTable(con, '"local"', locals)
  expect_identical(rws_list_tables(), sort(c("\"local\"", "local")))
  
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "\"local\""), "\"local\"")
  remotes <- DBI::dbReadTable(con, "\"local\"")
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame deals with [ quoted table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(con, "local", local)
  DBI::dbCreateTable(con, "[local]", locals)
  expect_identical(rws_list_tables(), sort(c("[local]", "local")))
  
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "[local]"), "[local]")
  remotes <- as.data.frame(rws_read_sqlite_table("[local]"))
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame deals with backtick quoted table names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = 1:3, select = 1:3)
  locals <- data.frame(y = 1:2)
  DBI::dbCreateTable(con, "local", local)
  DBI::dbCreateTable(con, "`local`", locals)
  expect_identical(rws_list_tables(), sort(c("`local`", "local")))
  
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(locals, x_name = "`local`"), "`local`")
  remotes <- DBI::dbReadTable(con, "`local`")
  expect_identical(remotes, locals)
})

test_that("rws_write_sqlite.data.frame corrects column order", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = 4:6, select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  expect_identical(rws_write_sqlite(local), "local")
  expect_identical(rws_write_sqlite(local[2:1], x_name = "local"), "local")
  expect_identical(rws_write_sqlite(local[c(1,1,2)], x_name = "local"), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, rbind(local, local, local))
})

test_that("rws_write_sqlite.data.frame is case insensitive", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3), seLect = 1:3)
  DBI::dbCreateTable(con, "local", local)
  colnames(local) <- toupper(colnames(local))
  
  expect_identical(rws_write_sqlite(local), "local")
})

test_that("rws_write_sqlite.data.frame deals with quoted column names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- tibble::tibble(x = factor(1:3), `[x]` = factor(2:4), `"x"` = factor(3:5))
  expect_identical(rws_write_sqlite(local), "local")
  
  meta <- rws_read_sqlite_meta()
  expect_identical(meta$ColumnMeta, sort(c("\"x\"", "[x]", "X")))
  expect_identical(DBI::dbReadTable(con, "local"),
                   data.frame(x = as.character(1:3),
                              X.x. = as.character(2:4),
                              X.x..1 = as.character(3:5),
                              stringsAsFactors = FALSE))
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, local)
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

test_that("rws_write_sqlite.list errors with none data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(x = 1)
  expect_error(rws_write_sqlite(y), "list 'y' includes objects which are not data frames")
})

test_that("rws_write_sqlite.environment issues warning with no data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- new.env()
  assign("x", 1, envir = y)
  expect_warning(rws_write_sqlite(y), "environment 'y' has no data frames")
})

test_that("rws_write_sqlite.list requires named list", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(data.frame(x = 1:3))
  expect_error(rws_write_sqlite(y), "x must be named")
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

test_that("rws_write_sqlite errors if list with 2 identically named data frames and complete = TRUE", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  DBI::dbCreateTable(con, "LOCAL", y$local)
  expect_error(rws_write_sqlite(y, complete = TRUE), 
                   "complete = TRUE but the following table name is duplicated: 'local'")
})

test_that("rws_write_sqlite errors if complete = TRUE and not all data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(local = data.frame(x = 1:3))
  
  DBI::dbCreateTable(con, "LOCAL", y$local)
  DBI::dbCreateTable(con, "LOCAL2", y$local)
  expect_error(rws_write_sqlite(y, complete = TRUE), 
                   "complete = TRUE but the following table name is not represented: 'LOCAL2'")
})

test_that("rws_write_sqlite warns if complete = TRUE and exists = TRUE and extra data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(local = data.frame(x = 1:3), local2 = data.frame(y = 1:2))
  
  DBI::dbCreateTable(con, "LOCAL", y$local)
  expect_warning(rws_write_sqlite(y, exists = TRUE, complete = TRUE), 
                   "the following data frame is ignored because exists = TRUE and complete = TRUE: 'local2'")
})

test_that("rws_write_sqlite writes environment", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local = data.frame(x = 1:3)
  z <- 1
  
  expect_identical(rws_write_sqlite(environment()), "local")
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, local)
})

test_that("rws_write_sqlite not commits", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  y <- list(local = data.frame(x = 1:3), LOCAL = data.frame(x = 1:4))
  
  expect_identical(rws_write_sqlite(y, exists = NA, commit = FALSE), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(con), character(0))
  expect_identical(rws_write_sqlite(y, exists = NA, commit = TRUE), c("local", "LOCAL"))
  expect_identical(DBI::dbListTables(con), c("local", "readwritesqlite_log", "readwritesqlite_meta"))
  remote <- DBI::dbReadTable(con, "local")
  expect_identical(remote, rbind(y$local, y$LOCAL))
})

test_that("foreign keys switched on one data frame at a time", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(con, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  y <- list(local = data.frame(x = 1:4), local2 = data.frame(x = 1:3))
  
  expect_error(rws_write_sqlite(y$local2, x_name = "local2"), 
               "FOREIGN KEY constraint failed")
  
  expect_identical(rws_write_sqlite(y$local, x_name = "local"), "local")
  expect_identical(rws_write_sqlite(y$local2, x_name = "local2"), "local2")
})

test_that("foreign keys switched off for two data frame", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(con, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  expect_false(foreign_keys(TRUE, con))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 1:4))
  expect_identical(rws_write_sqlite(y), c("local2", "local"))
  expect_true(foreign_keys(TRUE, con))
})

test_that("foreign keys pick up foreign key violation for two data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")
  
  DBI::dbGetQuery(con, "CREATE TABLE local2 (
                  x INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")
  
  expect_false(foreign_keys(TRUE, con))
  y <- list(local2 = data.frame(x = 1:3), local = data.frame(x = 2:3))
  expect_error(rws_write_sqlite(y), "FOREIGN KEY constraint failed")
  expect_true(foreign_keys(TRUE, con))
})

