#' Opens SQLite Database Connection
#'
#' Opens a \code{\linkS4class{SQLiteConnection}} to a SQLite database with
#' foreign key constraints enabled.
#'
#' @inheritParams RSQLite::SQLite
#' @export
rws_open_connection <- function(dbname = "") {
  check_string(dbname)
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = dbname)
  DBI::dbGetQuery(conn, "PRAGMA foreign_keys = ON;")
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
