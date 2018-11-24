context("dependencies")

test_that("write_sqlite.data.frame writes", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, "local", local))
  expect_identical(DBI::dbListTables(con), "local")
  expect_true(DBI::dbExistsTable(con, "local"))
  expect_true(DBI::dbExistsTable(con, "LOCAL"))
  # this is weird as says not exists!
  expect_false(DBI::dbExistsTable(con, "`local`"))
  
  # RSQLite is case insensitive for table names
  expect_error(DBI::dbCreateTable(con, "LOCAL", local), 
               "table `LOCAL` already exists")
  
  # unless table names are quoted
  expect_true(DBI::dbCreateTable(con, "`LOCAL`", local))
  
  expect_identical(DBI::dbListTables(con), c("`LOCAL`", "local"))
  
  expect_error(DBI::dbCreateTable(con, "`local`", local), 
               "table ```local``` already exists")
})