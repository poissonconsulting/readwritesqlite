#' Query SQLite Database
#' 
#' Gets a query from a SQLite database.
#' 
#' @param query A string of a SQLite query.
#' @inheritParams rws_write_sqlite
#' @return A data frame of the query.
#' @export
rws_query_sqlite <- function(query, meta = TRUE, conn) {
  check_string(query)
  check_flag(meta)
  check_sqlite_connection(conn, connected = TRUE)

  data <- DBI::dbGetQuery(conn, query)
  if(!meta) return(data)
  .NotYetImplemented()
}
