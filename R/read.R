read_sqlite_data <- function(table_name, meta, conn) {
  data <- read_data(table_name, meta = meta, conn = conn)
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

#' Read Tables from a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @param x A character vector of table names.
#' @return A named list of the data frames.
#' @family rws_read_sqlite
#' @export
rws_read_sqlite.character <- function(x, meta = TRUE,
                                      conn = getOption("rws.conn", NULL),
                                      ...) {
  check_sqlite_connection(conn, connected = TRUE)
  check_table_names(x, exists = TRUE, delete = FALSE, complete = FALSE, conn = conn)
  check_flag(meta)
  check_unused(...)
  
  datas <- lapply(x, read_sqlite_data, meta = meta, conn = conn)
  names(datas) <- x
  datas
}

#' Read All Tables from a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @param x A \code{\linkS4class{SQLiteConnection}} to a database.
#' @return A named list of the data frames.
#' @family rws_read_sqlite
#' @export
rws_read_sqlite.SQLiteConnection <- function(x, meta = TRUE, ...) {
  check_sqlite_connection(x, connected = TRUE)
  check_flag(meta)
  check_unused(...)
  
  table_names <- rws_list_tables(x)
  if(!length(table_names)) return(named_list())
  rws_read_sqlite(table_names, meta = meta, conn = x)
}

#' Read A Tables from a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @param x A string of the table name.
#' @return A data frame of the table.
#' @export
rws_read_sqlite_table <- function(x, meta = TRUE, 
                                  conn = getOption("rws.conn", NULL)) {
  rws_read_sqlite(x, meta = meta, conn = conn)[[1]]
}
