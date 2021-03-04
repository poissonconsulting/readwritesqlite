#' Validate SQLite Connection
#'
#' @inheritParams chk::chk_flag
#' @inheritParams chk_sqlite_conn
#' @return A flag indicating whether the object was validated.
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' vld_sqlite_conn(conn)
#' rws_disconnect(conn)
#' vld_sqlite_conn(conn, connected = TRUE)
vld_sqlite_conn <- function(x, connected = NA) {
  (vld_s4_class(x, "SQLiteConnection") || vld_s3_class(x, "Pool"))  && 
    (is.na(connected) || connected == dbIsValid(x))
}

vld_crs <- function(x){
  result <- suppressWarnings(try(sf::st_crs(x, valid = FALSE), silent = TRUE))
  all(!inherits(result, "try-error"), vld_character(x), vld_scalar(x), !is.na(x))
}