


table_schemas <- function(conn) {
  tables <- table_names(conn)
  if(!length(tables)) return(named_list())
  names(tables) <- tables
  lapply(tables, table_schema, conn)
}

table_names_hierarchical <- function(conn) {
  schemas <- table_schemas(conn)
  if(!length(schemas)) return(character(0))
  foreign_keys <- lapply(schemas, schema_foreign_key)
  print(foreign_keys)
  foreign_keys <- foreign_keys[order(foreign_keys)]
  names(foreign_keys)
}

schema_table_name <- function(schema) {
  pattern <- "(^CREATE\\s+TABLE\\s+`?)(\\w+)(`?\\s*.*)"
  name <- sub(pattern, "\\2", schema, ignore.case = TRUE)
  if(identical(name, schema)) return(character(0))
  name
}

schema_references <- function(schema) {
  pattern <- "REFERENCES\\s+\\w+"
  matches <- gregexpr(pattern, schema, ignore.case = TRUE)
  foreign_keys <- regmatches(schema, matches)[[1]]
  if(length(foreign_keys)) {
    foreign_keys <- sub("(REFERENCES\\s+)(\\w+)", "\\2", foreign_keys)
  }
  foreign_keys
}

schema_foreign_key <- function(schema) {
  foreign_key <- list(name = schema_table_name(schema),
                      references = schema_references(schema))
  class(foreign_key) <- "foreign_key"
  foreign_key
}

`>.foreign_key` <- function(e1, e2) {
  check_inherits(e2, "foreign_key")
  e1[1] %in% e2
}