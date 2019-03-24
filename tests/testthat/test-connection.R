context("connection")

test_that("rws_connect", {
  expect_error(rws_connect(":memory:", exists = TRUE),
               "File ':memory:' must already exist.")
  conn <- rws_connect(":memory:")
  expect_identical(check_sqlite_connection(conn, connected = TRUE), conn)
  rws_disconnect(conn)
  expect_identical(check_sqlite_connection(conn, connected = FALSE), conn)
  expect_identical(rws_close_connection(rws_open_connection(":memory:")), 
                   rws_disconnect(rws_connect(":memory:")))
})
