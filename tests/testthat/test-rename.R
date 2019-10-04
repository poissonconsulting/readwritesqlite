context("rename")

test_that("rws_rename_table works", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  rws_write(list(somedata = readwritesqlite::rws_data), exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), "somedata")
  expect_true(rws_rename_table("somedata", "tableb", conn))
  expect_identical(rws_list_tables(conn), "tableb")
  expect_identical(rws_read_init(conn)$TableInit, "TABLEB")
  expect_identical(rws_read_meta(conn)$TableMeta, rep("TABLEB", 7))
})

test_that("rws_rename_table informative errors", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  rws_write(list(somedata = readwritesqlite::rws_data), exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), "somedata")
  expect_error(rws_rename_table("somedata2", "tableb", conn),
              "^Table 'somedata2' does not exist[.]$")
  expect_error(rws_rename_table("somedata", "somedata", conn),
              "^Table 'somedata' already exists[.]$")
  expect_error(rws_rename_table("somedata", "someData", conn),
              "^Table 'someData' already exists[.]$")
  expect_error(rws_rename_table("somedata", "readwritesqlite_meta", conn))
})

test_that("rws_rename_table multiple tables", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  rws_write(list(somedata = data.frame(y = 2), moredata = data.frame(x = 1)), exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), sort(c("moredata", "somedata")))
  expect_true(rws_rename_table("somedata", "tableB", conn))
  expect_identical(rws_list_tables(conn), sort(c("moredata", "tableB")))
  expect_identical(rws_read_init(conn)$TableInit, sort(c("MOREDATA", "TABLEB")))
  expect_identical(rws_read_meta(conn)$TableMeta, sort(c("MOREDATA", "TABLEB")))
})

test_that("rws_rename_table primary key", {
  
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
  
  expect_true(rws_rename_table("local", "tb", conn = conn))
  
  expect_identical(readwritesqlite:::table_schema("local2", conn),
                   "CREATE TABLE local2 (\n                  x INTEGER NOT NULL PRIMARY KEY,\n                  y INTEGER NOT NULL,\n                FOREIGN KEY (x) REFERENCES \"tb\" (x))")
})
