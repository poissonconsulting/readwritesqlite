#' @export
rws_query_sqlite <- function(query, meta = TRUE, conn) {
.Deprecated("rws_query")
  rws_query(query, meta = meta, conn = conn)
}

#' @export
rws_open_connection <- function(dbname = "", exists = NA) {
  .Deprecated("rws_connect")
  rws_connect(dbname = dbname, exists = exists)
}

#' @export
rws_close_connection <- function(conn) {
  .Deprecated("rws_disconnect")
  rws_disconnect(conn)
}

#' @export
rws_write_sqlite <- function(x, exists = TRUE, delete = FALSE, 
                             replace = FALSE,
                             meta = TRUE,
                             log = TRUE,
                             commit = TRUE,
                             strict = TRUE,
                             x_name = substitute(x), 
                             silent = getOption("rws.silent", FALSE),
                             conn, 
                             ...) {
  .Deprecated("rws_write")
  UseMethod("rws_write")
}

#' @export
rws_read_sqlite_log <- function(conn) {
  .Deprecated("rws_read_log")
  rws_read_log(conn)
}

#' @export
rws_read_sqlite_init <- function(conn) {
  .Deprecated("rws_read_init")
  rws_read_init(conn)
}

#' @export
rws_read_sqlite_meta <- function(conn) {
  .Deprecated("rws_read_meta")
  rws_read_meta(conn)
}

#' @export
rws_read_sqlite <- function(x, ...) {
  .Deprecated("rws_read")
  UseMethod("rws_read")
}

#' @export
rws_read_sqlite_table <- function(x, meta = TRUE, conn) {
  .Deprecated("rws_read_table")
  rws_read_table(x, meta = meta, conn = conn)
}
