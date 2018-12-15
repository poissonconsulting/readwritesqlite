sys_date_time_utc <- function() {
  date_time <- Sys.time()
  attr(date_time, "tzone") <- "UTC"
  as.character(date_time, format = "%Y-%m-%d %H:%M:%S")
}

user <- function() {
  unname(Sys.info()["user"])
}

set_class <- function(x, value) {
  class(x) <- value
  x
}

as_conditional_tibble <- function(x) {
  sf_column_name <- sf_column_name(x)
  if(requireNamespace("tibble", quietly = TRUE)) {
    x <- tibble::as_tibble(x)
    if(!is.na(sf_column_name)) {
      x <- sf::st_sf(x, sf_column_name = sf_column_name, 
                     stringsAsFactors = FALSE)
    }
  }
  x
}

named_list <- function() {
  list(x = 1)[integer(0)]
}

is.sfc <- function(x) inherits(x, "sfc")
is.sf <- function(x) inherits(x, "sf")

is.units <- function(x) inherits(x, "units")
is.blob <- function(x) inherits(x, "blob")

any_is_na <- function(x) {
  any(is.na(x))
}

reserved_tables <- function() {
  c(.log_table_name, .meta_table_name, .init_table_name)
}

sf_column_name <- function(x) {
  x <- attr(x, "sf_column")
  if(is.null(x)) return(NA_character_)
  x
}
