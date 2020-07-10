context("read")

test_that("rws_read requires table", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  expect_error(rws_read("local2", conn = conn), "^Table 'local2' does not exist[.]$")
})

test_that("rws_read returns tibble", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbWriteTable(conn, "local", local)

  skip_if_not_installed("tibble")
  expect_identical(
    rws_read("local", conn = conn),
    list(local = tibble::as_tibble(local))
  )
})

test_that("rws_read returns empty named list", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  tables <- rws_read(conn)
  expect_identical(tables, list(y = 2)[FALSE])
})

test_that("rws_read returns list with single named data frame", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  DBI::dbWriteTable(conn, "local", local)
  tables <- rws_read(conn)
  expect_identical(tables, list(local = tibble::as_tibble(local)))
})

test_that("rws_read returns list with multiple named data frames", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  local2 <- local[1:2, , drop = FALSE]
  DBI::dbWriteTable(conn, "local", local)
  DBI::dbWriteTable(conn, "local2", local2)
  tables <- rws_read(conn)
  expect_identical(tables, list(
    local = tibble::as_tibble(local),
    local2 = tibble::as_tibble(local2)
  ))
})

test_that("rws_read with meta = FALSE ", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- readwritesqlite:::rws_data_sf
  expect_identical(rws_write(local, exists = NA, conn = conn), "local")
  expect_identical(
    rws_read_table("local", meta = TRUE, conn = conn),
    rws_read_table("local", meta = TRUE, conn = conn)
  )
  remote <- rws_read_table("local", meta = TRUE, conn = conn)

  expect_identical(class(remote), c("sf", "tbl_df", "tbl", "data.frame"))
  expect_identical(colnames(remote), colnames(local))
  expect_identical(nrow(remote), 3L)
  expect_identical(remote$logical, local$logical)
  expect_identical(remote$date, local$date)
  expect_identical(remote$posixct, local$posixct)
  expect_identical(remote$units, local$units)
  expect_identical(remote$factor, local$factor)
  expect_identical(remote$ordered, local$ordered)
  expect_equivalent(remote$geometry, local$geometry)

  remote2 <- rws_read_table("local", meta = FALSE, conn = conn)
  remote2$geometry <- NULL
  expect_identical(remote2, tibble::tibble(
    logical = c(1L, 0L, NA),
    date = c(10957, 11356, NA),
    factor = c("x", "y", NA),
    ordered = c("x", "y", NA),
    posixct = c(978433445, 1152378611, NA),
    units = c(10, 11.5, NA)
  ))
})
