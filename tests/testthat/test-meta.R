context("metad")

test_that("make_meta_data works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3))
  
  expect_identical(make_meta_data(conn), 
                   data.frame(TableMeta = character(0), ColumnMeta = character(0), 
                              stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(conn, "loCal", local))
  expect_identical(make_meta_data(conn), data.frame(TableMeta = "LOCAL",
                                                   ColumnMeta = "X",
                                                   stringsAsFactors = FALSE))
  expect_true(DBI::dbCreateTable(conn, "loCal2", local))
  expect_identical(make_meta_data(conn), data.frame(TableMeta = c("LOCAL", "LOCAL2"),
                                                   ColumnMeta = c("X", "X"),
                                                   stringsAsFactors = FALSE))
})

test_that("read_sqlite_meta creates table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  meta <- rws_read_sqlite_meta(conn)
  expect_identical(colnames(meta),
                   c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta"))
  expect_identical(nrow(meta), 0L)
})

test_that("meta handles logical", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  DBI::dbCreateTable(conn, "local", local)
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  meta <- rws_read_sqlite_meta(conn)
  expect_identical(meta, tibble::tibble(TableMeta = "LOCAL",
                                        ColumnMeta = "Z",
                                        MetaMeta = "class: logical",
                                        DescriptionMeta = NA_character_))
})

test_that("meta handles all classes", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(logical = TRUE, date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  meta <- rws_read_sqlite_meta(conn)
  expect_identical(meta, tibble::tibble(TableMeta = rep("LOCAL", 4),
                                        ColumnMeta = c("DATE", "LOGICAL", "POSIXCT", "UNITS"),
                                        MetaMeta = c("class: Date", "class: logical", "tz: Etc/GMT+8", "units: m"),
                                        DescriptionMeta = rep(NA_character_, 4)))
})

test_that("meta errors if meta and then no meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  local$z <- as.character(local$z)
  expect_error(rws_write_sqlite(local, conn = conn), 
               "column 'z' in table 'local' has 'No' meta data for the input data but 'class: logical' for the existing data")
})

test_that("meta errors if no meta and then meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = as.character(c(TRUE, FALSE, NA)), stringsAsFactors = FALSE)
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  local$z <- as.logical(local$z)
  expect_error(rws_write_sqlite(local, conn = conn), 
               "column 'z' in table 'local' has 'class: logical' meta data for the input data but 'No' for the existing data")
})

test_that("meta errors if inconsistent meta", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  local$z <- Sys.Date()
  expect_error(rws_write_sqlite(local, conn = conn), 
               "column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data")
})

test_that("fix meta inconsistent by deleting", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  local$z <- Sys.Date()
  expect_error(rws_write_sqlite(local, conn = conn), 
               "column 'z' in table 'local' has 'class: Date' meta data for the input data but 'class: logical' for the existing data")
  expect_identical(rws_write_sqlite(local, delete = TRUE, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  expect_error(rws_write_sqlite(local, conn = conn), 
               "column 'z' in table 'local' has 'class: logical' meta data for the input data but 'class: Date' for the existing data")
})

test_that("meta reads logical", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta reads off", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  
  remote <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  local$z <- as.integer(local$z)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta reads all classes", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(logical = TRUE, 
                      date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"),
                      geometry = sf::st_sfc(sf::st_point(c(0,1)), crs = 4326),
                      factor = factor("fac"),
                      ordered = ordered("ordered"))
  
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")
  expect_identical(readwritesqlite:::table_schema("local", conn),
                   paste0("CREATE TABLE `local` (\n  `logical` INTEGER,\n  ",
                          "`date` REAL,\n  `posixct` REAL,\n  `units` REAL,\n  ",
                          "`geometry` BLOB,\n  `factor` TEXT,\n  `ordered` TEXT\n)"))    
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta logical logical different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- c(TRUE, FALSE, NA)
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(1L, 0L, NA),
    zreal = c(1, 0, NA),
    znumeric = c(1L, 0L, NA),
    ztext = c("TRUE", "FALSE", NA),
    zblob = c(1, 0, NA)))
})

test_that("meta Date different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.Date(c("2001-02-03", "2002-03-04", NA))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(11356L, 11750L, NA),
    zreal = c(11356, 11750, NA),
    znumeric = c(11356L, 11750L, NA),
    ztext = c("2001-02-03", "2002-03-04", NA),
    zblob = c(11356, 11750, NA)))
})

test_that("meta POSIXct different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- as.POSIXct(c(
    "2001-01-02 03:04:05", "2007-08-09 10:11:12", NA), tz = "Etc/GMT+8")
  
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(978433445L, 1186683072L, NA),
    zreal = c(978433445, 1186683072, NA),
    znumeric = c(978433445L, 1186683072L, NA),
    ztext = c("2001-01-02 03:04:05", "2007-08-09 10:11:12", NA),
    zblob = c(978433445, 1186683072, NA)))
})

test_that("meta units different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- units::as_units(c(10, 11.5, NA), "m3")
  
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob NONE
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c(10, 11.5, NA),
    zreal = c(10, 11.5, NA),
    znumeric = c(10, 11.5, NA),
    ztext = c("10.0", "11.5", NA),
    zblob = c(10, 11.5, NA)))
})

test_that("meta sfc different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

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
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(vapply(remote2, is.blob, TRUE), 
                   c(zinteger = TRUE, zreal = TRUE, znumeric = TRUE,
                     ztext = FALSE, zblob = TRUE))
  expect_identical(remote2$ztext, "MULTIPOINT (0 1, 0 1, 0 1)")
})

test_that("meta factor different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA)))
})

test_that("meta ordered different types", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- ordered(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(local))
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA)))
})

test_that("meta factor without meta then meta errors", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, meta = FALSE, conn = conn), "local")
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(lapply(local, as.character)))
  
  remote2 <- rws_read_sqlite_table("local", meta = FALSE, conn = conn)
  expect_identical(remote2, tibble::tibble(
    zinteger = c("x", "y", NA),
    zreal = c("x", "y", NA),
    znumeric = c("x", "y", NA),
    ztext = c("x", "y", NA),
    zblob = c("x", "y", NA)))
  
  remote2 <- rws_read_sqlite_table("local", meta = TRUE, conn = conn)
  expect_identical(remote, tibble::as_tibble(lapply(local, as.character)))
  expect_error(rws_write_sqlite(local, meta = TRUE, conn = conn), 
                   "column 'zinteger' in table 'local' has 'factor: 'y', 'x'' meta data for the input data but 'No' for the existing data")
})

test_that("meta factor rearrange levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  z <- factor(c("x", "y", NA), levels = c("x", "y"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")
  
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(remote, tibble::as_tibble(rbind(local, local, local)))
})

test_that("meta factor add levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  z <- factor(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")

  z <- factor(c("x", "y", "z"), levels = c("z", "y", "x"))
  local2 <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  expect_identical(rws_write_sqlite(local2, x_name = "local", conn = conn), "local")
  
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(levels(remote$zinteger), c("z", "y", "x"))
  expect_identical(remote$zinteger, factor(c("x", "y", NA, "x", "y", "z"), 
                                           levels = c("z", "y", "x")))
})

test_that("meta ordered add and rearrange levels", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  z <- ordered(c("x", "y", NA), levels = c("y", "x"))
  local <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)

  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  zinteger INTEGER,
                  zreal REAL,
                  znumeric NUMERIC,
                  ztext TEXT,
                  zblob BLOB
              )")
  
  expect_identical(rws_write_sqlite(local, conn = conn), "local")

  z <- ordered(c("x", "y", "z"), levels = c("z", "x", "y"))
  local2 <- data.frame(
    zinteger = z,
    zreal = z,
    znumeric = z,
    ztext = z,
    zblob = z)
  
  expect_identical(rws_write_sqlite(local2, x_name = "local", conn = conn), "local")
  
  remote <- rws_read_sqlite_table("local", conn = conn)
  expect_identical(levels(remote$zinteger), c("z", "x", "y"))
  expect_identical(remote$zinteger, ordered(c("x", "y", NA, "x", "y", "z"), 
                                           levels = c("z", "x", "y")))
})


test_that("read_meta_levels", {
  expect_identical(read_meta_levels("factor:  '1', '3'"), c("1", "3"))
  expect_identical(read_meta_levels("ordered:'4'"), c("4"))
  expect_identical(read_meta_levels("'1', '3', '10'"), c("1", "3", "10"))
  expect_identical(read_meta_levels(character(0)), character(0))
  expect_identical(read_meta_levels("factor:  "), character(0))
})
