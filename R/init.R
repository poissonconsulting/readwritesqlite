init_schema <- function () {
  p("CREATE TABLE", .init_table_name, "(
  TableInit TEXT NOT NULL PRIMARY KEY,
  IsInit INTEGER NOT NULL,
  SFInit TEXT,
  CHECK(
    (IsInit >= 0 AND IsInit <= 1) AND
    (SFInit IS NULL OR IsInit == 1)
));")
}

make_init_data <- function(conn) {
  table_names <- rws_list_tables(conn)
  if(!length(table_names)) {
    return(data.frame(TableInit = character(0), IsInit = integer(0), 
                      SFInit = character(0),
                      stringsAsFactors = FALSE))
  }
  is_init <- lapply(table_names, nrows_table, conn = conn)
  is_init <- as.integer(is_init > 0)
  init_data <- data.frame(TableInit = to_upper(table_names), IsInit = is_init, 
                          SFInit = NA_character_, stringsAsFactors = FALSE)
  init_data
}

replace_init_table <- function(init_data, conn) {
  init_data$TableInit <- to_upper(init_data$TableInit)
  init_data$SFInit <- to_upper(init_data$SFInit)
  init_data <- init_data[order(init_data$TableInit),] 
  delete_data(.init_table_name, meta = FALSE, log = FALSE, conn = conn)
  DBI::dbAppendTable(conn, .init_table_name, init_data)
}

delete_init_data_table_name <- function(table_name, conn) {
  confirm_init_table(conn)
  table_name <- to_upper(table_name)
  init_table <- read_data(.init_table_name, meta = FALSE, conn = conn)
  init_table <- init_table[init_table$TableInit != table_name,,drop = FALSE]
  replace_init_table(init_table, conn = conn)
}

confirm_init_table <- function(conn) {
  init_schema <- init_schema()
  if (!tables_exists(.init_table_name, conn)) {
    execute(init_schema, conn)
  } else {
    init_schema <- sub(";$", "", init_schema)
    schema <- table_schema(.init_table_name, conn)
    if(!identical(schema, init_schema))
      err("table '", .init_table_name, "' has an invalid schema")
  }
  init_table <- read_data(.init_table_name, meta = FALSE, conn = conn)
  init_table <- init_table[init_table$IsInit == 1,]
  init_data <- make_init_data(conn)
  if(!nrow(init_data)) return(replace_init_table(init_data, conn))
  if(nrow(init_table)) {
    init_table <- init_table[init_table$TableInit %in% init_data$TableInit,]
    init_data <- init_data[!init_data$TableInit %in% init_table$TableInit,]
    init_data <- rbind(init_table, init_data)
  }
  replace_init_table(init_data, conn) 
}

#' Read Initialization Data table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write
#' @return A data frame of the init table
#' @aliases rws_read_sqlite_init
#' @export
#' @examples
#' conn <- rws_connect()
#' rws_read_init(conn)
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_read_init(conn)
#' rws_disconnect(conn)
rws_read_init <- function(conn) {
  confirm_init_table(conn)
  data <- read_data(.init_table_name, meta = FALSE, conn = conn)
  as_tibble_sf(data)
}

is_initialized <- function(table_name, conn) {
  confirm_init_table(conn)
  init_table <- read_data(.init_table_name, meta = FALSE, conn = conn)
  init_table <- init_table[init_table$TableInit == to_upper(table_name),]
  init_table$IsInit == 1L
}

write_init_data <- function(table_name, sf_column_name, conn) {
  if(is_initialized(table_name, conn)) return(NULL)
  init_table <- read_data(.init_table_name, meta = FALSE, conn = conn)
  init_data <- init_table[init_table$TableInit == to_upper(table_name),]
  init_table <- init_table[init_table$TableInit != to_upper(table_name),]
  init_data$IsInit <- 1L
  init_data$SFInit <- sf_column_name
  init_data <- rbind(init_table, init_data)
  replace_init_table(init_data, conn) 
  NULL
}

read_init_data <- function(data, table_name, conn) {
  confirm_init_table(conn)
  init_table <- read_data(.init_table_name, meta = FALSE, conn = conn)
  sf_column_name <- init_table$SFInit[init_table$TableInit == to_upper(table_name)]
  if(is.na(sf_column_name)) return(data)
  sf_column_name <- names(data)[to_upper(names(data)) == sf_column_name]
  sf::st_sf(data, sf_column_name = sf_column_name, 
            stringsAsFactors = FALSE, sfc_last = FALSE)
}
