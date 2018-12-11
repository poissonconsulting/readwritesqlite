validate_data <- function(data, table_name, conn) {
  
  colnames <- to_upper(column_names(table_name, conn = conn))
  data_names <- names(data)
  names(data_names) <- to_upper(names(data))
  names(data) <- to_upper(names(data))
  
  check_colnames(data, colnames = colnames, x_name = p0("data '", table_name, "'"))
  
  data <- data[colnames]
  table_info <- table_info(table_name, conn)
  table_info$name <- to_upper(table_info$name)
  row.names(table_info) <- table_info$name
  table_info <- table_info[colnames,]
  
  table_info$is_na <- vapply(data, any_is_na, TRUE)
  invalid_nas <- table_info$name[table_info$notnull & table_info$is_na]
  if(length(invalid_nas)) {
    err(co(invalid_nas, 
           p0("there are unpermitted missing values in the following ",
           "column%s in data '", table_name, "': %c"), conjunction = "and"))
  }
  
  pk <- table_info$name[table_info$pk != 0L]
  check_key(data, key = pk, x_name = p0("data '", table_name, "'"))
  
  names(data) <- data_names[names(data)]
  data
}
