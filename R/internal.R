sys_date_time_utc <- function() {
  date_time <- Sys.time()
  attr(date_time, "tzone") <- "UTC"
  as.character(date_time, format = "%Y-%m-%d %H:%M:%S")
}

user <- function() {
  unname(Sys.info()["user"])
}

table_schema <- function(conn, table_name) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  schema <- DBI::dbGetQuery(conn, statement = query)[[1]]
  schema
}

as_conditional_tibble <- function(x) {
  if(requireNamespace("tibble", quietly = TRUE))
    x <- tibble::as_tibble(x)
  x
}
