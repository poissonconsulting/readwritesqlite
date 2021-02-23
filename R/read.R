read_sqlite_data <- function(table_name, meta = meta, conn) {
  data <- read_data(table_name, meta = meta, conn = conn)
  as_tibble_sf(data)
}

#' Read from a SQLite Database
#'
#' @param x An object specifying the table(s) to read.
#' @inheritParams rws_write
#' @return A named list of data frames.
#' @aliases rws_read_sqlite
#' @family rws_read
#' @export
rws_read <- function(x, ...) {
  UseMethod("rws_read")
}

#' Read Tables from a SQLite Database
#'
#' @inheritParams rws_write
#' @param x A character vector of table names.
#' @return A named list of the data frames.
#' @family rws_read
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_write(rws_data[c("date", "ordered")],
#'   x_name = "data2",
#'   exists = FALSE, conn = conn
#' )
#' rws_read(c("rws_data", "data2"), conn = conn)
#' rws_disconnect(conn)
rws_read.character <- function(x, meta = TRUE, conn,
                               ...) {
  chk_sqlite_conn(conn, connected = TRUE)
  check_table_names(x, exists = TRUE, delete = FALSE, all = FALSE, unique = TRUE, conn = conn)
  chk_unused(...)

  datas <- lapply(x, read_sqlite_data, meta = meta, conn = conn)
  names(datas) <- x
  datas
}

#' Read All Tables from a SQLite Database
#'
#' @inheritParams rws_write
#' @param x A [SQLiteConnection-class] to a database.
#' @return A named list of the data frames.
#' @family rws_read
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_write(rws_data[c("date", "ordered")],
#'   x_name = "data2", exists = FALSE, conn = conn
#' )
#' rws_read(conn)
#' rws_disconnect(conn)
rws_read.SQLiteConnection <- function(x, meta = TRUE, ...) {
  chk_sqlite_conn(x, connected = TRUE)
  chk_unused(...)

  table_names <- rws_list_tables(x)
  if (!length(table_names)) {
    return(named_list())
  }
  rws_read(table_names, meta = meta, conn = x)
}

#' Read a Table from a SQLite Database
#'
#' @inheritParams rws_write
#' @param x A string of the table name.
#' @return A data frame of the table.
#' @aliases rws_read_sqlite_table
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_write(rws_data[c("date", "ordered")],
#'   x_name = "data2", exists = FALSE, conn = conn
#' )
#' rws_read_table("data2", conn = conn)
#' rws_disconnect(conn)
rws_read_table <- function(x, meta = TRUE, conn) {
  chk_string(x)
  rws_read(x, meta = meta, conn = conn)[[1]]
}
