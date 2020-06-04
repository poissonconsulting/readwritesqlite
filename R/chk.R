#' Check SQLite Connection
#'
#' @inheritParams chk::chk_true
#' @param connected A logical scalar specifying whether x should be connected.
#' @return `NULL`, invisibly. Called for the side effect of throwing an error
#'   if the condition is not met.
#'
#' @description
#'
#' `chk_sqlite_conn`
#' checks if a SQLite connection.
#'
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' chk_sqlite_conn(conn)
#' rws_disconnect(conn)
#' try(chk_sqlite_conn(conn, connected = TRUE))
chk_sqlite_conn <- function(x, connected = NA, x_name = NULL) {
  if (vld_sqlite_conn(x, connected)) {
    return(invisible())
  }
  if (is.null(x_name)) x_name <- deparse_backtick_chk(substitute(x))
  chkor(chk_s4_class(x, "SQLiteConnection", x_name = x_name),
        chk_s3_class(x, "Pool", x_name = x_name))
  if (vld_true(connected)) abort_chk(x_name, " must be connected.")
  abort_chk(x_name, " must be disconnected.")
}
