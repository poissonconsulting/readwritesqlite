#' Read a Table from a SQLite Database
#'
#' @param table_name A string of the (case insensitive) table name.
#' @param conn A \code{\linkS4class{SQLiteConnection}} object.
#' @param meta A flag specifying whether to preserve meta data.
#' @return The updated data frame with the same columns as the table.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbReadTableSQLite <- function(table_name,
                              conn = getOption("dbWriteSQLite.conn", NULL),
                              meta = TRUE) {
  check_string(table_name)
  check_inherits(conn, "SQLiteConnection")
  check_flag(meta)

  if (!dbExistsTable(conn, table_name))
    err("table '", table_name, "' does not exist")

  data <- DBI::dbReadTable(conn, table_name)
  as_conditional_tibble(data)
}
