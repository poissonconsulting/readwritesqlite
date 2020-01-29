context("check")

test_that("check_table_names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))

  local <- data.frame(x = 1:2)
  expect_true(DBI::dbCreateTable(conn, "local", local))

  expect_error(check_table_names(1, conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),
    "^`table_names` must inherit from S3 class 'character'[.]$",
    class = "chk_error"
  )
  expect_error(
    check_table_names(c("e", "f"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),
    "^Table 'e' does not exist[.]$"
  )
  expect_error(
    check_table_names(c(.log_table_name, "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),
    "'readwritesqlite_log' is a reserved table"
  )
  expect_error(
    check_table_names(c(.meta_table_name, "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),
    "'readwritesqlite_meta' is a reserved table"
  )
  expect_error(
    check_table_names(c("Readwritesqlite_iniT", "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),
    "'Readwritesqlite_iniT' is a reserved table"
  )
  expect_identical(check_table_names("e", conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE), "e")
  expect_identical(check_table_names(c("e", "f"), conn, exists = FALSE, delete = FALSE, all = FALSE, unique = FALSE), c("e", "f"))
  expect_identical(
    check_table_names(c("e", "e"), conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE),
    c("e", "e")
  )
  expect_error(
    check_table_names(c("e", "e"), conn, exists = FALSE, delete = FALSE, all = FALSE, unique = FALSE),
    "^The following table name is duplicated: 'e'; but exists = FALSE[.]$"
  )
  expect_error(
    check_table_names(c("e", "f", "f", "e"), conn, exists = FALSE, delete = TRUE, all = FALSE, unique = FALSE),
    "^The following table names are duplicated: 'e' and 'f'; but exists = FALSE and delete = TRUE[.]$"
  )
  expect_error(
    check_table_names(c("e", "f", "f", "e", "e"), conn, exists = FALSE, delete = TRUE, all = FALSE, unique = FALSE),
    "^The following table names are duplicated: 'e' and 'f'; but exists = FALSE and delete = TRUE[.]$"
  )
  expect_error(
    check_table_names(c("e", "E"), conn, exists = NA, delete = TRUE, all = FALSE, unique = FALSE),
    "^The following table name is duplicated: 'e'; but delete = TRUE[.]$"
  )
  expect_error(
    check_table_names(c("e", "E"), conn, exists = NA, delete = TRUE, all = FALSE, unique = TRUE),
    "^The following table name is duplicated: 'e'; but unique = TRUE and delete = TRUE[.]$"
  )
  expect_identical(
    check_table_names(c("e", "E"), conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE),
    c("e", "E")
  )
  expect_error(
    check_table_names(c("e"), conn, exists = NA, delete = FALSE, all = TRUE, unique = FALSE),
    "^The following table name is not represented: 'LOCAL'; but all = TRUE and exists != FALSE[.]$"
  )
  expect_identical(
    check_table_names("local", conn, exists = NA, delete = FALSE, all = TRUE, unique = TRUE),
    "local"
  )
})
