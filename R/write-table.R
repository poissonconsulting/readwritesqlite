#' Write a data frame to a SQLite Database
#'
#' @param conn A \code{\linkS4class{SQLiteConnection}} object, produced by
#'   [DBI::dbConnect()].
#' @param name A string of the (case insensitive) table name.
#' @param ... Errors if used.
#' @param value A data frame of the data to write.
#' @param overwrite A flag specifying whether to overwrite an existing table.
#' @param append A flag specifying whether to append to an existing table.
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log change.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(conn, name, value, ...,
                               overwrite = FALSE, append = FALSE,
                               meta = TRUE, log = TRUE) {
  check_inherits(conn, "SQLite")
  check_string(name)
  check_data(value)
  check_unused(...)
  check_flag(overwrite)
  check_flag(append)
  check_flag(meta)
  check_flag(log)

  dbBegin(conn)
  on.exit(dbRollback(conn))

  dbWriteTable(conn, name, value)
  dbCommit(conn)
  on.exit(NULL)
  invisible(TRUE)
}
