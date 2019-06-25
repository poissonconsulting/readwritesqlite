context("connection")

test_that("rws_connect", {
  expect_error(rws_connect(":memory:", exists = TRUE),
               "File ':memory:' must already exist.")
  conn <- rws_connect(":memory:")
  expect_identical(check_sqlite_connection(conn, connected = TRUE), conn)
  rws_disconnect(conn)
  expect_identical(check_sqlite_connection(conn, connected = FALSE), conn)
})
