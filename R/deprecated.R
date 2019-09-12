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

is_string <- function (x) (is.character(x) || is.factor(x)) && length(x) == 1 && !is.na(x)

chk_deparse <- function (x) {
    if (!is.character(x)) 
        x <- deparse(x)
    if (isTRUE(is.na(x))) 
        x <- "NA"
    if (!is_string(x)) 
        err(substitute(x), " must be a string")
    x
}

chk_fail <- function (..., error) {
    if (missing(error) || isTRUE(error)) 
        err(...)
    wrn(...)
}

#' @describeIn chk_sqlite_conn Check SQLite Connection
#'
#' @export
check_sqlite_connection <- function(x, connected = NA, x_name = substitute(x), error = TRUE) {
  .Deprecated("chk_sqlite_conn")

  x_name <- chk_deparse(x_name)
  chk_lgl(connected)
  chk_flag(error)
  chk_s3_class(x, "SQLiteConnection", x_name = x_name)
  if(isTRUE(connected) && !dbIsValid(x)) {
    chk_fail(x_name, " must be connected", error = error)
  } else if(isFALSE(connected) && dbIsValid(x))
    chk_fail(x_name, " must be disconnected", error = error)
  invisible(x)
}
