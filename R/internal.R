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
  if(requireNamespace("tibble", quietly = TRUE))
    x <- tibble::as_tibble(x)
  x
}

named_list <- function() {
  list(x = 1)[integer(0)]
}

is.sfc <- function(x) inherits(x, "sfc")

is.units <- function(x) inherits(x, "units")
is.blob <- function(x) inherits(x, "blob")

any_is_na <- function(x) {
  any(is.na(x))
}
