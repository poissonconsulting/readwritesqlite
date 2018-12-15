context("check")

test_that("check_sqlite_connection", {
  expect_error(check_sqlite_connection(1), 
               "1 must inherit from class SQLiteConnection")
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  expect_identical(check_sqlite_connection(conn), conn)
  expect_identical(check_sqlite_connection(conn, connected = TRUE), conn)
  expect_error(check_sqlite_connection(conn, connected = FALSE), 
               "conn must be disconnected")
  DBI::dbDisconnect(conn)

  expect_identical(check_sqlite_connection(conn), conn)
  expect_error(check_sqlite_connection(conn, connected = TRUE), 
               "conn must be connected")
  expect_identical(check_sqlite_connection(conn, connected = FALSE), conn)
})

test_that("check_table_names", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  teardown(DBI::dbDisconnect(conn))
  
  local <- data.frame(x = 1:2)
  expect_true(DBI::dbCreateTable(conn, "local", local))

  expect_error(check_table_names(1, conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE), 
               "table_names must be class character")
  expect_error(check_table_names(c("e", "f"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE), 
               "table 'e' does not exist")
  expect_error(check_table_names(c(.log_table_name, "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),  
               "'readwritesqlite_log' is a reserved table")
  expect_error(check_table_names(c(.meta_table_name, "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),  
               "'readwritesqlite_meta' is a reserved table")
  expect_error(check_table_names(c("Readwritesqlite_iniT", "e"), conn, exists = TRUE, delete = FALSE, all = FALSE, unique = FALSE),  
               "'Readwritesqlite_iniT' is a reserved table")
  expect_identical(check_table_names("e", conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE), "e")
  expect_identical(check_table_names(c("e", "f"), conn, exists = FALSE, delete = FALSE, all = FALSE, unique = FALSE), c("e", "f"))
  expect_identical(check_table_names(c("e", "e"), conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE), 
                   c("e", "e"))
  expect_error(check_table_names(c("e", "e"), conn, exists = FALSE, delete = FALSE, all = FALSE, unique = FALSE), 
                   "exists = FALSE but the following table name is duplicated: 'e'")
  expect_error(check_table_names(c("e", "f", "f", "e"), conn, exists = FALSE, delete = TRUE, all = FALSE, unique = FALSE), 
                   "exists = FALSE and delete = TRUE but the following table names are duplicated: 'e' and 'f'")
  expect_error(check_table_names(c("e", "f", "f", "e", "e"), conn, exists = FALSE, delete = TRUE, all = FALSE, unique = FALSE), 
                   "exists = FALSE and delete = TRUE but the following table names are duplicated: 'e' and 'f'")
  expect_error(check_table_names(c("e", "E"), conn, exists = NA, delete = TRUE, all = FALSE, unique = FALSE), 
                   "delete = TRUE but the following table name is duplicated: 'e'")
  expect_error(check_table_names(c("e", "E"), conn, exists = NA, delete = TRUE, all = FALSE, unique = TRUE), 
                   "unique = TRUE and delete = TRUE but the following table name is duplicated: 'e'")
  expect_identical(check_table_names(c("e", "E"), conn, exists = NA, delete = FALSE, all = FALSE, unique = FALSE), 
                   c("e", "E"))
  expect_error(check_table_names(c("e"), conn, exists = NA, delete = FALSE, all = TRUE, unique = FALSE),
               "all = TRUE and exists != FALSE but the following table name is not represented: 'LOCAL'")
  expect_identical(check_table_names("local", conn, exists = NA, delete = FALSE, all = TRUE, unique = TRUE), 
                   "local")
})
