### very simplified versions of usethis functions
bullet <- function(x, bullet) {
  bullet <- paste0(bullet, " ", x)
  rlang::inform(bullet)
}

ui_line <- function(x) {
  rlang::inform(x)
}

ui_oops <- function(x) {
  bullet(x, crayon::red(clisymbols::symbol$cross))
}

ui_done <- function(x) {
  bullet(x, crayon::green(clisymbols::symbol$tick))
}

ui_value <- function(x) {
  if (is.character(x)) {
    x <- encodeString(x, quote = "'")
  }
  # x <- crayon::blue(x)
  x
}
