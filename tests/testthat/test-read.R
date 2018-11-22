context("read")

test_that("dbReadTableSQLite requires table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  expect_error(dbReadTableSQLite("local2"), "table 'local2' does not exist")
})

test_that("dbReadTableSQLite requires table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(dbWriteSQLite.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbWriteTable(con, "local", local)
  expect_identical(dbReadTableSQLite("local"), tibble::as_tibble(local))
})

