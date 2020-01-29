column_names <- function(table_name, conn) {
  DBI::dbListFields(conn, table_name)
}

tables_exists <- function(table_names, conn) {
  tables <- DBI::dbListTables(conn)
  to_upper(table_names) %in% to_upper(tables)
}

get_query <- function(sql, conn) {
  DBI::dbGetQuery(conn, sql)
}

execute <- function(sql, conn) {
  DBI::dbExecute(conn, sql)
}

sql_interpolate <- function(sql, ..., conn) {
  DBI::sqlInterpolate(conn, sql, ...)
}

sql_strip_foreign_keys <- function(sql) {
  sql <- gsub(",\\s*FOREIGN\\s+KEY\\s*\\(\\s*\\w+\\s*(,\\s*\\w+)*\\s*\\)\\s*REFERENCES\\s+\\w+\\s*\\(\\s*\\w+\\s*(,\\s*\\w+)*\\s*\\)", "", sql, ignore.case = TRUE)
}

nrows_table <- function(table_name, conn) {
  sql <- "SELECT COUNT(*) FROM ?table_name;"
  sql <- sql_interpolate(sql, table_name = table_name, conn = conn)
  nrows <- get_query(sql, conn)
  nrows <- nrows[1, 1]
  nrows
}

create_table <- function(data, table_name, log, silent, conn) {
  if (!vld_false(silent)) msg("Creating table '", table_name, "'.")
  DBI::dbCreateTable(conn, table_name, data)
  if (log) log_command(table_name, command = "CREATE", nrow = 0L, conn = conn)
  data
}

drop_table <- function(table_name, conn) {
  sql <- "DROP TABLE IF EXISTS ?table_name;"
  sql <- sql_interpolate(sql, table_name = table_name, conn = conn)
  execute(sql, conn)
}

rename_table <- function(table_name, new_table_name, conn) {
  sql <- "ALTER TABLE ?table_name RENAME TO ?new_table_name;"
  sql <- sql_interpolate(sql,
    table_name = table_name,
    new_table_name = new_table_name, conn = conn
  )
  execute(sql, conn)
}

rename_column <- function(table_name, column_name, new_column_name, conn) {
  sql <- "ALTER TABLE ?table_name RENAME COLUMN ?column_name TO ?new_column_name;"
  sql <- sql_interpolate(sql,
    table_name = table_name,
    column_name = column_name,
    new_column_name = new_column_name, conn = conn
  )
  execute(sql, conn)
}

write_data <- function(data, table_name, replace, meta, log, conn) {
  if (meta) {
    sf_column_name <- sf_column_name(data)
    data <- write_meta_data(data, table_name = table_name, conn = conn)
    write_init_data(table_name, sf_column_name, conn = conn)
  }
  if (nrow(data)) {
    data <- convert_data(data)
    if (replace && nrows_table(table_name, conn)) {
      sql <- table_schema(table_name, conn)
      sql <- sub("CREATE TABLE\\s+\\w+\\s*[(]", "CREATE TEMP TABLE temp (", sql)
      sql <- sql_strip_foreign_keys(sql)
      execute(sql, conn)
      on.exit(drop_table("temp", conn = conn))
      DBI::dbAppendTable(conn, "temp", data)
      sql <- "REPLACE INTO ?table_name SELECT * FROM temp;"
      sql <- sql_interpolate(sql, table_name = table_name, conn = conn)
      nrow1 <- nrows_table(table_name, conn)
      execute(sql, conn)
      nrow2 <- nrows_table(table_name, conn)
      if (log) {
        nrow_insert <- nrow2 - nrow1
        nrow_replace <- nrow(data) - nrow_insert
        if (nrow_replace > 0) {
          log_command(table_name, command = "UPDATE", nrow = nrow_replace, conn = conn)
        }
        if (nrow_insert) {
          log_command(table_name, command = "INSERT", nrow = nrow_insert, conn = conn)
        }
      }
    } else {
      DBI::dbAppendTable(conn, table_name, data)
      if (log) {
        log_command(table_name, command = "INSERT", nrow = nrow(data), conn = conn)
      }
    }
  }
  data
}

delete_data <- function(table_name, meta, log, conn) {
  sql <- "DELETE FROM ?table_name;"
  sql <- sql_interpolate(sql, table_name = table_name, conn = conn)
  nrow <- execute(sql, conn)
  if (log) {
    log_command(table_name, command = "DELETE", nrow = nrow, conn = conn)
  }
  if (meta) {
    delete_init_data_table_name(table_name, conn)
    delete_meta_data_table_name(table_name, conn)
  }
}

read_data <- function(table_name, meta, conn) {
  data <- DBI::dbReadTable(conn, table_name)
  colnames(data) <- column_names(table_name, conn)
  if (meta) {
    data <- read_meta_data(data, table_name, conn)
    data <- read_init_data(data, table_name, conn)
  }
  data
}

query_data <- function(query, meta, conn) {
  data <- get_query(query, conn)
  if (meta) {
    table_names <- query_table_names(query)
    data <- read_meta_data_query(data, table_names, conn)
  }
  data
}

table_schema <- function(table_name, conn) {
  sql <- "SELECT sql FROM sqlite_master WHERE name = ?table_name;"
  sql <- sql_interpolate(sql, table_name = table_name, conn = conn)
  schema <- get_query(sql, conn)[[1]]
  schema
}

table_info <- function(table_name, conn) {
  sql <- p0("PRAGMA table_info('", table_name, "');")
  table_info <- get_query(sql, conn)
  table_info
}

table_column_type <- function(column_name, table_name, conn) {
  table_info <- table_info(table_name, conn)
  table_info$type[to_upper(table_info$name) == to_upper(column_name)]
}

is_table_column_text <- function(column_name, table_name, conn) {
  toupper(table_column_type(column_name, table_name, conn)) == "TEXT"
}

foreign_keys <- function(on, conn) {
  old <- get_query("PRAGMA foreign_keys;", conn)
  old <- as.logical(old[1, 1])

  if (on && !old) {
    execute("PRAGMA foreign_keys = ON;", conn)
  }
  if (!on && old) {
    execute("PRAGMA foreign_keys = OFF;", conn)
  }
  old
}

defer_foreign_keys <- function(on, conn) {
  old <- get_query("PRAGMA defer_foreign_keys;", conn)
  old <- as.logical(old[1, 1])

  if (on && !old) {
    execute("PRAGMA defer_foreign_keys = ON;", conn)
  }
  if (!on && old) {
    execute("PRAGMA defer_foreign_keys = OFF;", conn)
  }
  old
}
