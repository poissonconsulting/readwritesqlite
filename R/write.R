#' Write a data frame to a SQLite Database
#'
#' The table must exist.
#'
#' @param data A data frame of the data to write.
#' @param table_name A string of the (case insensitive) table name.
#' @param conn A \code{\linkS4class{SQLiteConnection}} object.
#' @param delete A flag specifying whether to delete existing rows before inserting the data.
#' @param commit A flag specifying whether to commit the changes (useful for checking data).
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log data manipulations.
#' @return The updated data frame with the same columns as the table.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(data, table_name = substitute(data),
                               conn = getOption("dbWriteSQLite.conn", NULL),
                               delete = FALSE, commit = TRUE,
                               meta = TRUE, log = TRUE) {

  table_name <- chk_deparse(table_name)
  data <- check_data_sqlite(data, table_name, conn)

  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)

  dbBegin(conn, name = "dbWriteTableSQLite")
  on.exit(dbRollback(conn, name = "dbWriteTableSQLite"))

  data2 <- check_data_sqlite(data, table_name, conn, convert = TRUE)

  if(delete) {
    sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
    query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
    nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
    if(log) {
      log_command(conn, table_name, command = "DELETE",
               nrow = nrow)
    }
  }
  if (nrow(data)) {
    dbAppendTable(conn, table_name, data2)
    if(log) {
      log_command(conn, table_name, command = "INSERT", nrow = nrow(data2))
    }
  }
  if(!commit) return(invisible(data))

  dbCommit(conn, name = "dbWriteTableSQLite")
  on.exit(NULL)
  invisible(data)
}
