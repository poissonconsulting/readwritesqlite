#' SQLite Name
#'
#' A SQLite name is a vector of names for SQLite objects that inherits from character.
#' It is useful for comparing SQLite names which are case insensitive 
#' except when they are quoted using \code{"name"}, \code{[name]} \code{`name`}.
#' 
#' @param x An object to coerce.
#' @param ... Unused
#' @export
as.sqlite_name <- function(x, ...) {
  UseMethod("as.sqlite_name")
}

#' @export
as.character.sqlite_name <- function(x, ...) set_class(x, "character")

#' @export
as.sqlite_name.sqlite_name <- function(x, ...) x

#' @export
as.sqlite_name.character <- function(x, ...) set_class(x, c("sqlite_name", "character"))

#' Is SQLite Name
#' 
#' Tests whether an R object inherits from class \code{sqlite_name}.
#' @param x An R object to test.
#' 
#' @return A flag specifying whether an R object is a sqlite_name.
#' @export
is.sqlite_name <- function(x) inherits(x, "sqlite_name")

#' @export
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

#' @export
xtfrm.sqlite_name <- function(x) {
  data <- data.frame(names = unquote(to_upper(x)), quotes = quotes(x),
                     stringsAsFactors = FALSE)
  order(data$names, data$quotes)
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
`[.sqlite_name` <- function(x, i) as.sqlite_name(as.character(x)[i])

#' @export
print.sqlite_name <- function(x, ...) {
  print(as.character(x))
  invisible(x)
}

#' @export
duplicated.sqlite_name <- function (x, incomparables = FALSE, ...) {
  duplicated(to_upper(x), incomparables = incomparables)
}
