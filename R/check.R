#' Check SQLite Connection
#'
#' Checks whether an R object is a SQLite Connection.
#'
#' @inheritParams chk::chk_flag
#' @param connected A logical scalar specifying whether x should be connected.
#' @param err A flag indicating whether to throw an informative error
#' or immediately generate an informative message if the check fails.
#' @param error A flag indicating whether to throw an informative error
#' or immediately generate an informative message if the check fails.
#' @return TRUE if passes check. Otherwise if throws an informative error unless
#' \code{err = FALSE} in which case it returns FALSE.
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' chk_sqlite_conn(conn)
#' rws_disconnect(conn)
#' try(chk_sqlite_conn(conn, connected = TRUE))
chk_sqlite_conn <- function(x, connected = NA, err = TRUE, x_name = NULL) {
  if (inherits(x, "SQLiteConnection") && (is.na(connected) || connected == dbIsValid(x))) {
    return(TRUE)
  }
  if (!err) {
    return(FALSE)
  }
  if (is.null(x_name)) x_name <- paste0("`", deparse(substitute(x)), "`")
  chk_s4_class(x, "SQLiteConnection", x_name = x_name)
  if (isTRUE(connected)) err(x_name, " must be connected.")
  err(x_name, " must be disconnected.")
}

check_table_name <- function(table_name, exists, conn) {
  chk_string(table_name)

  if (to_upper(table_name) %in% to_upper(reserved_tables())) {
    err("Table '", table_name, "' is a reserved table.")
  }

  table_exists <- tables_exists(table_name, conn)
  if (isTRUE(exists) && !table_exists) {
    err("Table '", table_name, "' does not exist.")
  }

  if (isFALSE(exists) && table_exists) {
    err("Table '", table_name, "' already exists.")
  }

  table_name
}

check_table_names <- function(table_names, exists, delete, all, unique, conn) {
  chk_s3_class(table_names, "character")
  if (!length(table_names)) {
    return(table_names)
  }

  vapply(table_names, check_table_name, "",
    exists = exists, conn = conn,
    USE.NAMES = FALSE
  )

  if (unique || isFALSE(exists) || delete) {
    duplicates <- duplicated(to_upper(table_names))
    if (any(duplicates)) {
      table_names <- table_names[!duplicated(to_upper(table_names))]
      table_names <- sort(table_names)

      unique <- if (unique) "unique = TRUE" else NULL
      exists <- if (isFALSE(exists)) "exists = FALSE" else NULL
      delete <- if (delete) "delete = TRUE" else NULL

      but <- p0(c(unique, exists, delete), collapse = " and ")
      err("The following table name%s %r duplicated: ",
        cc(table_names, " and "), "; but ", but, ".",
        n = length(table_names)
      )
    }
  }
  if (all && !isFALSE(exists)) {
    missing <-
      setdiff(to_upper(rws_list_tables(conn)), to_upper(table_names))
    if (length(missing)) {
      err("The following table name%s %r not represented: ",
        cc(missing, " and "), "; but all = TRUE and exists != FALSE.",
        n = length(missing)
      )
    }
  }
  table_names
}
