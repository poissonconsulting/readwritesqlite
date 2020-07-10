context("drop")

test_that("rws_drop_table works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  rws_write(list(somedata = readwritesqlite:::rws_data_sf), exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), "somedata")
  expect_true(rws_drop_table("somedata", conn))
  expect_identical(rws_list_tables(conn), character(0))
  expect_identical(rws_read_init(conn)$TableInit, character(0))
  expect_identical(rws_read_meta(conn)$TableMeta, character(0))
})

test_that("rws_rename_table informative errors", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  rws_write(list(somedata = readwritesqlite:::rws_data_sf), exists = FALSE, conn = conn)
  expect_error(
    rws_drop_table("somedata2", conn),
    "^Table 'somedata2' does not exist[.]$"
  )
  expect_error(
    rws_drop_table("readwritesqlite_meta", conn),
    "^Table 'readwritesqlite_meta' is a reserved table[.]$"
  )
})

test_that("rws_rename_table multiple tables", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  rws_write(list(somedata = data.frame(y = 2), moredata = data.frame(x = 1)), exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), sort(c("moredata", "somedata")))
  expect_true(rws_drop_table("somedata", conn))
  expect_identical(rws_list_tables(conn), "moredata")
  expect_identical(rws_read_init(conn)$TableInit, "MOREDATA")
  expect_identical(rws_read_meta(conn)$TableMeta, "MOREDATA")
})

test_that("rws_drop_table primary key deferred", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  DBI::dbExecute(conn, "CREATE TABLE local (
                  x INTEGER PRIMARY KEY NOT NULL)")

  DBI::dbExecute(conn, "CREATE TABLE local2 (
                  x INTEGER NOT NULL PRIMARY KEY,
                  y INTEGER NOT NULL,
                FOREIGN KEY (x) REFERENCES local (x))")

  local <- data.frame(x = 1:4)
  expect_identical(rws_write(local, conn = conn), "local")

  local2 <- data.frame(x = c(1:2, 4L))
  local2$y <- local2$x + 10L
  expect_identical(rws_write(local2, conn = conn), "local2")

  expect_true(rws_drop_table("local", conn = conn))
  expect_identical(rws_list_tables(conn), "local2")

  expect_identical(
    readwritesqlite:::table_schema("local2", conn),
    "CREATE TABLE local2 (\n                  x INTEGER NOT NULL PRIMARY KEY,\n                  y INTEGER NOT NULL,\n                FOREIGN KEY (x) REFERENCES local (x))"
  )

  expect_identical(
    rws_read_table("local2", conn = conn),
    structure(list(x = c(1L, 2L, 4L), y = c(11L, 12L, 14L)), class = c(
      "tbl_df",
      "tbl", "data.frame"
    ), row.names = c(NA, -3L))
  )

  expect_error(rws_write(local2, conn = conn), "no such table: main.local")
})
