write_sqlite_data <- function(data, table_name, exists, delete, replace, meta, log,
                              strict, silent, conn) {
  if (vld_false(exists) || (is.na(exists) && !tables_exists(table_name, conn))) {
    create_table(data, table_name, log = log, silent = silent, conn = conn)
  }

  if (delete) {
    delete_data(table_name, meta = meta, log = log, conn = conn)
  }

  data <- validate_data(data, table_name,
    strict = strict, silent = silent,
    conn = conn
  )
  write_data(data, table_name,
    replace = replace, meta = meta, log = log,
    conn = conn
  )
  data
}

#' Write to a SQLite Database
#'
#' @param x The object to write.
#' @param exists A flag specifying whether the table(s) must already exist.
#' @param delete A flag specifying whether to delete existing rows before
#' inserting data. If `meta = TRUE` the meta data is deleted.
#' @param replace A flag specifying whether to replace any existing rows whose inclusion would violate unique or primary key constraints.
#' @param meta A flag specifying whether to preserve meta data.
#' @param log A flag specifying whether to log the table operations.
#' @param commit A flag specifying whether to commit the operations
#' (calling with commit = FALSE can be useful for checking data).
#' @param strict A flag specifying whether to error if x has extraneous columns or if exists = TRUE extraneous data frames.
#' @param conn A [SQLiteConnection-class] to a database.
#' @param x_name A string of the name of the object.
#' @param silent A flag specifying whether to suppress messages and warnings.
#' @param ... Not used.
#' @return An invisible character vector of the name(s) of the table(s).
#' @aliases rws_write_sqlite
#' @family rws_write
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_disconnect(conn)
rws_write <- function(x, exists = TRUE, delete = FALSE,
                      replace = FALSE,
                      meta = TRUE,
                      log = TRUE,
                      commit = TRUE,
                      strict = TRUE,
                      x_name = substitute(x),
                      silent = getOption("rws.silent", FALSE),
                      conn,
                      ...) {
  UseMethod("rws_write")
}

#' Write a Data Frame to a SQLite Database
#'
#' @param x A data frame.
#' @inheritParams rws_write
#' @family rws_write
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_list_tables(conn)
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_write(rws_data, x_name = "moredata", exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_write.data.frame <- function(
                                 x, exists = TRUE, delete = FALSE, replace = FALSE, meta = TRUE, log = TRUE, commit = TRUE, strict = TRUE,
                                 x_name = substitute(x), silent = getOption("rws.silent", FALSE),
                                 conn, ...) {
  chk_lgl(exists)
  chk_flag(delete)
  chk_flag(replace)
  chk_flag(meta)
  chk_flag(log)
  chk_flag(commit)
  chk_flag(strict)
  chk_sqlite_conn(conn, connected = TRUE)

  x_name <- chk_deparse(x_name)
  chk_string(x_name)
  check_table_name(x_name, exists = exists, conn = conn)
  chk_flag(silent)
  chk_unused(...)

  foreign_keys <- foreign_keys(TRUE, conn)

  dbBegin(conn, name = "rws_write")
  on.exit(dbRollback(conn, name = "rws_write"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)

  write_sqlite_data(x,
    table_name = x_name, exists = exists,
    delete = delete, replace = replace,
    meta = meta, log = log,
    strict = strict,
    silent = silent, conn = conn
  )

  if (!commit) {
    return(invisible(x_name))
  }

  dbCommit(conn, name = "rws_write")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  invisible(x_name)
}

#' Write a Named List of Data Frames to a SQLite Database
#'
#' @inheritParams rws_write
#' @param x A named list of data frames.
#' @param all A flag specifying whether all the existing tables in the data base must be represented.
#' @param unique A flag specifying whether each table must represented by no more than one data frame.
#' @family rws_write
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_list_tables(conn)
#' rws_write(list(somedata = rws_data, anothertable = rws_data), exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_write.list <- function(x,
                           exists = TRUE,
                           delete = FALSE,
                           replace = FALSE,
                           meta = TRUE,
                           log = TRUE,
                           commit = TRUE,
                           strict = TRUE,
                           x_name = substitute(x),
                           silent = getOption("rws.silent", FALSE),
                           conn,
                           all = TRUE,
                           unique = TRUE, ...) {
  chk_named(x)
  chk_lgl(exists)
  chk_flag(delete)
  chk_flag(replace)
  chk_flag(meta)
  chk_flag(log)
  chk_flag(commit)
  chk_flag(strict)
  chk_sqlite_conn(conn, connected = TRUE)
  x_name <- chk_deparse(x_name)
  chk_string(x_name)
  chk_flag(silent)
  chk_flag(all)
  chk_flag(unique)
  chk_unused(...)

  if (!length(x)) {
    return(character(0))
  }

  if (!all(vapply(x, is.data.frame, TRUE))) {
    err("List `", x_name, "` includes objects which are not data frames.")
  }

  if (vld_true(exists)) {
    exists2 <- tables_exists(names(x), conn)
    if (any(!exists2)) {
      extra <- names(x)[!exists2]
      msg <- p0(
        "The following data frame%s in '",
        x_name, "' %r unrecognised: ", cc(extra, " and "),
        "; but exists = TRUE."
      )
      if (strict) err(msg, n = length(extra))
      if (!silent) wrn(msg, n = length(extra))
    }
    x <- x[exists2]
    if (!length(x)) {
      return(invisible(character(0)))
    }
  }

  check_table_names(names(x),
    exists = exists, delete = delete, all = all,
    unique = unique, conn = conn
  )

  foreign_keys <- foreign_keys(TRUE, conn)
  defer <- defer_foreign_keys(TRUE, conn)

  dbBegin(conn, name = "rws_write")
  on.exit(dbRollback(conn, name = "rws_write"))
  on.exit(foreign_keys(foreign_keys, conn), add = TRUE)
  on.exit(defer_foreign_keys(defer, conn), add = TRUE)

  mapply(write_sqlite_data, x, names(x),
    MoreArgs = list(
      exists = exists, delete = delete,
      replace = replace,
      meta = meta, log = log,
      silent = silent,
      strict = strict, conn = conn
    ), SIMPLIFY = FALSE
  )

  if (!commit) {
    return(invisible(names(x)))
  }
  dbCommit(conn, name = "rws_write")
  on.exit(NULL)
  foreign_keys(foreign_keys, conn)
  defer_foreign_keys(defer, conn)
  invisible(invisible(names(x)))
}

#' Write the Data Frames in an Environment to a SQLite Database
#'
#' @inheritParams rws_write
#' @inheritParams rws_write.list
#' @param x An environment.
#' @family rws_write
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' rws_list_tables(conn)
#' atable <- readwritesqlite::rws_data
#' another_table <- readwritesqlite::rws_data
#' not_atable <- 1L
#' rws_write(environment(), exists = FALSE, conn = conn)
#' rws_list_tables(conn)
#' rws_disconnect(conn)
rws_write.environment <- function(x,
                                  exists = TRUE,
                                  delete = FALSE,
                                  replace = FALSE,
                                  meta = TRUE,
                                  log = TRUE,
                                  commit = TRUE,
                                  strict = TRUE,
                                  x_name = substitute(x),
                                  silent = getOption("rws.silent", FALSE),
                                  conn,
                                  all = TRUE,
                                  unique = TRUE, ...) {
  x_name <- chk_deparse(x_name)
  chk_string(x_name)
  chk_flag(silent)
  chk_unused(...)
  x <- as.list(x)

  x <- x[vapply(x, is.data.frame, TRUE)]
  if (!length(x)) {
    if (!silent) {
      wrn(p0("Environment '", x_name, "' has no data frames."))
    }
    return(invisible(character(0)))
  }

  invisible(
    rws_write(x,
      exists = exists, delete = delete, replace = replace,
      meta = meta, log = log, commit = commit,
      strict = strict, silent = silent,
      conn = conn, all = all, unique = unique
    )
  )
}
