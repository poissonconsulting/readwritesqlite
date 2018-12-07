context("db")

test_that("nrows_table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  
  local <- data.frame(x = as.character(1:3))
  expect_true(DBI::dbCreateTable(con, "local", local))
  expect_identical(nrows_table("local", con), 0L)
  DBI::dbWriteTable(con, "local", local, append = TRUE)
  expect_identical(nrows_table("local", con), 3L)
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
  expect_false(foreign_keys(TRUE, con))
  expect_true(foreign_keys(TRUE, con))
  expect_true(foreign_keys(TRUE, con))
  expect_true(foreign_keys(FALSE, con))
  expect_false(foreign_keys(TRUE, con))
  expect_true(foreign_keys(TRUE, con))
})

test_that("table_info", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(logical = TRUE, date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"),
                      geometry = sf::st_sfc(sf::st_point(c(0,1)), crs = 4326))

  expect_identical(rws_write_sqlite(local, exists = FALSE), "local")
  
  table_info <- table_info("local", con)
  expect_is(table_info, "data.frame")
  expect_identical(colnames(table_info), 
                            c("cid", "name", "type", "notnull", "dflt_value", "pk"))
  expect_identical(table_info$cid, 0:4)
  expect_identical(table_info$name, c("logical", "date", "posixct", "units", "geometry"))
  expect_identical(table_info$type, c("INTEGER", "REAL", "REAL", "REAL", "BLOB"))
  expect_identical(table_info$notnull, rep(0L, 5))
  expect_identical(table_info$pk, rep(0L, 5))
})
