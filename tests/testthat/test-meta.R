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
  
  local <- data.frame(z = as.character(c(TRUE, FALSE, NA)))

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
  remote <- rws_read_sqlite_table("local")
  expect_identical(remote, tibble::as_tibble(local))
})

test_that("meta does logical different types", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  
  # dbSendQuery("CREATE TABLE local ")
  # 
  # expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  # 
  # remote <- rws_read_sqlite_table("local")
  # expect_identical(remote, tibble::as_tibble(local))
})

