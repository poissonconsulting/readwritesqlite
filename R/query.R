#' Query SQLite Database
#' 
#' Gets a query from a SQLite database.
#' 
#' @param query A string of a SQLite query.
#' @inheritParams rws_write
#' @return A data frame of the query.
#' @aliases rws_query_sqlite
#' @export
#' 
#' @examples 
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_query("SELECT date, posixct, factor FROM rws_data", conn = conn)
#' rws_disconnect(conn)
rws_query <- function(query, meta = TRUE, conn) {
  check_string(query)
  check_flag(meta)
  check_sqlite_connection(conn, connected = TRUE)

  data <- query_data(query, meta, conn)
  as_tibble_sf(data)
}
