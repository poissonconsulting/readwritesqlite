write_sqlite_data <- function(data, table_name, exists, delete, meta, 
                              log, silent, conn) {
  data <- as.data.frame(data) # otherwise sf objects can cause problems
  if(isFALSE(exists) || (is.na(exists) && !tables_exists(table_name, conn))) {
    create_table(data, table_name, log = log, silent = silent, conn = conn)
  }
  
  if(delete) delete_data(table_name, meta = meta, log = log, conn = conn)
  
  data <- validate_data(data, table_name, silent = silent, conn = conn)
  
  write_data(data, table_name, meta = meta, log = log, conn = conn)
}

#' Write to a SQLite Database
#'
#' @param x The object to write.
#' @param exists A flag specifying whether the table must already exist.
#' @param delete A flag specifying whether to delete existing rows before 
#' inserting data.
#' @param commit A flag specifying whether to commit the operations 
#' (calling with commit = FALSE can be useful for checking data).
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log the operations alterations.
#' @param conn A \code{\linkS4class{SQLiteConnection}} to a database.
#' @param x_name A string of the name of the object.
#' @param silent A flag specifying whether suppress messages and warnings.
#' @param ... Not used.
#' @return An invisible character vector of the name(s) of the table(s).
#' @family rws_write_sqlite
#' @export
rws_write_sqlite <- function(x, exists = getOption("rws.exists", NA), delete = FALSE, commit = TRUE,
                             meta = TRUE, log = TRUE, 
                             conn = getOption("rws.conn", NULL), 
                             x_name = substitute(x), 
                             silent = getOption("rws.silent", FALSE), ...) {
  UseMethod("rws_write_sqlite")
}

#' Write a Data Frame to a SQLite Database
#'
#' @param x A data frame.
#' @inheritParams rws_write_sqlite
#' @family rws_write_sqlite
#' @export
rws_write_sqlite.data.frame <- function(
  x, exists = getOption("rws.exists", NA), delete = FALSE, commit = TRUE,
  meta = TRUE, log = TRUE, conn = getOption("rws.conn", NULL), 
  x_name = substitute(x), silent = getOption("rws.silent", FALSE), ...) {
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  check_sqlite_connection(conn, connected = TRUE)
  
  x_name <- chk_deparse(x_name)
  check_string(x_name)
  check_table_name(x_name, exists = exists, conn = conn)
  check_flag(silent)
  check_unused(...)
  
  foreign_keys <- foreign_keys(TRUE, conn)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)
  
  write_sqlite_data(x, table_name = x_name, exists = exists, 
                    delete = delete, 
                    meta = meta, log = log, silent = silent, conn = conn)
  
  if(!commit) return(invisible(x_name))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  invisible(x_name)
}

#' Write a Named List of Data Frames to a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @param x A named list of data frames.
#' @param complete A flag specifying whether all the tables in the data base must be represented.
#' If complete = TRUE and exists = TRUE then extra tables are ignored (with a warning).
#' @family rws_write_sqlite
#' @export
rws_write_sqlite.list <- function(x,
                                  exists = getOption("rws.exists", NA),
                                  delete = FALSE, commit = TRUE,
                                  meta = TRUE, log = TRUE, 
                                  conn = getOption("rws.conn", NULL), 
                                  x_name = substitute(x), 
                                  silent = getOption("rws.silent", FALSE),
                                  complete = FALSE, ...) {
  check_named(x)
  check_scalar(exists, c(TRUE, NA))
  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)
  check_sqlite_connection(conn, connected = TRUE)
  x_name <- chk_deparse(x_name)
  check_string(x_name)
  check_flag(silent)
  check_flag(complete)
  check_unused(...)
  
  if(!length(x)) return(character(0))
  
  if(!all(vapply(x, is.data.frame, TRUE)))
    err("list '", x_name, "' includes objects which are not data frames")
  
  if(complete && isTRUE(exists)) {
    exists <- tables_exists(names(x), conn)
    if(any(!exists)) {
      extra <- names(x)[!exists]
      if(isFALSE(silent)) {
        wrn(co(extra, "the following data frame%s %r ignored because exists = TRUE and complete = TRUE: %c",
               conjunction = "and"))
      }
      x <- x[exists]
      if(!length(x)) return(invisible(character(0)))
    }
  }
  
  check_table_names(names(x), exists = exists, delete = delete, complete = complete, conn = conn)
  
  foreign_keys <- foreign_keys(TRUE, conn)
  defer <- defer_foreign_keys(TRUE, conn)
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)
  on.exit(defer_foreign_keys(defer, conn), add = TRUE)
  
  mapply(write_sqlite_data, x, names(x),
         MoreArgs = list(exists = exists, delete = delete, 
                         meta = meta, log = log, silent = silent, conn = conn), SIMPLIFY = FALSE)
  
  if(!commit) return(invisible(names(x)))
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  defer_foreign_keys(defer, conn)
  invisible(invisible(names(x)))
}

#' Write the Data Frames in an Environment to a SQLite Database
#'
#' @inheritParams rws_write_sqlite
#' @inheritParams rws_write_sqlite.list
#' @param x An environment.
#' @family rws_write_sqlite
#' @export
rws_write_sqlite.environment <- function(x,
                                         exists = getOption("rws.exists", NA),
                                         delete = FALSE, commit = TRUE,
                                         meta = TRUE, log = TRUE, 
                                         conn = getOption("rws.conn", NULL), 
                                         x_name = substitute(x),
                                         silent = getOption("rws.silent", FALSE),
                                         complete = FALSE, ...) {
  x_name <- chk_deparse(x_name)
  check_string(x_name)
  check_flag(silent)
  check_unused(...)
  x <- as.list(x)
  
  x <- x[vapply(x, is.data.frame, TRUE)]
  if(!length(x)) {
    if(!silent) {
      wrn(p0("environment '", x_name, "' has no data frames"))
    }
    return(invisible(character(0)))
  }
  
  invisible(
    rws_write_sqlite(x, exists = exists, delete = delete, commit = commit,
                     meta = meta, log = log, silent = silent, 
                     complete = complete, conn = conn))
}
