read_sqlite_data <- function(table_name, conn, meta) {
  if(toupper(table_name) == toupper("readwritesqlite_meta"))
    err("'readwritesqlite_meta' is a reserved table name")
  
  if(toupper(table_name) == toupper("readwritesqlite_log"))
    err("'readwritesqlite_log' is a reserved table name")

  if (!dbExistsTable(conn, table_name))
    err("table '", table_name, "' does not exist")
  
  data <- DBI::dbReadTable(conn, table_name)
  # need meta processing here
  as_conditional_tibble(data)
}

#' Read from a SQLite Database
#'
#' @param x An object specifying the tables to read.
#' @inheritParams write_sqlite
#' @return A named list of data frames.
#' @family write_sqlite
#' @export
read_sqlite <- function(x, conn = getOption("readwritesqlite.conn", NULL),
                        meta = TRUE, ...) {
  UseMethod("read_sqlite")
}

#' Read from a SQLite Database
#'
#' @inheritParams write_sqlite
#' @return A data frame (tibble if tibble package is installed) of the table.
#' @family dbReadTableSQLite
#' @export
read_sqlite.character <- function(x,
                                  conn = getOption("readwritesqlite.conn", NULL),
                                  meta = TRUE, ...) {
  check_unique(x)
  check_inherits(conn, "SQLiteConnection")
  check_flag(meta)
  check_unused(...)
  
  datas <- lapply(x, read_sqlite_data, meta = meta)
  names(datas) <- x
  datas
}

#' Read from a SQLite Database
#'
#' @inheritParams write_sqlite
#' @return A named list of the data tables.
#' @family dbReadTableSQLite
#' @export
read_sqlite.SQLiteConnection <- function(
  x = getOption("readwritesqlite.conn", NULL), meta = TRUE, ...) {
  check_unused(...)
  tables <- table_names(x)
  if(!length(tables)) return(named_list())
  read_sqlite(tables, conn = x, meta = meta)
}
