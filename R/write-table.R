#' Write a data frame to a SQLite Database
#'
#' The table must exist.
#'
#' @inheritParams dbCheckDataSQLite
#' @param commit A flag specifying whether to commit the changes.
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log change.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(conn, name, value, commit = TRUE,
                               meta = TRUE, log = TRUE) {
  check_flag(commit)
  check_flag(meta)
  check_flag(log)

  value <- dbCheckDataSQLite(conn, name, value)

  dbBegin(conn, name = "dbWriteTableSQLite")
  on.exit(dbRollback(conn, name = "dbWriteTableSQLite"))

  value <- dbCheckDataSQLite(conn, name, value, convert = TRUE)

  if (nrow(value)) dbAppendTable(conn = conn, name = name, value = value)
  if(!commit) return(invisible(TRUE))

  dbCommit(conn, name = "dbWriteTableSQLite")
  on.exit(NULL)
  invisible(TRUE)
}
