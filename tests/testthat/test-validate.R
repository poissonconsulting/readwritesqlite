context("validate")

test_that("rws_write.data.frame checks all columns present", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  local <- local[1]
  expect_error(rws_write(local, conn = conn),
               "'local' column names must include 'X' and 'SELECT'")
})

test_that("rws_write.data.frame checks missing values", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x2 = c(1:3, NA), select2 = 1:4)
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  x2 INTEGER NOT NULL,
                  select2 REAL NOT NULL
              )")
  
  expect_error(rws_write(local, conn = conn),
               "there are unpermitted missing values in the following column in data 'local': 'X2'")
  local <- na.omit(local)
  expect_identical(rws_write(local, conn = conn), "local")
})

test_that("rws_write.data.frame checks primary key on input values", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x2 = c(1,1,2), select2 = c(3,3,3))
  
  DBI::dbGetQuery(conn, "CREATE TABLE local (
                  x2 INTEGER,
                  select2 INTEGER,
              PRIMARY KEY (x2, select2))")
  
  expect_error(rws_write(local, conn = conn),
               "columns 'X2' and 'SELECT2' in data 'local' must be a unique key")
  local$x2 <- 1:3
  expect_identical(rws_write(local, conn = conn), "local")
})

