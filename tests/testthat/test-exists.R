context("exists")

test_that("unquoted table names case insensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_false(exists_table("loCal", con))
  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_true(exists_table("loCal", con))
  expect_true(exists_table("LOCAL", con))
  expect_true(DBI::dbCreateTable(con, "`loCal`", local))
  expect_true(exists_table("`loCal`", con))
  # this is why need own internal exists_table
  expect_false(dbExistsTable(con, "`loCal`"))
  expect_false(exists_table("`LOCAL`", con))
})
