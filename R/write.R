#' Write a data frame to a SQLite Database
#'
#' The table must exist.
#'
#' @param data A data frame of the data to write.
#' @param table_name A string of the (case insensitive) table name.
#' @param conn A \code{\linkS4class{SQLiteConnection}} object.
#' @param delete A flag specifying whether to delete existing rows before inserting the data.
#' @param commit A flag specifying whether to commit the changes (useful for checking data).
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log data manipulations.
#' @return The updated data frame with the same columns as the table.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTableSQLite <- function(data, table_name = substitute(data),
                               conn = getOption("dbWriteSQLite.conn", NULL),
                               delete = FALSE, commit = TRUE,
                               meta = TRUE, log = TRUE) {
  table_name <- chk_deparse(table_name)

  check_flag(delete)
  check_flag(commit)
  check_flag(meta)
  check_flag(log)

  data <- check_data_sqlite(data, table_name, conn)

  dbBegin(conn, name = "dbWriteTableSQLite")
  on.exit(dbRollback(conn, name = "dbWriteTableSQLite"))

  data2 <- check_data_sqlite(data, table_name, conn, convert = TRUE)

  if(delete) {
    sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
    query <- DBI::sqlInterpolate(conn, sql, table_name = table_name)
    nrow <- dbExecute(conn, p0("DELETE FROM ",  table_name))
    if(log) {
      log_command(conn, table_name, command = "DELETE",
                  nrow = nrow)
    }
  }
  if (nrow(data)) {
    dbAppendTable(conn, table_name, data2)
    if(log) {
      log_command(conn, table_name, command = "INSERT", nrow = nrow(data2))
    }
  }
  if(!commit) return(invisible(data))

  dbCommit(conn, name = "dbWriteTableSQLite")
  on.exit(NULL)
  invisible(data)
}

#' Write a list of data frames to a SQLite Database
#'
#' The tables must exist.
#' The commit = FALSE argument is not yet used.
#'
#' @param list A named list of data frames.
#' Objects which are not data frames are removed.
#' @inheritParams dbWriteTableSQLite
#' @return An invisible character vector of the names of the data frames that
#' were written to connection in the order in which they were written.
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' DBI::dbDisconnect(con)
dbWriteTablesSQLite <- function(list = as.list(parent.frame()),
                                conn = getOption("dbWriteSQLite.conn", NULL),
                                delete = FALSE, commit = TRUE,
                                meta = TRUE, log = TRUE) {

  check_list(list)
  check_inherits(conn, "SQLiteConnection")

  list <- list[vapply(list, is.data.frame, TRUE)]
  check_named(list, unique = TRUE)
  tables <- table_names_sorted(conn)
  tables <- tables[tables %in% names(list)]
  list <- list[tables]
  if(!length(list)) return(invisible(character(0)))

  if(!isTRUE(commit)) .NotYetUsed(commit)

  mapply(dbWriteTableSQLite, list, names(list),
         MoreArgs = list(delete = delete, meta = meta, log = log),
         SIMPLIFY = FALSE)

  invisible(names(list))
}
