write_sqlite_data <- function(data, table_name, exists, delete, meta, 
                              log, conn) {
  if(isFALSE(exists) || (is.na(exists) && !tables_exists(table_name, conn))) 
    create_table(data, table_name, log = log, conn = conn)
  
  if(delete) delete_data(table_name, meta = meta, log = log, conn = conn)
  
  data <- validate_data(data, table_name, conn = conn)
  
  write_data(data, table_name, meta = meta, log = log, conn = conn)
}

#' Write to a SQLite Database
#'
#' @param x The data frame, named list of data frames or environment with data frames to write.
#' @param exists A flag specifying whether the table must already exist.
#' @param delete A flag specifying whether to delete existing rows before 
#' inserting data.
#' @param commit A flag specifying whether to commit the operations 
#' (calling with commit = FALSE can be useful for checking data).
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log the operations alterations.
#' @param conn A \code{\linkS4class{SQLiteConnection}} to a database.
#' @param ... Not used.
#' @return An invisible character vector of the name(s) of the table(s).
#' @family rws_write_sqlite
#' @export
rws_write_sqlite <- function(x, exists = getOption("rws.exists", NA), delete = FALSE, commit = TRUE,
                             meta = TRUE, log = TRUE, 
                             conn = getOption("rws.conn", NULL), ...) {
  UseMethod("rws_write_sqlite")
}

#' @export
rws_write_sqlite.data.frame <- function(
  x, exists = getOption("rws.exists", NA), delete = FALSE, commit = TRUE,
  meta = TRUE, log = TRUE, conn = getOption("rws.conn", NULL), 
  table_name = substitute(x), ...) {
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  check_sqlite_connection(conn, connected = TRUE)
  
  table_name <- chk_deparse(table_name)
  check_string(table_name)
  check_table_name(table_name, exists = exists, conn = conn)
  check_unused(...)
  
  foreign_keys <- foreign_keys(TRUE, conn)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)
  
  write_sqlite_data(x, table_name, exists = exists, 
                    delete = delete, 
                    meta = meta, log = log, conn = conn)
  
  if(!commit) return(invisible(table_name))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  invisible(table_name)
}

#' @export
rws_write_sqlite.list <- function(x,
                                  exists = getOption("rws.exists", NA),
                                  delete = FALSE, commit = TRUE,
                                  meta = TRUE, log = TRUE, 
                                  conn = getOption("rws.conn", NULL), ...) {
  check_named(x)
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  check_sqlite_connection(conn, connected = TRUE)
  check_unused(...)
  
  x <- x[vapply(x, is.data.frame, TRUE)]
  if(!length(x)) {
    wrn("x has no data frames")
    return(invisible(character(0)))
  }
  
  check_table_names(names(x), exists = exists, delete = delete, conn = conn)
  
  foreign_keys <- foreign_keys(FALSE, conn)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)
  
  mapply(write_sqlite_data, x, names(x),
         MoreArgs = list(exists = exists, delete = delete, 
                         meta = meta, log = log, conn = conn), SIMPLIFY = FALSE)
  
  foreign_keys(TRUE, conn)
  if(!commit) return(invisible(names(x)))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  invisible(invisible(names(x)))
}

#' @export
rws_write_sqlite.environment <- function(x,
                                         exists = getOption("rws.exists", NA),
                                         delete = FALSE, commit = TRUE,
                                         meta = TRUE, log = TRUE, 
                                         conn = getOption("rws.conn", NULL), 
                                         ...) {
  x <- as.list(x)
  check_unused(...)
  invisible(
    rws_write_sqlite(x, exists = exists, delete = delete, commit = commit,
                     meta = meta, log = log, conn = conn))
}
