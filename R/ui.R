### very simplified versions of usethis functions
ui_line <- function(x) {
  rlang::inform(x)
}

ui_value <- function(x) {
  if (is.character(x)) {
    x <- encodeString(x, quote = "'")
  }
  x <- crayon::blue(x)
  x
}
