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
