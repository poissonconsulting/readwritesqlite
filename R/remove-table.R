#' Write a data frame to a SQLite Database
#'
#' @inheritParams dbWriteTableSQLite
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbRemoveTableSQLite <- function(conn, name, ...) {
  check_inherits(conn, "SQLite")
  check_string(name)
  check_unused(...)

  dbBegin(conn)
  on.exit(dbRollback(conn))

  # need to filter rows from MetaData and Log

  dbRemoveTable(conn, name)
  dbCommit(conn)
  on.exit(NULL)
  invisible(TRUE)
}
