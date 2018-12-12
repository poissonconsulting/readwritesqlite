context("check")

test_that("check_sqlite_connection", {
  expect_error(check_sqlite_connection(1), 
               "1 must inherit from class SQLiteConnection")
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  expect_identical(check_sqlite_connection(con), con)
  expect_identical(check_sqlite_connection(con, connected = TRUE), con)
  expect_error(check_sqlite_connection(con, connected = FALSE), 
               "con must be disconnected")
  DBI::dbDisconnect(con)

  expect_identical(check_sqlite_connection(con), con)
  expect_error(check_sqlite_connection(con, connected = TRUE), 
               "con must be connected")
  expect_identical(check_sqlite_connection(con, connected = FALSE), con)
})

test_that("check_table_names", {
  con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(con))
  
  local <- data.frame(x = 1:2)
  expect_true(DBI::dbCreateTable(con, "local", local))

  expect_error(check_table_names(1, con, exists = TRUE, delete = FALSE, complete = FALSE), 
               "table_names must be class character")
  expect_error(check_table_names(c("e", "f"), con, exists = TRUE, delete = FALSE, complete = FALSE), 
               "table 'e' does not exist")
  expect_error(check_table_names(c(.log_table_name, "e"), con, exists = TRUE, delete = FALSE, complete = FALSE),  
               "'readwritesqlite_log' is a reserved table")
  expect_error(check_table_names(c(.meta_table_name, "e"), con, exists = TRUE, delete = FALSE, complete = FALSE),  
               "'readwritesqlite_meta' is a reserved table")
  expect_identical(check_table_names("e", con, exists = NA, delete = FALSE, complete = FALSE), "e")
  expect_identical(check_table_names(c("e", "f"), con, exists = FALSE, delete = FALSE, complete = FALSE), c("e", "f"))
  expect_identical(check_table_names(c("e", "e"), con, exists = NA, delete = FALSE, complete = FALSE), 
                   c("e", "e"))
  expect_error(check_table_names(c("e", "e"), con, exists = FALSE, delete = FALSE, complete = FALSE), 
                   "exists = FALSE but the following table name is duplicated: 'e'")
  expect_error(check_table_names(c("e", "f", "f", "e"), con, exists = FALSE, delete = TRUE, complete = FALSE), 
                   "exists = FALSE and delete = TRUE but the following table names are duplicated: 'e' and 'f'")
  expect_error(check_table_names(c("e", "f", "f", "e", "e"), con, exists = FALSE, delete = TRUE, complete = FALSE), 
                   "exists = FALSE and delete = TRUE but the following table names are duplicated: 'e' and 'f'")
  expect_error(check_table_names(c("e", "E"), con, exists = NA, delete = TRUE, complete = FALSE), 
                   "delete = TRUE but the following table name is duplicated: 'e'")
  expect_error(check_table_names(c("e", "E"), con, exists = NA, delete = TRUE, complete = TRUE), 
                   "delete = TRUE and complete = TRUE but the following table name is duplicated: 'e'")
  expect_identical(check_table_names(c("e", "E"), con, exists = NA, delete = FALSE, complete = FALSE), 
                   c("e", "E"))
  expect_error(check_table_names(c("e"), con, exists = NA, delete = FALSE, complete = TRUE),
               "complete = TRUE but the following table name is not represented: 'LOCAL'")
  expect_identical(check_table_names("local", con, exists = NA, delete = FALSE, complete = TRUE), 
                   "local")
})
