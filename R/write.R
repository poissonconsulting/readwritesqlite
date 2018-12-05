write_sqlite_data <- function(data, table_name, conn, exists, delete, meta, 
                              log) {
  if(isFALSE(exists) || (is.na(exists) && !tables_exists(table_name, conn))) 
    create_table(data, table_name, log = log, conn = conn)
  
  if(delete) delete_data(table_name, meta = meta, log = log, conn = conn)

  data <- validate_data(data, table_name, conn = conn)

  write_data(data, table_name, meta = meta, log = log, conn = conn)
}

#' Write to a SQLite Database
#'
#' @param x The object to write.
#' @param conn A \code{\linkS4class{SQLiteConnection}} to a database.
#' @param exists A flag specifying whether the table must already exist.
#' @param delete A flag specifying whether to delete existing rows before 
#' inserting data.
#' @param commit A flag specifying whether to commit the operations 
#' (calling with commit = FALSE can be useful for checking data).
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log the operations alterations.
#' @param ... Not used.
#' @return An invisible character vector of the name(s) of the table(s).
#' @family rws_write_sqlite
#' @export
rws_write_sqlite <- function(x, conn = getOption("rws.conn", NULL),
                             exists = TRUE, delete = FALSE, commit = TRUE,
                             meta = TRUE, log = TRUE, ...) {
  UseMethod("rws_write_sqlite")
}

#' Write a data frame to a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @param table_name A string of the table name.
#' @family rws_write_sqlite
#' @export
rws_write_sqlite.data.frame <- function(
  x, conn = getOption("rws.conn", NULL), 
  exists = TRUE, delete = FALSE, commit = TRUE,
  meta = TRUE, log = TRUE, table_name = substitute(x), ...) {
  check_sqlite_connection(conn, connected = TRUE)
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  
  table_name <- chk_deparse(table_name)
  check_string(table_name)
  check_table_name(table_name, conn, exists = exists)
  check_unused(...)
  
  foreign_keys <- foreign_keys(conn)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(conn, foreign_keys), add = TRUE)
  
  write_sqlite_data(x, table_name, conn = conn, exists = exists, 
                    delete = delete, 
                    meta = meta, log = log)
  
  if(!commit) return(invisible(table_name))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(conn, foreign_keys)
  invisible(table_name)
}

#' Write a list of data frames to a SQLite Database
#'
#' @param x A named list of data frames.
#' @inheritParams rws_write_sqlite
#' @family rws_write_sqlite
#' @export
rws_write_sqlite.list <- function(x, conn = getOption("rws.conn", NULL),
                                  exists = TRUE,
                                  delete = FALSE, commit = TRUE,
                                  meta = TRUE, log = TRUE, ...) {
  check_named(x)
  check_sqlite_connection(conn, connected = TRUE)
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  check_unused(...)
  
  x <- x[vapply(x, is.data.frame, TRUE)]
  if(!length(x)) {
    wrn("x has no data frames")
    return(invisible(character(0)))
  }
  
  check_table_names(names(x), conn, exists = exists, delete = delete)
  
  foreign_keys <- foreign_keys(conn, FALSE)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(conn, foreign_keys), add = TRUE)
  
  mapply(write_sqlite_data, x, names(x),
         MoreArgs = list(conn = conn, exists = exists, delete = delete, 
                         meta = meta, log = log), SIMPLIFY = FALSE)
  
  foreign_keys(conn, TRUE)
  if(!commit) return(invisible(names(x)))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(conn, foreign_keys)
  invisible(invisible(names(x)))
}
