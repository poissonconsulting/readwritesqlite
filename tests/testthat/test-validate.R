context("validate")

test_that("rws_write_sqlite.data.frame checks all columns present", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(con, "local", local)
  local <- local[1]
  expect_error(rws_write_sqlite(local),
               "data column names must include 'X' and 'SELECT'")
})

test_that("rws_write_sqlite.data.frame checks missing values", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  local <- data.frame(x2 = c(1:3, NA), select2 = 1:4)
  
  DBI::dbGetQuery(con, "CREATE TABLE local (
                  x2 INTEGER NOT NULL,
                  select2 REAL NOT NULL
              )")
  
  expect_error(rws_write_sqlite(local),
               "there are unpermitted missing values in the following column in table 'local': 'X2'")
  local <- na.omit(local)
  expect_identical(rws_write_sqlite(local), "local")
})
