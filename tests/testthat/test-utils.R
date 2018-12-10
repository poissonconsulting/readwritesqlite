context("utils")

test_that("rws_table_names",{
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(rws.conn = con)
  teardown(options(op))
  
  expect_identical(rws_list_tables(), character(0))
  local = data.frame(x = 1:3)
  z <- 1
  
  rws_write_sqlite(local)
  expect_identical(rws_list_tables(), "local")
})