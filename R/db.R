column_names <- function(table_name, conn) {
  DBI::dbListFields(conn, table_name)
}

tables_exists <- function(table_names, conn) {
  tables <- DBI::dbListTables(conn)
  to_upper(table_names) %in% to_upper(tables)
}

nrows_table <- function(table_name, conn) {
  nrows <- DBI::dbGetQuery(conn, p0("SELECT COUNT(*) FROM ", table_name, ";"))
  nrows <- nrows[1,1]
  nrows
}

create_table <- function(data, table_name, silent, conn) {
  if(!isFALSE(silent)) msg("creating table '", table_name, "'")
  DBI::dbCreateTable(conn, table_name, data)
  log_command(table_name, command = "CREATE", nrow = 0L, conn = conn)
  data
}

write_data <- function(data, table_name, conn) {
  sf_column_name <- sf_column_name(data)
  data <- write_meta_data(data, table_name = table_name, conn = conn)
  write_init_data(table_name, sf_column_name, conn = conn)
  if (nrow(data)) {
    data <- as.data.frame(data)
    DBI::dbAppendTable(conn, table_name, data)
    log_command(table_name, command = "INSERT", nrow = nrow(data), conn = conn)
  }
  data
}

delete_data <- function(table_name, meta, log, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
  if(log) {
    log_command(table_name, command = "DELETE", nrow = nrow, conn = conn)
  }
  if(meta) {
    delete_init_data_table_name(table_name, conn)
    delete_meta_data_table_name(table_name, conn)
  }
}

read_data <- function(table_name, meta, conn) {
  data <- DBI::dbReadTable(conn, table_name)
  colnames(data) <- column_names(table_name, conn)
  if(meta) {
    data <- read_meta_data(data, table_name, conn)
    data <- read_init_data(data, table_name, conn)
  }
  data
}

table_schema <- function(table_name, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  schema <- DBI::dbGetQuery(conn, statement = query)[[1]]
  schema
}

table_info <- function(table_name, conn) {
  query <- p0("PRAGMA table_info('", table_name, "');")
  table_info <- DBI::dbGetQuery(conn, query)
  table_info
}

table_column_type <- function(column_name, table_name, conn) {
  table_info <- table_info(table_name, conn)
  table_info$type[to_upper(table_info$name) == to_upper(column_name)]
}

is_table_column_text <- function(column_name, table_name, conn) {
  table_column_type(column_name, table_name, conn) == "TEXT"
}

foreign_keys <- function(on, conn) {
  old <- DBI::dbGetQuery(conn, "PRAGMA foreign_keys;")
  old <- as.logical(old[1,1])
  
  if(on && !old)
    DBI::dbExecute(conn, "PRAGMA foreign_keys = ON;")
  if(!on && old)
    DBI::dbExecute(conn, "PRAGMA foreign_keys = OFF;")
  old
}

defer_foreign_keys <- function(on, conn) {
  old <- DBI::dbGetQuery(conn, "PRAGMA defer_foreign_keys;")
  old <- as.logical(old[1,1])
  
  if(on && !old)
    DBI::dbExecute(conn, "PRAGMA defer_foreign_keys = ON;")
  if(!on && old)
    DBI::dbExecute(conn, "PRAGMA defer_foreign_keys = OFF;")
  old
}
