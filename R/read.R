#' Read a Table from a SQLite Database
#'
#' @inheritParams dbWriteTableSQLite
#' @return A data frame (tibble if tibble package is installed) of the table.
#' @family dbReadTableSQLite
#' @export
dbReadTableSQLite <- function(table_name,
                              conn = getOption("dbWriteSQLite.conn", NULL),
                              meta = TRUE) {
  check_string(table_name)
  check_inherits(conn, "SQLiteConnection")
  check_flag(meta)

  if (!dbExistsTable(conn, table_name))
    err("table '", table_name, "' does not exist")

  data <- DBI::dbReadTable(conn, table_name)
  as_conditional_tibble(data)
}

#' Read Tables from a SQLite Database
#'
#' @inheritParams dbWriteTableSQLite
#' @return A list of the tables.
#' @family dbReadTableSQLite
#' @export
dbReadTablesSQLite <- function(conn = getOption("dbWriteSQLite.conn", NULL),
                               meta = TRUE) {
  check_inherits(conn, "SQLiteConnection")
  tables <- DBI::dbListTables(conn)
  tables <- tables[!tables %in% c("dbWriteSQLiteLog", "dbWriteSQLiteMeta")]
  if(!length(tables)) return(empty_named_list())
  names(tables) <- tables
  lapply(tables, dbReadTableSQLite, conn = conn, meta = meta)
}
