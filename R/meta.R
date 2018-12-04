meta_schema <- function () {
  p("CREATE TABLE", .meta_table_name, "(
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);")
}

update_meta_table <- function(meta_data, conn) {
  meta_data$TableMeta <- to_upper(as.sqlite_name(meta_data$TableMeta))
  meta_data$ColumnMeta <- to_upper(as.sqlite_name(meta_data$ColumnMeta))
  meta_data$TableMeta <- as.character(meta_data$TableMeta)
  meta_data$ColumnMeta <- as.character(meta_data$ColumnMeta)
  
  meta_table <- read_table(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- merge(meta_data, meta_table, all.x = TRUE, 
                      by = c("TableMeta", "ColumnMeta"))
  delete_data(.meta_table_name, log = FALSE, meta = FALSE, conn = conn)
  append_data(meta_table, .meta_table_name, log = FALSE, conn = conn)
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
  table_column_names <- table_column_names(conn)
  colnames(table_column_names) <- c("TableMeta", "ColumnMeta")
  update_meta_table(table_column_names, conn = conn)
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
  data <- read_table(.meta_table_name, meta = FALSE, conn = conn)
  as_conditional_tibble(data)
}

data_column_has_meta <- function(x) {
  is.logical(x) || dttr::is.Date(x) || dttr::is.POSIXct(x) 
}

meta_has_meta <- function(table_name, conn) {
  data <- read_table(table_name, meta = FALSE, conn = conn)
  
  table_name <- as.character(to_upper(as.sqlite_name(table_name)))
  meta_table <- read_table(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta == table_name,,drop = FALSE]
  has_meta <- !is.na(meta_table$MetaMeta)
  if(!nrow(data)) has_meta[!has_meta] <- NA
  names(has_meta) <- meta_table$ColumnMeta
  data_names <- as.character(to_upper(as.sqlite_name(names(data))))
  has_meta <- has_meta[data_names]
  names(has_meta) <- names(data)
  has_meta
}

meta_data <- function(data, table_name, conn) {
  check_meta_table(conn)
  data_has_meta <- vapply(data, FUN = data_column_has_meta, FUN.VALUE = TRUE)
  meta_has_meta <- meta_has_meta(table_name, conn)
  
  data
}

