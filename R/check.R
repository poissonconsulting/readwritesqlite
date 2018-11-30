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

#' Check SQLite Name
#'
#' @inheritParams checkr::check_vector
#' @return An invisible copy of the original object.
#' @export
#'
#' @examples
#' check_sqlite_name("Data")
check_sqlite_name <- function(x, values = NULL, length = NA, unique = FALSE, 
                              sorted = FALSE, named = NA, attributes = named,
                              x_name = substitute(x), error = TRUE) {
  x_name <- chk_deparse(x_name)
  
  checkor(check_null(values), 
          check_vector(values, c("", NA_character_), length = TRUE))
  
  check_classes(x, c("sqlite_name", "character"), 
                order = TRUE, x_name = x_name)
  
  check_vector(as.character(x), values = values, length = length, unique = unique,
               sorted = sorted, named = named, attributes = attributes, 
               x_name = x_name, error = error) 
  invisible(x)
}

