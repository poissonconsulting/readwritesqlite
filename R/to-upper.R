.quotes <- "^(`|[[]|\")(.*)(`|[]]|\")$"

is_quoted <- function(x) grepl(.quotes, x)

quotes <- function(x) {
  y <- sub(.quotes, "\\1", x)
  y[y == x] <- ""
  as.character(y)
}

unquote <- function(x) sub(.quotes, "\\2", x)

to_upper <- function(x) {
  x <- as.character(x)
  is_quoted <- is_quoted(x)
  x[!is_quoted] <- toupper(x[!is_quoted])
  x
}
