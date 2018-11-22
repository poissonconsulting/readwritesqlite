convert_data <- function(value) {
  value <- factor_to_character(value)
  value <- raw_to_character(value)
  value <- character_to_utf8(value)
  value
}

factor_to_character <- function(value, warn = FALSE) {
  is_factor <- vapply(value, is.factor, TRUE)
  value[is_factor] <- lapply(value[is_factor], as.character)
  value
}

raw_to_character <- function(value) {
  is_raw <- vapply(value, is.raw, TRUE)
  if (any(is_raw)) {
    wrn("Creating a TEXT column from raw, use lists of raw to create BLOB columns")
    value[is_raw] <- lapply(value[is_raw], as.character)
  }
  value
}

character_to_utf8 <- function(value) {
  is_character <- vapply(value, is.character, TRUE)
  value[is_character] <- lapply(value[is_character], enc2utf8)
  value
}
