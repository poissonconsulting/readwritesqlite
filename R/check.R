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
#' con <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
#' check_sqlite_connection(con)
#' DBI::dbDisconnect(con)
#' check_sqlite_connection(con, error = FALSE)
#' check_sqlite_connection(con, connected = TRUE, error = FALSE)
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

check_table_name <- function(table_name, conn, exists) {
  check_string(table_name)
  
  if(to_upper(table_name) == to_upper(.log_table_name))
    err("'", table_name, "' is a reserved table")

  if(to_upper(table_name) == to_upper(.meta_table_name))
    err("'", table_name, "' is a reserved table")
  
  table_exists <- tables_exists(table_name, conn)
  if(isTRUE(exists) && !table_exists)
    err("table '", table_name, "' does not exist")
  
  if(isFALSE(exists) && table_exists)
    err("table '", table_name, "' already exists")
  
  table_name
}

check_table_names <- function(table_names, conn, exists, delete) {
  check_character(table_names)
  if(!length(table_names)) return(table_names)
  
  vapply(table_names, check_table_name, "", conn = conn, exists = exists,
         USE.NAMES = FALSE)
  
  if(isFALSE(exists) || isTRUE(delete)) {
    duplicates <- duplicated(to_upper(table_names))
    if(any(duplicates)) {
      table_names %in% table_names[duplicates]
      table_names <- unique(table_names)
      table_names <- sort(table_names)
      
      # needs some love
      but <- ""
      if(isFALSE(exists)) {
        but <- "exists is FALSE"
        if(isTRUE(delete))
          but <- p0(but, " and ")
      }
      but <- p0(but, if(isTRUE(delete)) "delete is TRUE" else "")
      if(!identical(but, "")) but <- p0(" (", but, ")")
      
      err(p0(co(table_names, "table name %c is duplicated",
            some = "the following %n table name%s %r duplicates: %c",
             conjunction = "and"), but))
    }
  }
  as.character(table_names)
}
