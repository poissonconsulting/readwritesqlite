read_sqlite_data <- function(table_name, conn, meta) {
  data <- DBI::dbReadTable(conn, table_name)
  if(meta) {
    .NotYetImplemented()
  }
  as_conditional_tibble(data)
}

#' Read from a SQLite Database
#'
#' @param x An object specifying the table(s) to read.
#' @inheritParams rws_write_sqlite
#' @return A named list of data frames.
#' @family rws_read_sqlite
#' @export
rws_read_sqlite <- function(x, meta = TRUE, ...) {
  UseMethod("rws_read_sqlite")
}

#' Read from a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @return A data frame (tibble if tibble package is installed) of the table.
#' @family rws_read_sqlite
#' @export
rws_read_sqlite.character <- function(x,
                                  conn = getOption("rws.conn", NULL),
                                  meta = TRUE, ...) {
  check_sqlite_connection(conn, connected = TRUE)
  check_table_names(x, conn)
  check_flag(meta)
  check_unused(...)
  
  datas <- lapply(x, read_sqlite_data, conn = conn, meta = meta)
  names(datas) <- x
  datas
}

#' Read from a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @return A named list of the data tables.
#' @family dbReadTableSQLite
#' @export
rws_read_sqlite.SQLiteConnection <- function(x = getOption("rws.conn", NULL), 
                                         meta = TRUE, ...) {
  check_sqlite_connection(x, connected = TRUE)
  check_flag(meta)
  check_unused(...)
  
  table_names <- table_names(x)
  if(!length(table_names)) return(named_list())
  rws_read_sqlite(table_names, conn = x, meta = meta)
}
