local_conn <- function() {
  conn <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
  withr::defer_parent(DBI::dbDisconnect(conn))
  conn
}
