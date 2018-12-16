context("read")

test_that("rws_read_sqlite requires table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  expect_error(rws_read_sqlite("local2", conn = conn), "table 'local2' does not exist")
})

test_that("rws_read_sqlite returns tibble", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbWriteTable(conn, "local", local)

  skip_if_not_installed("tibble")
  expect_identical(rws_read_sqlite("local", conn = conn), 
                 list(local = tibble::as_tibble(local)))
})

test_that("rws_read_sqlite returns empty named list", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  tables <- rws_read_sqlite(conn)
  expect_identical(tables, list(y = 2)[FALSE])
})

test_that("rws_read_sqlite returns list with single named data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  DBI::dbWriteTable(conn, "local", local)
  tables <- rws_read_sqlite(conn)
  expect_identical(tables, list(local = tibble::as_tibble(local)))
})

test_that("dbReadTablesSQLite returns list with multiple named data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  local2 <- local[1:2,,drop = FALSE]
  DBI::dbWriteTable(conn, "local", local)
  DBI::dbWriteTable(conn, "local2", local2)
  tables <- rws_read_sqlite(conn)
  expect_identical(tables, list(local = tibble::as_tibble(local),
                                local2 = tibble::as_tibble(local2)))
})
