validate_data <- function(data, table_name, conn) {
  colnames <- to_upper(column_names(table_name, conn = conn))
  data_names <- names(data)
  names(data_names) <- to_upper(names(data))
  names(data) <- to_upper(names(data))

  check_colnames(data, colnames = colnames)

  data <- data[colnames]
  table_info <- table_info(table_name, conn)
  table_info$name <- to_upper(table_info$name)
  row.names(table_info) <- table_info$name
  table_info <- table_info[colnames,]
  
  names(data) <- data_names[names(data)]
  data <- convert_data(data)
  data
}
