test_that("rws_write.data.frame checks all columns present", {

  conn <- local_conn()

  local <- data.frame(x = as.character(1:3), select = 1:3)
  DBI::dbCreateTable(conn, "local", local)
  local <- local[1]
  expect_error(rws_write(local, conn = conn),
    "'local' column names must include 'SELECT'",
    class = "chk_error"
  )
})

test_that("rws_write.data.frame checks missing values", {

  conn <- local_conn()

  local <- data.frame(x2 = c(1:3, NA), select2 = 1:4)

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x2 INTEGER NOT NULL,
                  select2 REAL NOT NULL
              )")

  expect_error(
    rws_write(local, conn = conn),
    "There are unpermitted missing values in the following 1 column in data 'local': 'X2'"
  )
  local <- na.omit(local)
  expect_identical(rws_write(local, conn = conn), "local")
})

test_that("rws_write.data.frame checks primary key on input values", {

  conn <- local_conn()

  local <- data.frame(x2 = c(1, 1, 2), select2 = c(3, 3, 3))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x2 INTEGER,
                  select2 INTEGER,
              PRIMARY KEY (x2, select2))")

  expect_error(rws_write(local, conn = conn),
    "^Columns 'X2' and 'SELECT2' in data 'local' must be unique[.]$",
    class = "chk_error"
  )
  local$x2 <- 1:3
  expect_identical(rws_write(local, conn = conn), "local")
})
