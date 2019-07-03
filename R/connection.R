#' Opens SQLite Database Connection
#'
#' Opens a \code{\linkS4class{SQLiteConnection}} to a SQLite database with
#' foreign key constraints enabled.
#'
#' @inheritParams RSQLite::SQLite
#' @param exists A flag specifying whether the table(s) must already exist.
#' @return A \code{\linkS4class{SQLiteConnection}} to a SQLite database with
#' foreign key constraints enabled.
#' @aliases rws_open_connection
#' @seealso \code{\link{rws_disconnect}()}
#' @export
#' 
#' @examples 
#' conn <- rws_connect()
#' print(conn)
#' rws_disconnect(conn)
rws_connect <- function(dbname = ":memory:", exists = NA) {
  check_string(dbname)
  check_scalar(exists, c(TRUE, NA))
  
  if(isTRUE(exists) && !file.exists(dbname))
    err("File '", dbname,"' must already exist.")

  if(isFALSE(exists) && file.exists(dbname))
    err("File '", dbname,"' must not already exist.")
  
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = dbname)
  execute("PRAGMA foreign_keys = ON;", conn)
  conn
}

#' Close SQLite Database Connection
#'
#' Closes a \code{\linkS4class{SQLiteConnection}} to a SQLite database.
#'
#' @inheritParams RSQLite::SQLite
#' @aliases rws_close_connection
#' @seealso \code{\link{rws_connect}()}
#' @export
#' 
#' @examples 
#' conn <- rws_connect()
#' rws_disconnect(conn)
#' print(conn)
rws_disconnect <- function(conn) {
  check_sqlite_connection(conn)
  DBI::dbDisconnect(conn)
}
