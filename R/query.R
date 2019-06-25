#' Query SQLite Database
#' 
#' Gets a query from a SQLite database.
#' 
#' @param query A string of a SQLite query.
#' @inheritParams rws_write
#' @return A data frame of the query.
#' @aliases rws_query_sqlite
#' @export
rws_query <- function(query, meta = TRUE, conn) {
  check_string(query)
  check_flag(meta)
  check_sqlite_connection(conn, connected = TRUE)

  data <- query_data(query, meta, conn)
  as_tibble_sf(data)
}
