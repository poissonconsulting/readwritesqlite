sys_date_time_utc <- function() {
  date_time <- Sys.time()
  attr(date_time, "tzone") <- "UTC"
  as.character(date_time, format = "%Y-%m-%d %H:%M:%S")
}

user <- function() {
  unname(Sys.info()["user"])
}

table_schema <- function(table_name, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
  schema <- DBI::dbGetQuery(conn, statement = query)[[1]]
  schema
}

table_schemas <- function(conn) {
  tables <- table_names(conn)
  if(!length(tables)) return(empty_named_list())
  names(tables) <- tables
  lapply(tables, table_schema, conn)
}

as_conditional_tibble <- function(x) {
  if(requireNamespace("tibble", quietly = TRUE))
    x <- tibble::as_tibble(x)
  x
}

empty_named_list <- function() {
  list(x = 1)[integer(0)]
}

table_names <- function(conn) {
  tables <- DBI::dbListTables(conn)
  tables <- tables[!tables %in% c("dbWriteSQLiteLog", "dbWriteSQLiteMeta")]
  tables
}

table_names_sorted <- function(conn) {
  schemas <- table_schemas(conn)
  if(!length(schemas)) return(character(0))
  foreign_keys <- lapply(schemas, foreign_key)
  foreign_keys <- foreign_keys[order(foreign_keys)]
  names(foreign_keys)
}

table_name <- function(schema) {
  pattern <- "(^CREATE\\s+TABLE\\s+`?)(\\w+)(`?\\s*.*)"
  name <- sub(pattern, "\\2", schema, ignore.case = TRUE)
  if(identical(name, schema)) return(character(0))
  name
}

table_foreign_keys <- function(schema) {
  pattern <- "REFERENCES\\s+\\w+"
  matches <- gregexpr(pattern, schema, ignore.case = TRUE)
  foreign_keys <- regmatches(schema, matches)[[1]]
  if(length(foreign_keys)) {
    foreign_keys <- sub("(REFERENCES\\s+)(\\w+)", "\\2", foreign_keys)
  }
  foreign_keys
}

foreign_key <- function(schema) {
  foreign_key <- c(table_name(schema), table_foreign_keys(schema))
  class(foreign_key) <- "foreign_key"
  foreign_key
}

`>.foreign_key` <- function(e1, e2) {
  check_inherits(e2, "foreign_key")
  e1[1] %in% e2
}
