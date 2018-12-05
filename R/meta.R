meta_schema <- function () {
  p("CREATE TABLE", .meta_table_name, "(
  TableMeta TEXT NOT NULL,
  ColumnMeta TEXT NOT NULL,
  MetaMeta TEXT,
  DescriptionMeta TEXT,
  PRIMARY KEY(TableMeta, ColumnMeta)
);")
}

make_meta_data <- function(conn) {
  table_names <- table_names(conn)
  if(!length(table_names)) 
    return(data.frame(TableMeta = character(0), ColumnMeta = character(0),
                      stringsAsFactors = FALSE))
  meta_data <- lapply(table_names, column_names, conn = conn)
  meta_data <- mapply(function(x, y) 
    data.frame(TableMeta = y, ColumnMeta = x, stringsAsFactors = FALSE), 
    meta_data, table_names, SIMPLIFY = FALSE)
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
  write_data(meta_data, .meta_table_name, meta = FALSE, log = FALSE, conn = conn)
}

confrm_meta_table <- function(conn) {
  meta_schema <- meta_schema()
  if (!tables_exists(.meta_table_name, conn)) {
    dbExecute(conn, meta_schema)
  } else {
    meta_schema <- sub(";$", "", meta_schema)
    schema <- table_schema(.meta_table_name, conn)
    if(!identical(schema, meta_schema))
      err("table '", .meta_table_name, "' has an invalid schema")
  }
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_data <- make_meta_data(conn)
  meta_data <- merge(meta_data, meta_table, all.x = TRUE,
                     by = c("TableMeta", "ColumnMeta"))
  replace_meta_table(meta_data, conn) 
}

#' Read Meta Data table from SQLite Database
#'
#' The table is created if it doesn't exist.
#'
#' @inheritParams rws_write_sqlite
#' @return A data frame of the meta table
#' @export
#' @examples
#' con <- DBI::dbConnect(RSQLite::SQLite())
#' rws_read_sqlite_meta(con)
#' DBI::dbDisconnect(con)
rws_read_sqlite_meta <- function(conn = getOption("rws.conn", NULL)) {
  confrm_meta_table(conn)
  data <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  as_conditional_tibble(data)
}

delete_meta_data <- function(table_name, conn) {
  confrm_meta_table(conn)
  table_name <- to_upper(table_name)
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta != table_name,,drop = FALSE]
  replace_meta_table(meta_table, conn = conn)
}

data_column_has_meta <- function(x) {
  is.logical(x) || dttr::is.Date(x) || dttr::is.POSIXct(x) 
}

meta_has_meta <- function(table_name, conn) {
  table_name <- to_upper(table_name)
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta == table_name,,drop = FALSE]
  has_meta <- !is.na(meta_table$MetaMeta)
  
  data <- read_data(table_name, meta = FALSE, conn = conn)
  if(!nrow(data)) has_meta[!has_meta] <- NA
  names(has_meta) <- meta_table$ColumnMeta
  data_names <- to_upper(names(data))
  has_meta <- has_meta[data_names]
  names(has_meta) <- names(data)
  has_meta
}

data_column_meta <- function(x) {
  if (is.logical(x)) return("class: logical")
  if (is.Date(x)) return("class: Date")
  if (is.POSIXct(x)) return(p("tz:", dttr::dtt_tz(x)))
  stop("unrecognized meta type")
}

meta_column_meta <- function(column_name, table_name, conn) {
  column_name <- to_upper(column_name)
  table_name <- to_upper(table_name)
  
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta == table_name,]
  meta_table <- meta_table[meta_table$ColumnMeta == column_name,]
  meta_table$MetaMeta
}

meta_data_column <- function (column_name, data, table_name, conn) {
  data_column <- data[[column_name]]
  data_column_meta <- data_column_meta(data_column)
  meta_column_meta <- meta_column_meta(column_name, table_name, conn)
  
  print(data_column_meta)
  print(meta_column_meta)
  if(is.na(meta_column_meta)) {
    meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
    row <- meta_table$TableMeta == to_upper(table_name) & 
      meta_table$ColumnMeta == to_upper(column_name)
    meta_table$MetaMeta[row] <- data_column_meta
    replace_meta_table(meta_table, conn = conn)
  } else if(!identical(data_column_meta, meta_column_meta)) {
    err(p0("data meta '", data_column_meta, "' for column '", column_name, 
           "' in table '", table_name, "' is inconsistent with meta '", 
           meta_column_meta, "'"))
  }
  column_name
}

write_meta_data <- function(data, table_name, conn) {
  confrm_meta_table(conn)
  data_has_meta <- vapply(data, FUN = data_column_has_meta, FUN.VALUE = TRUE)
  meta_has_meta <- meta_has_meta(table_name, conn)
  
  meta_mismatch <- !is.na(meta_has_meta) & data_has_meta != meta_has_meta
  if(any(meta_mismatch)) {
    columns <- names(meta_mismatch[meta_mismatch])
    err(co(columns, p0("the following column%s in table '", table_name, 
                       "' have inconsistent meta data: %c")))
  }
  if(!any(data_has_meta)) return(data)
  
  columns <- names(data)[data_has_meta]
  lapply(columns, meta_data_column, data = data, 
         table_name = table_name, conn = conn)
  data
}

read_meta_data <- function(data, table_name, conn) {
  data
}
