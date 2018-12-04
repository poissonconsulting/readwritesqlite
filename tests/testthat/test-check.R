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
    
  expect_error(check_table_names(1, con, exists = TRUE, delete = FALSE), 
               "table_names must be class character")
  expect_error(check_table_names(c("e", "f"), con, exists = TRUE, delete = FALSE), 
               "table 'e' does not exist")
  expect_error(check_table_names(c(.log_table_name, "e"), con, exists = TRUE, delete = FALSE),  
               "'readwritesqlite_log' is a reserved table")
  expect_error(check_table_names(c(.meta_table_name, "e"), con, exists = TRUE, delete = FALSE),  
               "'readwritesqlite_meta' is a reserved table")
  expect_identical(check_table_names("e", con, exists = NA, delete = FALSE), "e")
  expect_identical(check_table_names(c("e", "f"), con, exists = FALSE, delete = FALSE), c("e", "f"))
  expect_identical(check_table_names(c("e", "e"), con, exists = NA, delete = FALSE), 
                   c("e", "e"))
  expect_error(check_table_names(c("e", "e"), con, exists = FALSE, delete = FALSE), 
                   "table name 'e' is duplicated [(]exists is FALSE[)]")
  expect_error(check_table_names(c("e", "f", "f", "e"), con, exists = FALSE, delete = TRUE), 
                   "the following 2 table names are duplicates: 'e' and 'f' [(]exists is FALSE and delete is TRUE[)]")
  expect_error(check_table_names(c("e", "f", "f", "e", "e"), con, exists = FALSE, delete = TRUE), 
                   "the following 2 table names are duplicates: 'e' and 'f' [(]exists is FALSE and delete is TRUE[)]")
  expect_error(check_table_names(c("e", "E"), con, exists = NA, delete = TRUE), 
                   "the following 2 table names are duplicates: 'e' and 'E' [(]delete is TRUE[)]")
  expect_identical(check_table_names(c("e", "E"), con, exists = NA, delete = FALSE), 
                   c("e", "E"))
})
