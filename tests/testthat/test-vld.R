context("vld")

test_that("vld_sqlite_conn", {
  expect_false(vld_sqlite_conn(1))
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  expect_true(vld_sqlite_conn(conn))
  expect_true(vld_sqlite_conn(conn, connected = TRUE))
  expect_false(vld_sqlite_conn(conn, connected = FALSE))
  DBI::dbDisconnect(conn)

  expect_true(vld_sqlite_conn(conn))
  expect_false(vld_sqlite_conn(conn, connected = TRUE))
  expect_true(vld_sqlite_conn(conn, connected = FALSE))
})
