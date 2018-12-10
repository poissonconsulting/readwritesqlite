context("metad")

test_that("make_meta_data works", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  
  local <- data.frame(x = as.character(1:3))
  
  expect_identical(make_meta_data(con), 
                   data.frame(TableMeta = character(0), ColumnMeta = character(0), 
                              stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_identical(make_meta_data(con), data.frame(TableMeta = "LOCAL",
                                                   ColumnMeta = "X",
                                                   stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(con, "loCal2", local))
  expect_identical(make_meta_data(con), data.frame(TableMeta = c("LOCAL", "LOCAL2"),
                                                   ColumnMeta = c("X", "X"),
                                                   stringsAsFactors = FALSE))
})

test_that("read_sqlite_meta creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  meta <- rws_read_sqlite_meta()
  expect_identical(colnames(meta),
                   c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta"))
  expect_identical(nrow(meta), 0L)
})

test_that("meta handles logical", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(con, "local", local)
  expect_identical(rws_write_sqlite(local), "local")
  meta <- rws_read_sqlite_meta()
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = NA_character_))
})

test_that("meta handles all classes", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(logical = TRUE, date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  meta <- rws_read_sqlite_meta()
  expect_identical(meta, tibble::tibble(TableMeta = rep("LOCAL", 4),
                                        ColumnMeta = c("DATE", "LOGICAL", "POSIXCT", "UNITS"),
                                        MetaMeta = c("class: Date", "class: logical", "tz: Etc/GMT+8", "units: m"),
                                        DescriptionMeta = rep(NA_character_, 4)))
})

test_that("meta errors if meta and then no meta", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  expect_identical(rws_write_sqlite(local), "local")
  
  local$z <- as.character(local$z)
  expect_error(rws_write_sqlite(local), 
               "column 'z' in table 'local' has 'No' meta data for the input data but 'class: logical' for the existing data")
})

test_that("meta errors if no meta and then meta", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = as.character(c(TRUE, FALSE, NA)), stringsAsFactors = FALSE)
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  expect_identical(rws_write_sqlite(local), "local")
  
  local$z <- as.logical(local$z)
  expect_error(rws_write_sqlite(local), 
               "column 'z' in table 'local' has 'class: logical' meta data for the input data but 'No' for the existing data")
})

test_that("meta errors if inconsistent meta", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  expect_identical(rws_write_sqlite(local), "local")
  
  local$z <- Sys.Date()
  expect_error(rws_write_sqlite(local), 
               "column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data")
})

test_that("fix meta inconsistent by deleting", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  expect_identical(rws_write_sqlite(local), "local")
  
  local$z <- Sys.Date()
  expect_error(rws_write_sqlite(local), 
               "column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data")
  expect_identical(rws_write_sqlite(local, delete = TRUE), "local")
  expect_identical(rws_write_sqlite(local), "local")
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  expect_error(rws_write_sqlite(local), 
               "column 'z' in table 'local' has 'class: logical' meta data for the input data but 'class: Date' for the existing data")
})

test_that("meta reads logical", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta reads off", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  
  remote <- rws_read_sqlite_table("local", meta = FALSE)
  local$z <- as.integer(local$z)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta reads all classes", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(logical = TRUE, date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"),
                      geometry = sf::st_sfc(sf::st_point(c(0,1)), crs = 4326))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  expect_identical(readwritesqlite:::table_schema("local", con),
                   paste0("CREATE TABLE `local` (\n  `logical` INTEGER,\n  ",
                          "`date` REAL,\n  `posixct` REAL,\n  `units` REAL,\n  ",
                          "`geometry` BLOB\n)"))    
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta logical logical different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- c(TRUE, FALSE, NA)
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(1L, 0L, NA),
    zreal = c(1, 0, NA),
    znumeric = c(1L, 0L, NA),
    ztext = c("TRUE", "FALSE", NA),
    zblob = c(1, 0, NA)))
})

test_that("meta Date different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- as.Date(c("2001-02-03", "2002-03-04", NA))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(11356L, 11750L, NA),
    zreal = c(11356, 11750, NA),
    znumeric = c(11356L, 11750L, NA),
    ztext = c("2001-02-03", "2002-03-04", NA),
    zblob = c(11356, 11750, NA)))
})

test_that("meta POSIXct different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- as.POSIXct(c(
    "2001-01-02 03:04:05", "2007-08-09 10:11:12", NA), tz = "Etc/GMT+8")
  
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(978433445L, 1186683072L, NA),
    zreal = c(978433445, 1186683072, NA),
    znumeric = c(978433445L, 1186683072L, NA),
    ztext = c("2001-01-02 03:04:05", "2007-08-09 10:11:12", NA),
    zblob = c(978433445, 1186683072, NA)))
})

test_that("meta units different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- units::as_units(c(10, 11.5, NA), "m3")
  
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob NONE
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(10, 11.5, NA),
    zreal = c(10, 11.5, NA),
    znumeric = c(10, 11.5, NA),
    ztext = c("10.0", "11.5", NA),
    zblob = c(10, 11.5, NA)))
})

test_that("meta sfc different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- sf::st_sfc(c(sf::st_point(c(0,1)), 
                    sf::st_point(c(0,1)),
                    sf::st_point(c(0,1))
  ), crs = 4326)
  
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  colnames(local) <- c("zinteger", "zreal", "znumeric", "ztext", "zblob")
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(vapply(remote2, is.blob, TRUE), 
                   c(zinteger = TRUE, zreal = TRUE, znumeric = TRUE,
                     ztext = FALSE, zblob = TRUE))
  expect_identical(remote2$ztext, "MULTIPOINT (0 1, 0 1, 0 1)")
})

test_that("meta factor different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  colnames(local) <- c("zinteger", "zreal", "znumeric", "ztext", "zblob")
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local), "local")
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(2L, 1L, NA),
    zreal = c(2, 1, NA),
    znumeric = c(2L, 1L, NA),
    ztext = c("x", "y", NA),
    zblob = c(2L, 1L, NA)))
})

test_that("read_meta_levels", {
  expect_identical(read_meta_levels("factor:  '1', '3'"), c("1", "3"))
  expect_identical(read_meta_levels("ordered:'4'"), c("4"))
  expect_identical(read_meta_levels("'1', '3', '10'"), c("1", "3", "10"))
  expect_identical(read_meta_levels(character(0)), character(0))
  expect_identical(read_meta_levels("factor:  "), character(0))
})
