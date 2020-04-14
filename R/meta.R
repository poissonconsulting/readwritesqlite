meta_schema <- function() {
  p("CREATE TABLE", .meta_table_name, "(
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);")
}

make_meta_data <- function(conn) {
  table_names <- rws_list_tables(conn)
  if (!length(table_names)) {
    return(data.frame(
      TableMeta = character(0), ColumnMeta = character(0),
      stringsAsFactors = FALSE
    ))
  }
  meta_data <- lapply(table_names, column_names, conn = conn)
  meta_data <- mapply(function(x, y) {
    data.frame(TableMeta = y, ColumnMeta = x, stringsAsFactors = FALSE)
  },
  meta_data, table_names,
  SIMPLIFY = FALSE
  )
  meta_data$stringsAsFactors <- FALSE
  meta_data <- do.call("rbind", meta_data)
  meta_data$TableMeta <- to_upper(meta_data$TableMeta)
  meta_data$ColumnMeta <- to_upper(meta_data$ColumnMeta)
  meta_data
}

replace_meta_table <- function(meta_data, conn) {
  meta_data$TableMeta <- to_upper(meta_data$TableMeta)
  meta_data$ColumnMeta <- to_upper(meta_data$ColumnMeta)
  delete_data(.meta_table_name, meta = FALSE, log = FALSE, conn = conn)
  meta_data <- meta_data[order(meta_data$TableMeta, meta_data$ColumnMeta), ]
  DBI::dbAppendTable(conn, .meta_table_name, meta_data)
}

confirm_meta_table <- function(conn) {
  meta_schema <- meta_schema()
  if (!tables_exists(.meta_table_name, conn)) {
    execute(meta_schema, conn)
  } else {
    meta_schema <- sub(";$", "", meta_schema)
    schema <- table_schema(.meta_table_name, conn)
    if (!identical(schema, meta_schema)) {
      err("Table '", .meta_table_name, "' has an invalid schema.")
    }
  }
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_data <- make_meta_data(conn)
  meta_data <- merge(meta_data, meta_table,
    all.x = TRUE,
    by = c("TableMeta", "ColumnMeta")
  )
  replace_meta_table(meta_data, conn)
}

#' Read Meta Data table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write
#' @return A data frame of the meta table
#' @aliases rws_read_sqlite_meta
#' @export
#' @examples
#' conn <- rws_connect()
#' rws_read_meta(conn)
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_read_meta(conn)
#' rws_disconnect(conn)
rws_read_meta <- function(conn) {
  confirm_meta_table(conn)
  data <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  as_tibble_sf(data)
}

data_column_meta <- function(column) {
  if (is.logical(column)) {
    return("class: logical")
  }
  if (is.Date(column)) {
    return("class: Date")
  }
  if (is_hms(column)) {
    return("class: hms")
  }
  if (is.POSIXct(column)) {
    return(p("tz:", tz(column)))
  }
  if (is.sfc(column)) {
    if (!requireNamespace("sf")) err("Package 'sf' must be installed.")
    proj <- p("proj:", sf::st_crs(column)$proj4string)
    proj <- sub("\\s*$", "", proj)
    return(proj)
  }
  if (is.units(column)) {
    if (!requireNamespace("units")) err("Package 'units' must be installed.")
    return(p("units:", units::deparse_unit(column)))
  }
  if (is.ordered(column)) {
    return(p("ordered:", cc(levels(column), ellipsis = .Machine$integer.max)))
  }
  if (is.factor(column)) {
    return(p("factor:", cc(levels(column), ellipsis = .Machine$integer.max)))
  }
  NA_character_
}

read_meta_levels <- function(x) {
  x <- sub("^(factor|ordered)(:\\s*)(.*)$", "\\3", x)
  if (!length(x)) {
    return(x)
  }
  x <- strsplit(x, ",")[[1]]
  x <- sub("^(\\s*')(.+)", "\\2", x)
  sub("^(.+)('\\s*)$", "\\1", x)
}

read_meta_data_column <- function(column, meta) {
  if (grepl("^class:\\s*logical$", meta)) {
    return(as.logical(column))
  }
  if (grepl("^class:\\s*Date$", meta)) {
    return(as_Date(column))
  }
  if (grepl("^class:\\s*hms$", meta)) {
    return(as_hms(column))
  }
  if (grepl("^tz:", meta)) {
    tz <- sub("(^tz:\\s*)(.*)", "\\2", meta)
    return(as_POSIXct(column, tz = tz))
  }
  if (grepl("^units:", meta)) {
    if (!requireNamespace("units")) err("Package 'units' must be installed.")
    units <- sub("(^units:\\s*)(.*)", "\\2", meta)
    column <- as.double(column)
    return(units::as_units(column, units))
  }
  if (grepl("^proj:", meta)) {
    if (!requireNamespace("sf")) err("Package 'sf' must be installed.")
    proj <- sub("(^proj:\\s*)(.*)", "\\2", meta)
    return(sf::st_set_crs(sf::st_as_sfc(column), proj))
  }
  if (grepl("^factor:", meta)) {
    levels <- read_meta_levels(meta)
    return(factor(column, levels = levels))
  }
  if (grepl("^ordered:", meta)) {
    levels <- read_meta_levels(meta)
    return(ordered(column, levels = levels))
  }
  column
}

data_meta <- function(data) {
  vapply(data, FUN = data_column_meta, FUN.VALUE = "", USE.NAMES = TRUE)
}

delete_meta_data_table_name <- function(table_name, conn) {
  confirm_meta_table(conn)
  table_name <- to_upper(table_name)
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta != table_name, , drop = FALSE]
  replace_meta_table(meta_table, conn = conn)
}

meta_table_meta <- function(table_name, conn) {
  table_name <- to_upper(table_name)

  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta == table_name, ]
  meta_table_meta <- meta_table$MetaMeta
  names(meta_table_meta) <- meta_table$ColumnMeta
  meta_table_meta
}

write_meta_data_column <- function(column, column_name, table_name, conn) {
  meta <- data_column_meta(column)
  column_name <- to_upper(column_name)
  table_name <- to_upper(table_name)

  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table$MetaMeta[meta_table$TableMeta == table_name &
    meta_table$ColumnMeta == column_name] <- meta
  replace_meta_table(meta_table, conn = conn)


  if (grepl("^units:", meta)) {
    return(as.double(column))
  }
  if (grepl("^(factor|ordered):", meta)) {
    return(as.character(column))
  }

  is_text <- is_table_column_text(column_name, table_name, conn)

  if (grepl("^proj:", meta)) {
    if (!requireNamespace("sf")) err("Package 'sf' must be installed.")
    if (is_text) {
      return(sf::st_as_text(column))
    }
    return(sf::st_as_binary(column, endian = "little"))
  }

  if (is_text) {
    return(as.character(column))
  }
  return(as.numeric(column))

  column
}

consistent_factors <- function(data_meta, meta_meta) {
  if (!grepl("^(factor|ordered):", data_meta)) {
    return(FALSE)
  }
  if (!grepl("^(factor|ordered):", meta_meta)) {
    return(FALSE)
  }
  if (grepl("^factor:", data_meta) != grepl("^factor:", data_meta)) {
    return(FALSE)
  }
  if (grepl("^factor:", data_meta)) {
    return(all(read_meta_levels(meta_meta) %in% read_meta_levels(data_meta)))
  }
  if (!all(read_meta_levels(meta_meta) %in% read_meta_levels(data_meta))) {
    return(FALSE)
  }
  meta_levels <- read_meta_levels(meta_meta)
  data_levels <- read_meta_levels(data_meta)
  data_levels <- data_levels[data_levels %in% meta_levels]
  all(data_levels == meta_levels)
}

validate_data_meta <- function(data, table_name, conn) {
  confirm_meta_table(conn)
  data_meta <- data_meta(data)
  meta <- meta_table_meta(table_name, conn)[to_upper(names(data_meta))]

  data_meta[is.na(data_meta)] <- "No"
  if (is_initialized(table_name, conn)) meta[is.na(meta)] <- "No"

  mismatch <- which(!is.na(meta) & data_meta != meta)
  for (wch in mismatch) {
    dmeta <- data_meta[wch]
    mmeta <- meta[wch]
    if (!consistent_factors(dmeta, mmeta)) {
      column_name <- names(dmeta)

      err(
        "Column '", column_name, "' in table '", table_name,
        "' has '", dmeta, "' meta data for the input data",
        " but '", mmeta, "' for the existing data."
      )
    }
  }
  data_meta[data_meta != "No"]
}

write_meta_data <- function(data, table_name, conn) {
  data_meta <- validate_data_meta(data, table_name, conn)

  if (!length(data_meta)) {
    return(data)
  }

  column_names <- names(data_meta)

  data[column_names] <-
    mapply(
      FUN = write_meta_data_column, data[column_names], column_names,
      MoreArgs = list(table_name = table_name, conn = conn), SIMPLIFY = FALSE
    )
  data
}

read_meta_data <- function(data, table_name, conn) {
  confirm_meta_table(conn)
  meta <- meta_table_meta(table_name, conn)

  meta <- meta[to_upper(names(data))]
  names(meta) <- names(data)

  meta <- meta[!is.na(meta)]
  if (!length(meta)) {
    return(data)
  }

  data[names(meta)] <- mapply(
    FUN = read_meta_data_column, data[names(meta)],
    meta, SIMPLIFY = FALSE
  )
  data
}

read_meta_data_data <- function(data, meta) {
  names <- intersect(to_upper(names(data)), names(meta))

  if (!length(names)) {
    return(data)
  }

  meta <- meta[names]
  names(meta) <- names(data)[to_upper(names(data)) %in% names]
  meta <- meta[!is.na(meta)]
  if (!length(meta)) {
    return(data)
  }

  data[names(meta)] <- mapply(
    FUN = read_meta_data_column, data[names(meta)],
    meta, SIMPLIFY = FALSE
  )
  data
}

unambigous_meta_meta <- function(table_names, conn) {
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta %in% to_upper(table_names), ]

  meta_table <- unique(meta_table[c("ColumnMeta", "MetaMeta")])
  meta <- meta_table$MetaMeta
  names(meta) <- meta_table$ColumnMeta

  duplicates <- unique(names(meta)[duplicated(names(meta))])
  if (length(duplicates)) meta <- meta[!names(meta) %in% duplicates]
  meta
}

read_meta_data_query <- function(data, table_names, conn) {
  confirm_meta_table(conn)

  meta <- unambigous_meta_meta(table_names, conn)
  data <- read_meta_data_data(data, meta)
  data
}
