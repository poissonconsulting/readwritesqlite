test_that("chk_sqlite_conn", {
  expect_error(chk_sqlite_conn(1),
##    "Error",
##    "Error in err(..., n = n, tidy = tidy, .subclass = \"chk_error\") : \n  At least one of the following conditions must be met:\n* `x` must inherit from S4 class 'SQLiteConnection'.\n* `x` must inherit from S3 class 'Pool'.\n",
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

