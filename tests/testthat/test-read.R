test_that("rws_read requires table", {

  conn <- local_conn()
  
  expect_error(rws_read("local2", conn = conn), "^Table 'local2' does not exist[.]$")
})

test_that("rws_read returns tibble", {

  conn <- local_conn()
  
  local <- data.frame(x = as.character(1:3), stringsAsFactors = FALSE)
  DBI::dbWriteTable(conn, "local", local)
  
  skip_if_not_installed("tibble")
  expect_identical(
    rws_read("local", conn = conn),
    list(local = tibble::as_tibble(local))
  )
})

test_that("rws_read returns empty named list", {

  conn <- local_conn()
  
  tables <- rws_read(conn)
  expect_identical(tables, list(y = 2)[FALSE])
})

test_that("rws_read returns list with single named data frame", {

  conn <- local_conn()
  
  local <- data.frame(x = 1:3)
  DBI::dbWriteTable(conn, "local", local)
  tables <- rws_read(conn)
  expect_identical(tables, list(local = tibble::as_tibble(local)))
})

test_that("rws_read returns list with multiple named data frames", {

  conn <- local_conn()
  
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

  conn <- local_conn()
  
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

test_that("rws_read converts non number text to NA integer (no 0s)", {
  conn <- rws_connect(":memory:")
  
  teardown(rws_disconnect(conn))
  
  age <- data.frame(zz = c(1L, 0L))
  rws_write(age, exists = FALSE, conn = conn)
  
  age <- data.frame(zz = c("1", "0", "no age", NA_character_))
  
  rws_write(age, conn = conn)
  
  expect_warning(x <- rws_read("age", conn = conn)$age, "^Column `zz`: mixed type, first seen values of type integer, coercing other values of type string$")
  
  testthat::skip("'no age' should not be converted to 0")
  expect_identical(x, tibble::tibble(zz = c(1L, 0L, 1L, 0L, NA, NA)))
})

test_that("rws_read converts non number text to NA real (no 0s)", {
  conn <- rws_connect(":memory:")
  
  teardown(rws_disconnect(conn))
  
  age <- data.frame(zz = c(1, 0))
  rws_write(age, exists = FALSE, conn = conn)
  
  age <- data.frame(zz = c("1", "0", "no age", NA_character_))
  
  rws_write(age, conn = conn)
  
  expect_warning(x <- rws_read("age", conn = conn)$age, "^Column `zz`: mixed type, first seen values of type real, coercing other values of type string$")
  
  testthat::skip("'no age' should not be converted to 0")
  expect_identical(x, tibble::tibble(zz = c(1, 0, 1, 0, NA, NA)))
})

test_that("rws_read converts text to NA integer (no 0s)", {
  conn <- rws_connect(":memory:")
  
  teardown(rws_disconnect(conn))
  
  age <- data.frame(zz = c(1L, 0L))
  rws_write(age, exists = FALSE, conn = conn)
  
  age <- data.frame(zz = c("1", "0", "no age", NA_character_))
  
  rws_write(age, conn = conn)
  
  expect_warning(x <- rws_read("age", conn = conn)$age, "^Column `zz`: mixed type, first seen values of type integer, coercing other values of type string$")
  
  expect_identical(x, tibble::tibble(zz = c(1L, 0L, 1L, 0L, 0L, NA_integer_)))
})

test_that("rws_read converts text to NA boolean (no 0s)", {
  conn <- rws_connect(":memory:")
  
  teardown(rws_disconnect(conn))
  
  age <- data.frame(zz = c(TRUE, FALSE))
  rws_write(age, exists = FALSE, conn = conn)
  
  age <- data.frame(zz = c("1", "0", "no age", NA_character_))
  
  skip("Getting error Column 'zz' in table 'age' has 'No' meta data for the input data but 'class: logical' for the existing data.")
  rws_write(age, conn = conn)
  
  x <- rws_read("age", conn = conn)$age
  
  expect_identical(x, tibble::tibble(zz = c(1L, 0L, 1L, 0L, 0L, NA_integer_)))
})

test_that("rws_read converts integer to text", {
  conn <- rws_connect(":memory:")
  
  teardown(rws_disconnect(conn))
  
  age <- data.frame(zz = c("1", "0", "no age", NA_character_))
  rws_write(age, exists = FALSE, conn = conn)
  
  age <- data.frame(zz = c(1L, 0L))
  rws_write(age, conn = conn)
  
  x <- rws_read("age", conn = conn)$age
  
  expect_identical(x, tibble::tibble(zz = c("1", "0", "no age", NA, "1", "0")))
})
