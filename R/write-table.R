#' Write a data frame to a SQLite Database
#'
#' The table must exist.
#'
#' @inheritParams dbCheckDataSQLite
#' @param delete A flag specifying whether to delete existing rows before inserting the data.
#' @param commit A flag specifying whether to commit the changes.
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log data manipulations.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(conn, table_name, data, commit = TRUE, delete = FALSE,
                               meta = TRUE, log = TRUE) {
  check_flag(commit)
  check_flag(delete)
  check_flag(meta)
  check_flag(log)

  data <- dbCheckDataSQLite(conn, table_name, data)

  dbBegin(conn, name = "dbWriteTableSQLite")
  on.exit(dbRollback(conn, name = "dbWriteTableSQLite"))

  data <- dbCheckDataSQLite(conn, table_name, data, convert = TRUE)

  if(delete) {
    nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
    if(log) {
      log_data(conn, table_name, command = "DELETE",
               nrow = dbGetRowsAffected(nrow))
    }
  }
  if (nrow(data)) {
    dbAppendTable(conn, table_name, data)
    if(log) {
      log_data(conn, table_name, command = "INSERT", nrow = nrow(data))
    }
  }
  if(!commit) return(invisible(TRUE))

  dbCommit(conn, name = "dbWriteTableSQLite")
  on.exit(NULL)
  invisible(TRUE)
}
