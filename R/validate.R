validate_data <- function(data, table_name, strict, silent, conn) {
  sf_column_name <- sf_column_name(data)
  data <- as.data.frame(data)

  colnames <- to_upper(column_names(table_name, conn = conn))
  data_names <- names(data)
  names(data_names) <- to_upper(names(data))
  names(data) <- to_upper(names(data))

  chk_superset(colnames(data), colnames, x_name = p0("'", table_name, "' column names"))

  if (vld_false(silent)) {
    extra <- data_names[!names(data_names) %in% colnames]
    if (length(extra)) {
      msg <- p0(
        "The following column%s in data '",
        table_name, "' %r unrecognised: ", cc(extra, " and "),
        "."
      )
      if (strict) err(msg, n = length(extra))
      if (!silent) wrn(msg, n = length(extra))
    }
  }

  data <- data[colnames]
  table_info <- table_info(table_name, conn)
  table_info$name <- to_upper(table_info$name)
  row.names(table_info) <- table_info$name
  table_info <- table_info[colnames, ]

  table_info$is_na <- vapply(data, any_is_na, TRUE)
  invalid_nas <- table_info$name[table_info$notnull & table_info$is_na]
  if (length(invalid_nas)) {
    err("There are unpermitted missing values in the following %n ",
      "column%s in data '", table_name, "': ", cc(invalid_nas, " and "),
      n = length(invalid_nas)
    )
  }

  pk <- table_info$name[table_info$pk != 0L]
  chk_unique(data[pk],
    incomparables = NA, x_name =
      p0("columns ", cc(pk, " and "), " in data '", table_name, "'")
  )

  names(data) <- data_names[names(data)]
  if (!is.na(sf_column_name) && sf_column_name %in% names(data)) {
    data <- st_sf(data,
      sf_column_name = sf_column_name,
      stringsAsFactors = FALSE
    )
  }
  data
}
