sf_schema <- function () {
  p("CREATE TABLE", .sf_table_name, "(
  TableSF TEXT NOT NULL PRIMARY KEY,
  ColumnSF TEXT NOT NULL,
  FOREIGN KEY (TableSF, ColumnSF) REFERENCES ", .meta_table_name, " (TableMeta, ColumnMeta) ON DELETE CASCADE);")
}

confirm_sf_table <- function(conn) {
  sf_schema <- sf_schema()
  if (!tables_exists(.sf_table_name, conn)) {
    dbExecute(conn, sf_schema)
  } else {
    sf_schema <- sub(";$", "", sf_schema)
    schema <- table_schema(.sf_table_name, conn)
    if(!identical(schema, sf_schema))
      err("table '", .sf_table_name, "' has an invalid schema")
  }
}

replace_sf_table <- function(sf_data, conn) {
  sf_data$TableSF <- to_upper(sf_data$TableSF)
  sf_data$ColumnSF <- to_upper(sf_data$ColumnSF)
  delete_data(.sf_table_name, meta = FALSE, log = FALSE, conn = conn)
  sf_data <- sf_data[order(sf_data$TableSF, sf_data$ColumnSF),] 
  write_data(sf_data, .sf_table_name, meta = FALSE, log = FALSE, conn = conn)
}

write_sf_column <- function(data, table_name, conn) {
  confirm_sf_table(conn)
  if(!is.sf(data)) return(data)
  sf_table <- read_data(.sf_table_name, meta = FALSE, conn = conn)
  sf_table <- sf_table[sf_table$TableSF != to_upper(table_name),,drop = FALSE]
  new_row <- data.frame(TableSF = table_name, ColumnSF = sf_column_name(data))
  sf_table <- rbind(sf_table, new_row, stringsAsFactors = FALSE)
  replace_sf_table(sf_table, conn = conn)
  data
}

read_sf_column <- function(data, table_name, conn) {
  confirm_sf_table(conn)
  sf_table <- read_data(.sf_table_name, meta = FALSE, conn = conn)
  sf_table <- sf_table[sf_table$TableSF == to_upper(table_name),,drop = FALSE]
  if(!nrow(sf_table)) return(data)
  sf_column_name <- names(data)[to_upper(names(data)) == sf_table$ColumnSF]
  sf::st_sf(data, sf_column_name = sf_column_name, 
                    stringsAsFactors = FALSE)
}
