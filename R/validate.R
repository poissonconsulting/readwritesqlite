validate_data <- function(data, table_name, conn) {
  colnames <- column_names(table_name, conn = conn)
  check_colnames(data, colnames = colnames)
  data <- data[colnames]
  # need to add more data checking here
  
  data <- convert_data(data)
  data
}
