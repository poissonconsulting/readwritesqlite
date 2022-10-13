#' Opens SQLite Database Connection
#'
#' Opens a [SQLiteConnection-class] to a SQLite database with
#' foreign key constraints enabled.
#'
#' @inheritParams RSQLite::SQLite
#' @param exists A flag specifying whether the table(s) must already exist.
#' @return A [SQLiteConnection-class] to a SQLite database with
#' foreign key constraints enabled.
#' @aliases rws_open_connection
#' @seealso [rws_disconnect()]
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' print(conn)
#' rws_disconnect(conn)
rws_connect <- function(dbname = ":memory:", exists = NA) {
  chk_string(dbname)
  chk_lgl(exists)

  if (vld_true(exists) && !file.exists(dbname)) {
    err("File '", dbname, "' must already exist.")
  }

  if (vld_false(exists) && file.exists(dbname)) {
    err("File '", dbname, "' must not already exist.")
  }

  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = dbname)
  execute("PRAGMA foreign_keys = ON;", conn)
  conn
}

#' Close SQLite Database Connection
#'
#' Closes a [SQLiteConnection-class] to a SQLite database.
#'
#' @param conn An `RSQLite::SQLiteConnection()`.
#' @aliases rws_close_connection
#' @seealso [rws_connect()]
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_disconnect(conn)
#' print(conn)
rws_disconnect <- function(conn) {
  chk_sqlite_conn(conn)
  DBI::dbDisconnect(conn)
}
