#' SQLite Name
#'
#' A SQLite name is a vector of names for SQLite objects that inherits from character.
#' It is useful for comparing SQLite names which are case insensitive except when 
#' they are quoted using \code{"name"}, \code{[name]} \code{`name`}.
#' When making a comparison, SQLite names are converted to upper case 
#' unless they are quoted using one of the three methods 
#' in which case the quotes are removed.
as.sqlite_name <- function(x, ...) {
  UseMethod("as.sqlite_name")
}

as.character.sqlite_name <- function(x, ...) set_class(x, "character")

as.sqlite_name.sqlite_name <- function(x, ...) x

as.sqlite_name.character <- function(x, ...) set_class(x, c("sqlite_name", "character"))

is.sqlite_name <- function(x) inherits(x, "sqlite_name")

rep.sqlite_name <- function(x, times, ...) {
  x <- as.character(x)
  x <- rep(x, times)
  as.sqlite_name(x)
}

.quotes <- "^(`|[[]|\")(.*)(`|[]]|\")$"

is_quoted <- function(x) grepl(.quotes, x)

quotes <- function(x) {
  y <- sub(.quotes, "\\1", x)
  y[y == x] <- ""
  as.character(y)
}

to_upper <- function(x) {
  x <- as.character(x)
  is_quoted <- is_quoted(x)
  x[!is_quoted] <- toupper(x[!is_quoted])
  x
}

unquote <- function(x) sub(.quotes, "\\2", x)

xtfrm.sqlite_name <- function(x) {
  data <- data.frame(names = unquote(to_upper(x)), quotes = quotes(x),
                     stringsAsFactors = FALSE)
  order(data$names, data$quotes)
}

`>.sqlite_name` <- function(e1, e2) {
  e2 <- as.sqlite_name(e2)
  unquote(to_upper(e1)) > unquote(to_upper(e2)) & quotes(e1) > quotes(e2)
}

`==.sqlite_name` <- function(e1, e2) {
  e2 <- as.sqlite_name(e2)
  to_upper(e1) == to_upper(e2)
}

`[.sqlite_name` <- function(x, i) as.sqlite_name(as.character(x)[i])

print.sqlite_name <- function(x, ...) {
  print(as.character(x))
  invisible(x)
}
