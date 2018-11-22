#' Write a local data frame or file to the database
#'
#' Functions for writing data frames or delimiter-separated files
#' to database tables.
#'
#' @inheritParams DBI::dbWriteTable
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(conn, name, value) {
  check_inherits(conn, "SQLite")
  check_string(name)
  check_data(value)
  dbWriteTable(conn, name, value)
}
