check_data_sqlite <- function(data, table_name, conn, convert = FALSE) {
  check_data(data)
  check_string(table_name)
  check_inherits(conn, "SQLiteConnection")
  check_flag(convert)

  if(table_name %in% c("dbWriteSQLiteLog"))
    err("'dbWriteSQLiteLog' is a reserved table name")

  if (!dbExistsTable(conn, table_name))
    err("table '", table_name, "' does not exist")

  colnames <- dbListFields(conn, table_name)

  check_colnames(data, colnames = colnames)
  data <- data[colnames]

  data2 <- as.data.frame(data)
  data2 <- convert_data(data2)
  if(convert) return(data2)
  data
}
