context("query")

test_that("rws_get_sqlite_query works with meta = FALSE", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:3)
  local2 <- as_conditional_tibble(local[1:2,,drop = FALSE])
  DBI::dbWriteTable(conn, "local", local)
  DBI::dbWriteTable(conn, "local2", local2)
  data<- rws_query_sqlite("SELECT * FROM local", meta = FALSE, conn = conn)
  expect_equal(data, local)
  data2 <- rws_query_sqlite("SELECT * FROM local2", meta = FALSE, conn = conn)
  expect_identical(data2, local2)
})

test_that("rws_get_sqlite_query works with meta = TRUE and logical", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(z = c(TRUE, FALSE, NA))
  expect_identical(rws_write_sqlite(local, exists = FALSE, conn = conn), "local")

  data <- rws_query_sqlite("SELECT * FROM local", meta = FALSE, conn = conn)
  expect_equal(data, data.frame(z = c(1L, 0L, NA_integer_)))
  expect_error(rws_query_sqlite("SELECT * FROM local", meta = TRUE, conn = conn))
})
