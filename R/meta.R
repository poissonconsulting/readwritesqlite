meta_schema <- function () {
  "CREATE TABLE readwritesqlite_meta (
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT NOT NULL,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);"
}

check_meta_table <- function(conn) {
  meta_schema <- meta_schema()
  if (!dbExistsTable(conn, "readwritesqlite_meta")) {
    dbExecute(conn, meta_schema)
  } else {
    meta_schema <- sub(";$", "", meta_schema)
    schema <- table_schema("readwritesqlite_meta", conn)
    if(!identical(schema, meta_schema))
      err("table 'readwritesqlite_meta' has an invalid schema")
  }
}

#' Read Meta Data table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams write_sqlite
#' @return A data frame of the readwritesqlite_meta table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' dbReadMetaTableSQLite(con)
#' DBI::dbDisconnect(con)
read_sqlite_meta <- function(conn = getOption("readwritesqlite.conn", NULL)) {
  check_meta_table(conn)
  data <- dbReadTable(conn, "readwritesqlite_meta")
  as_conditional_tibble(data)
}
