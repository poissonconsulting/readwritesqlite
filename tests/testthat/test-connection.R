context("connection")

test_that("rws_connect", {
  expect_error(rws_connect(":memory:", exists = TRUE),
               "File ':memory:' must already exist.")
  conn <- rws_connect(":memory:")
  expect_true(chk_sqlite_conn(conn, connected = TRUE))
  rws_disconnect(conn)
  expect_true(chk_sqlite_conn(conn, connected = FALSE))
})
