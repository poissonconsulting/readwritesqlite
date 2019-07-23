context("db")

test_that("nrows_table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3))
  expect_true(DBI::dbCreateTable(conn, "local", local))
  expect_identical(nrows_table("local", conn), 0L)
  DBI::dbWriteTable(conn, "local", local, append = TRUE)
  expect_identical(nrows_table("local", conn), 3L)
})

test_that("unquoted table names case insensitive in RSQLite", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = as.character(1:3))
  
  expect_false(tables_exists("loCal", conn))
  expect_true(DBI::dbCreateTable(conn, "loCal", local))
  expect_true(tables_exists("loCal", conn))
  expect_true(tables_exists("LOCAL", conn))
  expect_identical(tables_exists(c("loCal", "LOCAL"), conn), c(TRUE, TRUE))
  expect_true(DBI::dbCreateTable(conn, "`loCal`", local))
  expect_true(tables_exists("`loCal`", conn))
  expect_false(tables_exists("`LOCAL`", conn))
  skip_if_not_installed("RSQLite", "2.1.1.9003")
    expect_true(dbExistsTable(conn, "`loCal`"))
})

test_that("foreign keys", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  # by default foreign keys are not switched on
  expect_false(foreign_keys(TRUE, conn))
  expect_true(foreign_keys(TRUE, conn))
  expect_true(foreign_keys(TRUE, conn))
  expect_true(foreign_keys(FALSE, conn))
  expect_false(foreign_keys(TRUE, conn))
  expect_true(foreign_keys(TRUE, conn))
})

test_that("table_info", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(logical = TRUE, date = as.Date("2000-01-01"),
                      posixct = as.POSIXct("2001-01-02 03:04:05", tz = "Etc/GMT+8"),
                      units = units::as_units(10, "m"),
                      geometry = sf::st_sfc(sf::st_point(c(0,1)), crs = 4326))

  expect_identical(rws_write(local, exists = FALSE, conn = conn), "local")
  
  table_info <- table_info("local", conn)
  expect_is(table_info, "data.frame")
  expect_identical(colnames(table_info), 
                            c("cid", "name", "type", "notnull", "dflt_value", "pk"))
  expect_identical(table_info$cid, 0:4)
  expect_identical(table_info$name, c("logical", "date", "posixct", "units", "geometry"))
  expect_identical(table_info$type, c("INTEGER", "REAL", "REAL", "REAL", "BLOB"))
  expect_identical(table_info$notnull, rep(0L, 5))
  expect_identical(table_info$pk, rep(0L, 5))
  
  expect_identical(table_column_type("GEOMETRY", "local", conn), "BLOB")
})
