context("read")

test_that("rws_read_sqlite requires table", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  expect_error(rws_read_sqlite("local2"), "table 'local2' does not exist")
})

test_that("rws_read_sqlite returns tibble", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbWriteTable(con, "local", local)

  skip_if_not_installed("tibble")
    expect_identical(rws_read_sqlite("local"), tibble::as_tibble(local))
})

test_that("rws_read_sqlite returns empty named list", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  tables <- rws_read_sqlite()
  expect_identical(tables, list(y = 2)[FALSE])
})

test_that("rws_read_sqlite returns list with single named data frame", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  DBI::dbWriteTable(con, "local", local)
  tables <- dbReadTablesSQLite()
  expect_identical(tables, list(local = tibble::as_tibble(local)))
})

test_that("dbReadTablesSQLite returns list with multiple named data frames", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))

  local <- data.frame(x = 1:3)
  local2 <- local[1:2,,drop = FALSE]
  DBI::dbWriteTable(con, "local", local)
  DBI::dbWriteTable(con, "local2", local2)
  tables <- dbReadTablesSQLite()
  expect_identical(tables, list(local = tibble::as_tibble(local),
                                local2 = tibble::as_tibble(local2)))
})


