#' Table Names
#' 
#' Gets the table names excluding the names of the meta and log tables.
#'
#' @inheritParams rws_write_sqlite
#'
#' @return A character vector of table names.
#' @export
rws_list_tables <- function(conn) {
  check_sqlite_connection(conn, connected = TRUE)
  tables <- DBI::dbListTables(conn)
  reserved <- reserved_tables()
  tables <- tables[!to_upper(tables) %in% to_upper(reserved)]
  sort(tables)
}