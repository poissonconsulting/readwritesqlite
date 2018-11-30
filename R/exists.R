#' Title
#'
#' @param table_name 
#' @param conn 
#'
#' @return
#' @export
#'
#' @examples
exists_sqlite_table <- function(table_name, conn) {
  tables <- dbListTables(conn)
  table_name <- to_upper(as.sqlite_name(table_name))
  tables <- to_upper(as.sqlite_name(tables))
  table_name %in% tables
}
