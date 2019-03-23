#' Opens SQLite Database Connection
#'
#' Opens a \code{\linkS4class{SQLiteConnection}} to a SQLite database with
#' foreign key constraints enabled.
#'
#' @inheritParams RSQLite::SQLite
#' @param exists A flag specifying whether the table(s) must already exist.
#' @export
rws_open_connection <- function(dbname = "", exists = NA) {
  check_string(dbname)
  check_scalar(exists, c(TRUE, NA))
  
  if(isTRUE(exists) && !file.exists(dbname))
    err("File '", dbname,"' must already exist.")

  if(isFALSE(exists) && file.exists(dbname))
    err("File '", dbname,"' must not already exist.")
  
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = dbname)
  get_query("PRAGMA foreign_keys = ON;", conn)
  conn
}

#' Close SQLite Database Connection
#'
#' Closes a \code{\linkS4class{SQLiteConnection}} to a SQLite database.
#'
#' @inheritParams RSQLite::SQLite
#' @export
rws_close_connection <- function(conn) {
  check_sqlite_connection(conn)
  DBI::dbDisconnect(conn)
}
