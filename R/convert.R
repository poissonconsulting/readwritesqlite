factor_to_character <- function(data, warn = FALSE) {
  is_factor <- vapply(data, is.factor, TRUE)
  data[is_factor] <- lapply(data[is_factor], as.character)
  data
}

raw_to_character <- function(data) {
  is_raw <- vapply(data, is.raw, TRUE)
  if (any(is_raw)) {
    wrn("Creating a TEXT column from raw, use lists of raw to create BLOB columns.")
    data[is_raw] <- lapply(data[is_raw], as.character)
  }
  data
}

sfc_to_blob <- function(data) {
  is_sfc <- vapply(data, is.sfc, TRUE)
  if (any(is_sfc) && !requireNamespace("sf")) {
    err("Package 'sf' must be installed.")
  }

  data[is_sfc] <- lapply(data[is_sfc], sf::st_as_binary,
    endian = "little"
  )
  data
}

character_to_utf8 <- function(data) {
  is_character <- vapply(data, is.character, TRUE)
  data[is_character] <- lapply(data[is_character], enc2utf8)
  data
}

convert_data <- function(data) {
  data <- as.data.frame(data)
  data <- factor_to_character(data)
  data <- raw_to_character(data)
  data <- character_to_utf8(data)
  data <- sfc_to_blob(data)
  data
}
