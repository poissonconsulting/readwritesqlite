delete_data <- function(table_name, log, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
  if(log) {
    log_command(conn, table_name, command = "DELETE", nrow = nrow)
  }
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

sys_date_time_utc <- function() {
  date_time <- Sys.time()
  attr(date_time, "tzone") <- "UTC"
  as.character(date_time, format = "%Y-%m-%d %H:%M:%S")
}

user <- function() {
  unname(Sys.info()["user"])
}

set_class <- function(x, value) {
  class(x) <- value
  x
}

as_conditional_tibble <- function(x) {
  if(requireNamespace("tibble", quietly = TRUE))
    x <- tibble::as_tibble(x)
  x
}

named_list <- function() {
  list(x = 1)[integer(0)]
}

table_names <- function(conn) {
  tables <- DBI::dbListTables(conn)
  tables <- tables[!tables %in% c(.log_table_name, .meta_table_name)]
  tables
}

column_names <- function(table_name, conn) {
  DBI::dbListFields(conn, table_name)
}

create_table <- function(data, table_name, log, conn) {
  DBI::dbCreateTable(conn, table_name, data)
  if(log) log_command(conn, table_name, command = "CREATE", nrow = 0L)
  data
}

append_data <- function(data, table_name, log, conn) {
  if (nrow(data)) {
    dbAppendTable(conn, table_name, data)
    if(log) {
      log_command(conn, table_name, command = "INSERT", nrow = nrow(data))
    }
    data
  }
}

read_table <- function(table_name, meta, conn) {
  data <- DBI::dbReadTable(conn, table_name)
  # need some meta processing here 
  data
}

check_data_rws <- function(data, table_name, conn) {
  colnames <- column_names(table_name, conn = conn)
  check_colnames(data, colnames = colnames)
  data <- data[colnames]
  # need to add more data checking here
  
  data <- convert_data(data)
  data
}

table_column_names <- function(conn) {
  table_names <- table_names(conn)
  if(!length(table_names)) 
    return(data.frame(Table = character(0), Column = character(0), 
                      stringsAsFactors = FALSE))
  table_column_names <- lapply(table_names, column_names, conn = conn)
  table_column_names <- mapply(function(x, y) 
    data.frame(Table = y, Column = x, stringsAsFactors = FALSE), 
    table_column_names, table_names, SIMPLIFY = FALSE)
  table_column_names$stringsAsFactors <- FALSE
  do.call("rbind", table_column_names)
}

tables_exists <- function(table_names, conn) {
  tables <- DBI::dbListTables(conn)
  table_names <- to_upper(as.sqlite_name(table_names))
  tables <- to_upper(as.sqlite_name(tables))
  table_names %in% tables
}

table_schema <- function(table_name, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  schema <- DBI::dbGetQuery(conn, statement = query)[[1]]
  schema
}
