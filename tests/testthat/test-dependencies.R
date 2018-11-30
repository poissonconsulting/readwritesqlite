context("dependencies")

test_that("unquoted table names case insensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, "loCal", local))
  expect_identical(DBI::dbListTables(con), "loCal")
  
  # these match
  expect_true(DBI::dbExistsTable(con, "loCal"))
  expect_true(DBI::dbExistsTable(con, "local"))
  expect_true(DBI::dbExistsTable(con, "LOCAL"))
  
  expect_false(DBI::dbExistsTable(con, "`loCal`"))
  expect_false(DBI::dbExistsTable(con, "[loCal]"))
  expect_false(DBI::dbExistsTable(con, "\"loCal\""))
  expect_false(DBI::dbExistsTable(con, '"loCal"'))
  
  expect_error(DBI::dbCreateTable(con, "loCal", local),
               "table `loCal` already exists")
  expect_error(DBI::dbCreateTable(con, "local", local),
               "table `local` already exists")
  expect_error(DBI::dbCreateTable(con, "LOCAL", local),
               "table `LOCAL` already exists")
  expect_true(DBI::dbCreateTable(con, "`loCal`", local))
  expect_identical(DBI::dbListTables(con), c("`loCal`", "loCal"))
  expect_true(DBI::dbCreateTable(con, "[loCal]", local))
  expect_identical(DBI::dbListTables(con), c("[loCal]", "`loCal`", "loCal"))
  expect_true(DBI::dbCreateTable(con, "\"loCal\"", local))
  expect_identical(DBI::dbListTables(con), 
                   c("\"loCal\"", "[loCal]", "`loCal`", "loCal"))
})

test_that("``quoted table names case sensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, "`loCal`", local))
  expect_identical(DBI::dbListTables(con), "`loCal`")

  # this is weird as says not exists!!
  expect_false(DBI::dbExistsTable(con, "`loCal`"))
  # but creation fails with error already exists
  expect_error(DBI::dbCreateTable(con, "`loCal`", local),
               "table ```loCal``` already exists")

  expect_false(DBI::dbExistsTable(con, "``loCal``"))
  expect_false(DBI::dbExistsTable(con, "loCal"))
  expect_false(DBI::dbExistsTable(con, "[loCal]"))
  expect_false(DBI::dbExistsTable(con, "\"loCal\""))
  expect_false(DBI::dbExistsTable(con, '"loCal"'))
}

test_that("[] quoted table names case sensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, "[loCal]", local))
  expect_identical(DBI::dbListTables(con), "[loCal]")

  # this matches!
  expect_true(DBI::dbExistsTable(con, "[loCal]"))

  expect_false(DBI::dbExistsTable(con, "loCal"))
  expect_false(DBI::dbExistsTable(con, "`loCal`"))
  expect_false(DBI::dbExistsTable(con, "\"loCal\""))
  expect_false(DBI::dbExistsTable(con, '"loCal"'))
}

test_that("\"\" quoted table names case sensitive in RSQLite", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, "\"loCal\"", local))
  expect_identical(DBI::dbListTables(con), "\"loCal\"")

  # these match!
  expect_true(DBI::dbExistsTable(con, "\"loCal\""))
  expect_true(DBI::dbExistsTable(con, '"loCal"'))

  expect_false(DBI::dbExistsTable(con, "[loCal]"))
  expect_false(DBI::dbExistsTable(con, "loCal"))
  expect_false(DBI::dbExistsTable(con, "`loCal`"))
}

test_that('"" quoted table names case sensitive in RSQLite', {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  op <- options(readwritesqlite.conn = con)
  teardown(options(op))
  
  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(con, '"loCal"', local))
  expect_identical(DBI::dbListTables(con), "\"loCal\"")

  # these match!
  expect_true(DBI::dbExistsTable(con, '"loCal"'))
  expect_true(DBI::dbExistsTable(con, "\"loCal\""))

  expect_false(DBI::dbExistsTable(con, "[loCal]"))
  expect_false(DBI::dbExistsTable(con, "loCal"))
  expect_false(DBI::dbExistsTable(con, "`loCal`"))
}
