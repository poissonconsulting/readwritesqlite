test_that("chk_sqlite_conn", {
  expect_error(chk_sqlite_conn(1),
    "`x` must inherit from S4 class 'SQLiteConnection'[.].*`x` must inherit from S3 class 'Pool'[.]$",
    class = "chk_error"
  )
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  
  expect_null(chk_sqlite_conn(conn))
  expect_invisible(chk_sqlite_conn(conn))
  expect_null(chk_sqlite_conn(conn, connected = TRUE))
  expect_error(
    chk_sqlite_conn(conn, connected = FALSE),
    "`conn` must be disconnected[.]$",
    class = "chk_error"
  )
  DBI::dbDisconnect(conn)

  expect_null(chk_sqlite_conn(conn))
  expect_error(
    chk_sqlite_conn(conn, connected = TRUE),
    "`conn` must be connected[.]$",
    class = "chk_error"
  )
  expect_null(chk_sqlite_conn(conn, connected = FALSE))
})
