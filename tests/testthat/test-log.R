context("log")

test_that("dbReadLogTableSQLite creates table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  log <- dbReadLogTableSQLite(con)
  expect_identical(colnames(log), c("DateTimeUTCLog", "UserLog", "TableLog",
                                    "CommandLog", "NRowLog"))
  expect_identical(nrow(log), 0L)
})

