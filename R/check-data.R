#' Check and possibly convert a Data Frame
#'
#' Factors are converted to character,
#' raw to character and character to UTF-8 encoding.
#'
#' @param conn A \code{\linkS4class{SQLiteConnection}} object, produced by
#'   [DBI::dbConnect()].
#' @param name A string of the (case insensitive) table name.
#' @param value A data frame of the data to write.
#' @param convert A flag specifying whether to convert data columns.
#' @inheritParams checkr::check_data
#' @return The data frame with the required and converted columns in the correct order.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbCheckDataSQLite <- function(conn, name, value, order = FALSE, exclusive = FALSE,
                                   convert = FALSE) {
  check_inherits(conn, "SQLiteConnection")
  check_string(name)
  check_data(value)
  check_flag(convert)

  if (!dbExistsTable(conn, name))
    err("'", name, "' is not an existing table")

  colnames <- dbListFields(conn, name)

  check_colnames(value, colnames = colnames, order = order, exclusive = exclusive)
  value <- value[colnames]
  if(convert)
    value <- convert_data(value)
  value
}
