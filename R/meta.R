meta_schema <- function () {
  p("CREATE TABLE", .meta_table_name, "(
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT NOT NULL,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);")
}

check_meta_table <- function(conn) {
  meta_schema <- meta_schema()
  if (!tables_exists(.meta_table_name, conn)) {
    dbExecute(conn, meta_schema)
  } else {
    meta_schema <- sub(";$", "", meta_schema)
    schema <- table_schema(.meta_table_name, conn)
    if(!identical(schema, meta_schema))
      err("table '", .meta_table_name, "' has an invalid schema")
  }
}

#' Read Meta Data table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write_sqlite
#' @return A data frame of the meta table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' rws_read_sqlite_meta(con)
#' DBI::dbDisconnect(con)
rws_read_sqlite_meta <- function(conn = getOption("rws.conn", NULL)) {
  check_meta_table(conn)
  data <- dbReadTable(conn, .meta_table_name)
  as_conditional_tibble(data)
}
