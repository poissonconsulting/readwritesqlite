#' Check (and Convert) Data
#'
#' Factors are converted to character,
#' raw to character and character to UTF-8 encoding.
#'
#' @param conn A \code{\linkS4class{SQLiteConnection}} object, produced by
#'   [DBI::dbConnect()].
#' @param table_name A string of the (case insensitive) table name.
#' @param data A data frame of the data to write.
#' @param convert A flag specifying whether to convert data columns.
#' @return The data frame with the required and converted columns in the correct order.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbCheckDataSQLite <- function(conn, table_name, data, convert = FALSE) {
  check_inherits(conn, "SQLiteConnection")
  check_string(table_name)
  check_data(data)
  check_flag(convert)

  if(table_name %in% c("dbWriteSQLiteLog"))
    err("'dbWriteSQLiteLog' is a reserved table name")

  if (!dbExistsTable(conn, table_name))
    err("'", table_name, "' is not an existing table")

  colnames <- dbListFields(conn, table_name)

  check_colnames(data, colnames = colnames)
  data <- data[colnames]
  if(convert) {
    data <- as.data.frame(data)
    data <- convert_data(data)
  }
  data
}
