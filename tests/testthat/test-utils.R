context("utils")

test_that("rws_table_names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  expect_identical(rws_list_tables(conn), character(0))
  local <- data.frame(x = 1:3)
  z <- 1

  rws_write(local, exists = FALSE, conn = conn)
  expect_identical(rws_list_tables(conn), "local")
})
