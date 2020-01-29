check_table_name <- function(table_name, exists, conn) {
  chk_string(table_name)

  if (to_upper(table_name) %in% to_upper(reserved_tables())) {
    err("Table '", table_name, "' is a reserved table.")
  }

  table_exists <- tables_exists(table_name, conn)
  if (vld_true(exists) && !table_exists) {
    err("Table '", table_name, "' does not exist.")
  }

  if (vld_false(exists) && table_exists) {
    err("Table '", table_name, "' already exists.")
  }

  table_name
}

check_column_name <- function(table_name, column_name, exists, conn) {
  check_table_name(table_name, exists = TRUE, conn = conn)
  chk_string(column_name)

  column_exists <- column_name %in% column_names(table_name, conn)

  if (vld_true(exists) && !column_exists) {
    err("Column '", column_name, "' does not exist in table '", table_name, "'.")
  }

  if (vld_false(exists) && column_exists) {
    err("Column '", column_name, "' already exists in table '", table_name, "'.")
  }

  column_name
}


check_table_names <- function(table_names, exists, delete, all, unique, conn) {
  chk_s3_class(table_names, "character")
  if (!length(table_names)) {
    return(table_names)
  }

  vapply(table_names, check_table_name, "",
    exists = exists, conn = conn,
    USE.NAMES = FALSE
  )

  if (unique || vld_false(exists) || delete) {
    duplicates <- duplicated(to_upper(table_names))
    if (any(duplicates)) {
      table_names <- table_names[!duplicated(to_upper(table_names))]
      table_names <- sort(table_names)

      unique <- if (unique) "unique = TRUE" else NULL
      exists <- if (vld_false(exists)) "exists = FALSE" else NULL
      delete <- if (delete) "delete = TRUE" else NULL

      but <- p0(c(unique, exists, delete), collapse = " and ")
      err("The following table name%s %r duplicated: ",
        cc(table_names, " and "), "; but ", but, ".",
        n = length(table_names)
      )
    }
  }
  if (all && !vld_false(exists)) {
    missing <-
      setdiff(to_upper(rws_list_tables(conn)), to_upper(table_names))
    if (length(missing)) {
      err("The following table name%s %r not represented: ",
        cc(missing, " and "), "; but all = TRUE and exists != FALSE.",
        n = length(missing)
      )
    }
  }
  table_names
}
