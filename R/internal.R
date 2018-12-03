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

tables_exists <- function(table_names, conn) {
  tables <- DBI::dbListTables(conn)
  table_names <- to_upper(as.sqlite_name(table_names))
  tables <- to_upper(as.sqlite_name(tables))
  table_names %in% tables
}
