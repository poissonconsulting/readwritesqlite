column_names <- function(table_name, conn) {
  DBI::dbListFields(conn, table_name)
}

table_names <- function(conn) {
  tables <- DBI::dbListTables(conn)
  reserved <- to_upper(c(.log_table_name, .meta_table_name))
  tables <- tables[!to_upper(tables) %in% reserved]
  tables
}

tables_exists <- function(table_names, conn) {
  tables <- DBI::dbListTables(conn)
  to_upper(table_names) %in% to_upper(tables)
}

create_table <- function(data, table_name, log, conn) {
  DBI::dbCreateTable(conn, table_name, data)
  if(log) log_command(conn, table_name, command = "CREATE", nrow = 0L)
  data
}

write_data <- function(data, table_name, meta, log, conn) {
  if(meta) data <- write_meta_data(data, table_name = table_name, conn = conn)
  if (nrow(data)) {
    DBI::dbAppendTable(conn, table_name, data)
    if(log) log_command(conn, table_name, command = "INSERT", nrow = nrow(data))
  }
  data
}

delete_data <- function(table_name, meta, log, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
  if(log) log_command(conn, table_name, command = "DELETE", nrow = nrow)
  if(meta) delete_meta_data_table_name(table_name, conn)
}

read_data <- function(table_name, meta, conn) {
  data <- DBI::dbReadTable(conn, table_name)
  if(meta) data <- read_meta_data(data, table_name, conn)
  data
}

table_schema <- function(table_name, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  schema <- DBI::dbGetQuery(conn, statement = query)[[1]]
  schema
}

foreign_keys <- function(conn, on = TRUE) {
  old <- DBI::dbGetQuery(conn, "PRAGMA foreign_keys;")
  old <- as.logical(old[1,1])
  
  if(on && !old)
    DBI::dbExecute(conn, "PRAGMA foreign_keys = ON;")
  if(!on && old)
    DBI::dbExecute(conn, "PRAGMA foreign_keys = OFF;")
  old
}
