#' Write a local data frame or file to the database
#'
#' Functions for writing data frames or delimiter-separated files
#' to database tables.
#'
#' @param conn a \code{\linkS4class{SQLiteConnection}} object, produced by
#'   [DBI::dbConnect()]
#' @param name a character string specifying a table name. SQLite table names
#'   are \emph{not} case sensitive, e.g., table names `ABC` and `abc`
#'   are considered equal.
#' @param check.names If `TRUE`, the default, column names will be
#'   converted to valid R identifiers.
#' @param select.cols  Deprecated, do not use.
#' @param ... Needed for compatibility with generic. Otherwise ignored.
#' @inheritParams DBI::sqlRownamesToColumn
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
setMethod("dbWriteTable", c("SQLiteConnection", "character", "data.frame"),
  function(conn, name, value, ...,
           row.names = pkgconfig::get_config("RSQLite::row.names.table", FALSE),
           overwrite = FALSE, append = FALSE,
           field.types = NULL, temporary = FALSE) {

  RSQLite::dbWriteTable(conn, name, value, ...,
                        row.names = row.names,
           overwrite = overwrite, append = append,
           field.types = field.types, temporary = temporary)
  }
)
