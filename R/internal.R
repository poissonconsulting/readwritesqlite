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

as_tibble_sf <- function(x) {
  sf_column_name <- sf_column_name(x)
    x <- tibble::as_tibble(x)
    if(!is.na(sf_column_name)) {
      x <- sf::st_sf(x, sf_column_name = sf_column_name, 
                     stringsAsFactors = FALSE)
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
  if(!is.sf(x)) return(NA_character_)
  x <- attr(x, "sf_column")
  if(is.null(x)) return(NA_character_)
  x
}

str_extract_all <- function(x, y) {
  regmatches(x, gregexpr(y, x, ignore.case = TRUE, perl = TRUE))
}

query_table_names <- function(x) {
  w <- "((\\w+)|(`\\w+`)|([[]\\w+[]])|(\"\\w+\"))"
  from <- p0("(?<=FROM\\s)\\s*", w, "(\\s*,\\s*", w, ")*")
  from <- unlist(str_extract_all(x, from))
  from <- unlist(strsplit(from, ","))
  join <- p0("(?<=JOIN\\s)\\s*", w)
  join <- unlist(str_extract_all(x, join))
  tables <- c(from, join)
  tables <- gsub("\\s", "", tables)
  sort(unique(to_upper(tables)))
}
