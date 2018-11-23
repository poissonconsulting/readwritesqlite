meta_schema <- function () {
  "CREATE TABLE dbWriteSQLiteMeta (
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT NOT NULL,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);"
}

check_meta_table <- function(conn) {
  meta_schema <- meta_schema()
  if (!dbExistsTable(conn, "dbWriteSQLiteMeta")) {
    dbExecute(conn, meta_schema)
  } else {
    meta_schema <- sub(";$", "", meta_schema)
    schema <- table_schema("dbWriteSQLiteMeta", conn)
    if(!identical(schema, meta_schema))
      err("dbWriteSQLiteMeta Table has an invalid schema")
  }
}

#' Read dbWriteSQLiteMeta Table
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams dbWriteTableSQLite
#' @return A data frame of the dbWriteSQLiteMeta table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' dbReadMetaTableSQLite(con)
#' DBI::dbDisconnect(con)
dbReadMetaTableSQLite <- function(conn = getOption("dbWriteSQLite.conn", NULL)) {
  check_meta_table(conn)
  data <- dbReadTable(conn, "dbWriteSQLiteMeta")
  as_conditional_tibble(data)
}
