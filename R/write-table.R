#' Write a data frame to a SQLite Database
#'
#' @param conn A \code{\linkS4class{SQLiteConnection}} object, produced by
#'   [DBI::dbConnect()].
#' @param name A string of the (case insensitive) table name.
#' @param ... Errors if used.
#' @param value A data frame of the data to write.
#' @param overwrite A flag specifying whether to overwrite an existing table.
#' @param append A flag specifying whether to append to an existing table.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(conn, name, value, ...,
                               overwrite = FALSE, append = FALSE) {
  check_inherits(conn, "SQLite")
  check_string(name)
  check_data(value)
  check_unused(...)
  check_flag(overwrite)
  check_flag(append)
  dbWriteTable(conn, name, value)
}
