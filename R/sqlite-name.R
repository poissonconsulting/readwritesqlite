#' SQLite Name
#'
#' A SQLite name is a vector of names for SQLite objects that inherits from character.
#' It is useful for comparing SQLite names which are case insensitive except when 
#' they are quoted using \code{"name"}, \code{[name]} \code{`name`}.
#' When making a comparison, SQLite names are converted to upper case 
#' unless they are quoted using one of the three methods 
#' in which case the quotes are removed.
#' @examples
#' x <- 1
#' @name sqlite_name
NULL

#' Coerce to a SQLite Name
#'
#' @param x The object to coerce
#' @param ... Unused.
#' @export
#' @examples
#' as.sqlite_name("Data")
as.sqlite_name <- function(x, ...) {
  UseMethod("as.sqlite_name")
}

#' @describeIn as.sqlite_name Coerces SQLite name vector to a character vector
#' @export
as.character.sqlite_name <- function(x, ...) set_class(x, "character")

#' @export
as.sqlite_name.sqlite_name <- function(x, ...) x

#' @describeIn as.sqlite_name Coerces character vector to a SQLite name vector
#' @export
as.sqlite_name.character <- function(x, ...) set_class(x, c("sqlite_name", "character"))

#' Is SQLite Name
#'
#' Test whether an object is a SQLite name.
#'
#' @param x The object to test.
#' @return A flag indicating whether the test was positive.
#' @export
#' @examples
#' is.sqlite_name(as.sqlite_name("data"))
is.sqlite_name <- function(x) inherits(x, "sqlite_name")

#' @export
rep.sqlite_name <- function(x, times, ...) {
  x <- as.character(x)
  x <- rep(x, times)
  as.sqlite_name(x)
}

.quotes <- "^(`|[[]|\")(.*)(`|[]]|\")$"

is_quoted <- function(x) grepl(.quotes, x)

unquote <- function(x) sub(.quotes, "\\2", x)

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

#' @export
`>.sqlite_name` <- function(e1, e2) {
  e2 <- as.sqlite_name(e2)
  unquote(to_upper(e1)) > unquote(to_upper(e2)) & quotes(e1) > quotes(e2)
}

#' @export
`==.sqlite_name` <- function(e1, e2) {
  e2 <- as.sqlite_name(e2)
  to_upper(e1) == to_upper(e2)
}

#' @export
xtfrm.sqlite_name <- function(x) {
  data <- data.frame(names = unquote(to_upper(x)), quotes = quotes(x),
                     stringsAsFactors = FALSE)
  order(data$names, data$quotes)
}

#' @export
`[.sqlite_name` <- function(x, i) as.sqlite_name(as.character(x)[i])

#' @export
print.sqlite_name <- function(x, ...) {
  print(as.character(x))
  invisible(x)
}
