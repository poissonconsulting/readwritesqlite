context("dependencies")

test_that("unquoted table names case insensitive in RSQLite", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(conn, "loCal", local))
  expect_identical(DBI::dbListTables(conn), "loCal")

  # these match
  expect_true(DBI::dbExistsTable(conn, "loCal"))
  expect_true(DBI::dbExistsTable(conn, "local"))
  expect_true(DBI::dbExistsTable(conn, "LOCAL"))

  expect_false(DBI::dbExistsTable(conn, "`loCal`"))
  expect_false(DBI::dbExistsTable(conn, "[loCal]"))
  expect_false(DBI::dbExistsTable(conn, "\"loCal\""))
  expect_false(DBI::dbExistsTable(conn, '"loCal"'))

  expect_error(
    DBI::dbCreateTable(conn, "loCal", local),
    "table `loCal` already exists"
  )
  expect_error(
    DBI::dbCreateTable(conn, "local", local),
    "table `local` already exists"
  )
  expect_error(
    DBI::dbCreateTable(conn, "LOCAL", local),
    "table `LOCAL` already exists"
  )
  expect_true(DBI::dbCreateTable(conn, "`loCal`", local))
  expect_identical(DBI::dbListTables(conn), c("`loCal`", "loCal"))
  expect_true(DBI::dbCreateTable(conn, "[loCal]", local))
  expect_identical(DBI::dbListTables(conn), c("[loCal]", "`loCal`", "loCal"))
  expect_true(DBI::dbCreateTable(conn, "\"loCal\"", local))
  expect_identical(
    DBI::dbListTables(conn),
    c("\"loCal\"", "[loCal]", "`loCal`", "loCal")
  )
})

test_that("``quoted table names case sensitive in RSQLite", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(conn, "`loCal`", local))
  expect_identical(DBI::dbListTables(conn), "`loCal`")

  expect_false(DBI::dbExistsTable(conn, "``loCal``"))
  expect_false(DBI::dbExistsTable(conn, "loCal"))
  expect_false(DBI::dbExistsTable(conn, "[loCal]"))
  expect_false(DBI::dbExistsTable(conn, "\"loCal\""))
  expect_false(DBI::dbExistsTable(conn, '"loCal"'))

  skip_if_not_installed("RSQLite", "2.1.1.9003")
  expect_true(DBI::dbExistsTable(conn, "`loCal`"))
})

test_that("[] quoted table names case sensitive in RSQLite", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(conn, "[loCal]", local))
  expect_identical(DBI::dbListTables(conn), "[loCal]")

  # this matches!
  expect_true(DBI::dbExistsTable(conn, "[loCal]"))

  expect_false(DBI::dbExistsTable(conn, "loCal"))
  expect_false(DBI::dbExistsTable(conn, "`loCal`"))
  expect_false(DBI::dbExistsTable(conn, "\"loCal\""))
  expect_false(DBI::dbExistsTable(conn, '"loCal"'))
})

test_that("\"\" quoted table names case sensitive in RSQLite", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(conn, "\"loCal\"", local))
  expect_identical(DBI::dbListTables(conn), "\"loCal\"")

  # these match!
  expect_true(DBI::dbExistsTable(conn, "\"loCal\""))
  expect_true(DBI::dbExistsTable(conn, '"loCal"'))

  expect_false(DBI::dbExistsTable(conn, "[loCal]"))
  expect_false(DBI::dbExistsTable(conn, "loCal"))
  expect_false(DBI::dbExistsTable(conn, "`loCal`"))
})

test_that('"" quoted table names case sensitive in RSQLite', {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = as.character(1:3))

  expect_true(DBI::dbCreateTable(conn, '"loCal"', local))
  expect_identical(DBI::dbListTables(conn), "\"loCal\"")

  # these match!
  expect_true(DBI::dbExistsTable(conn, '"loCal"'))
  expect_true(DBI::dbExistsTable(conn, "\"loCal\""))

  expect_false(DBI::dbExistsTable(conn, "[loCal]"))
  expect_false(DBI::dbExistsTable(conn, "loCal"))
  expect_false(DBI::dbExistsTable(conn, "`loCal`"))
})
