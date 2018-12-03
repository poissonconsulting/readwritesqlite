write_sqlite_data <- function(data, table_name, conn, exists, delete, meta, log) {
  if(isFALSE(exists)) {
    DBI::dbCreateTable(con, table_name, data)
    if(log) log_command(conn, table_name, command = "CREATE", nrow = 0L)
  }
  
  colnames <- dbListFields(conn, table_name)
  check_colnames(data, colnames = colnames)
  data <- data[colnames]
  # need to add more data checking here
  
  # need to add meta recording here
  data <- convert_data(data)
  
  if(delete) {
    sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
    query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
    nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
    if(log) {
      log_command(conn, table_name, command = "DELETE", nrow = nrow)
    }
  }
  if (nrow(data)) {
    dbAppendTable(conn, table_name, data)
    if(log) {
      log_command(conn, table_name, command = "INSERT", nrow = nrow(data))
    }
  }
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
  
  dbBegin(conn, name = "rws_write_sqlite")
  on.exit(dbRollback(conn, name = "rws_write_sqlite"))
  
  write_sqlite_data(x, table_name, conn = conn, exists = exists, 
                    delete = delete, 
                    meta = meta, log = log)
  
  if(!commit) return(invisible(table_name))
  
  dbCommit(conn, name = "rws_write_sqlite")
  on.exit(NULL)
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
  .NotYetImplemented()
  # check_named(x)
  # check_sqlite_connection(conn, connected = TRUE)
  # check_flag(delete)
  # check_flag(commit)
  # check_flag(meta)
  # check_flag(log)
  # check_unused(...)
  # 
  # x <- x[vapply(x, is.data.frame, TRUE)]
  # if(!length(x)) {
  #   wrn("x has no data frames")
  #   return(character(0))
  # }
  # is <- is_table(names(x), conn)
  # 
  # if(any(!is)) {
  #   non_matching <- names(x)[!is]
  #   wrn(co(non_matching,  
  #          "the following %n data frame%s have names which do not match a table: %c", 
  #          lots = "%n data frames have names that do not match a table",
  #          conjunction = "and"))
  # }
  # 
  # table_names <- hierachical_table_names(conn)
  # table_names <- table_names[toupper(table_names) %in% toupper(names(x))]
  # if(length(non_matching)) {
  #   
  # }
  # x <- x[names(x) %in% table_names]
  # if(!length(x)) return(invisible(character(0)))
  # 
  # if(!isTRUE(commit)) .NotYetUsed(commit)
  # 
  # mapply(write_sqlite, list, names(list),
  #        MoreArgs = list(delete = delete, meta = meta, log = log),
  #        SIMPLIFY = FALSE)
  # 
  # dbCommit(conn, name = "write_sqlite")
  # on.exit(NULL)
  # invisible(data_name)
}
