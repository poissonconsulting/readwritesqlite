#' Check SQLite Connection
#' 
#' Checks whether an R object is a SQLite Connection.
#'
#' @inheritParams checkr::check_vector
#' @param connected A flag specifying whether x should be connected.
#' @return An invisible copy of the original object.
#' @export
#'
#' @examples
#' conn <- rws_connect()
#' check_sqlite_connection(conn)
#' rws_disconnect(conn)
#' check_sqlite_connection(conn, error = FALSE)
#' check_sqlite_connection(conn, connected = TRUE, error = FALSE)
check_sqlite_connection <- function(x, connected = NA, x_name = substitute(x), error = TRUE) {
  x_name <- chk_deparse(x_name)
  check_scalar(connected, values = c(TRUE, NA))
  check_flag(error)
  check_inherits(x, "SQLiteConnection", x_name = x_name)
  if(isTRUE(connected) && !dbIsValid(x)) {
    chk_fail(x_name, " must be connected", error = error)
  } else if(isFALSE(connected) && dbIsValid(x))
    chk_fail(x_name, " must be disconnected", error = error)
  invisible(x)
}

check_table_name <- function(table_name, exists, conn) {
  check_string(table_name)
  
  if(to_upper(table_name) %in% to_upper(reserved_tables()))
    err("'", table_name, "' is a reserved table")

  table_exists <- tables_exists(table_name, conn)
  if(isTRUE(exists) && !table_exists)
    err("table '", table_name, "' does not exist")
  
  if(isFALSE(exists) && table_exists)
    err("table '", table_name, "' already exists")
  
  table_name
}

check_table_names <- function(table_names, exists, delete, all, unique, conn) {
  check_character(table_names)
  if(!length(table_names)) return(table_names)
  
  vapply(table_names, check_table_name, "", exists = exists, conn = conn,
         USE.NAMES = FALSE)
  
  if(unique || isFALSE(exists) || delete) {
    duplicates <- duplicated(to_upper(table_names))
    if(any(duplicates)) {
      table_names <- table_names[!duplicated(to_upper(table_names))]
      table_names <- sort(table_names)
      
      unique <- if(unique) "unique = TRUE" else NULL
      exists <- if(isFALSE(exists)) "exists = FALSE" else NULL
      delete <- if(delete) "delete = TRUE" else NULL
      
      but <- p0(c(unique, exists, delete), collapse = " and ")
      
      err(co(table_names, one = p0(but, " but the following table name%s %r duplicated: %c"),
               conjunction = "and"))
    }
  }
  if(all && !isFALSE(exists)) {
    missing <- 
      setdiff(to_upper(rws_list_tables(conn)), to_upper(table_names))
    if(length(missing)) {
      err(co(missing, "all = TRUE and exists != FALSE but the following table name%s %r not represented: %c",
             conjunction = "and"))
    }
  }
  table_names
}
