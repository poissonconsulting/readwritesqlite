context("connection")

test_that("rws_open_connection", {
  expect_error(rws_open_connection(":memory:", exists = TRUE),
               "File ':memory:' must already exist.")
  conn <- rws_open_connection(":memory:")
  expect_identical(check_sqlite_connection(conn, connected = TRUE), conn)
  rws_close_connection(conn)
  expect_identical(check_sqlite_connection(conn, connected = FALSE), conn)
})
