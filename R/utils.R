#' Table Names
#' 
#' Gets the table names excluding the names of the meta and log tables.
#'
#' @inheritParams rws_write
#'
#' @return A character vector of table names.
#' @export
#' 
#' @examples
#' conn <- rws_connect()
#' rws_list_tables(conn)
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_list_tables <- function(conn) {
  check_sqlite_connection(conn, connected = TRUE)
  tables <- DBI::dbListTables(conn)
  tables <- tables[!to_upper(tables) %in% to_upper(reserved_tables())]
  sort(tables)
}