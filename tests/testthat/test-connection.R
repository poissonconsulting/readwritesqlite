context("connection")

test_that("rws_open_connection", {
  conn <- rws_open_connection(":memory:")
  expect_identical(check_sqlite_connection(conn, connected = TRUE), conn)
  rws_close_connection(conn)
  expect_identical(check_sqlite_connection(conn, connected = FALSE), conn)
})
