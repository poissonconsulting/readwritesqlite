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
  meta_data <- meta_data[order(meta_data$TableMeta, meta_data$ColumnMeta),] 
  write_data(meta_data, .meta_table_name, meta = FALSE, log = FALSE, conn = conn)
}

confirm_meta_table <- function(conn) {
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
  confirm_meta_table(conn)
  data <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  as_conditional_tibble(data)
}

data_column_meta <- function(column) {
  if (is.logical(column)) return("class: logical")
  if (is.Date(column)) return("class: Date")
  if (is.POSIXct(column)) return(p("tz:", dttr::dtt_tz(column)))
  if (is.sfc(column)) return(p("proj:", sf::st_crs(column)$proj4string))
  if (is.units(column)) return(p("units:", units::deparse_unit(column)))
  NA_character_
}

read_meta_data_column <- function(column, meta) {
  if(grepl("^class:\\s*logical$", meta)) {
    column <- as.double(column)
    return(as.logical(column))
  }
  if(grepl("^class:\\s* Date$", meta)) return(dttr::dtt_date(column))
  if(grepl("^tz:", meta)) {
    tz <- sub("(^tz:\\s*)(.*)", "\\2", meta)
    return(dttr::dtt_date_time(column, tz = tz))
  } 
  if(grepl("^units:", meta)) {
    units <- sub("(^units:\\s*)(.*)", "\\2", meta)
    column <- as.double(column)
    return(units::as_units(column, units))
  }
 if(grepl("^proj:", meta)) {
   proj <- sub("(^proj:\\s*)(.*)", "\\2", meta)
   return(sf::st_set_crs(sf::st_as_sfc(column), proj))
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
  meta_table <- meta_table[meta_table$TableMeta != table_name,,drop = FALSE]
  replace_meta_table(meta_table, conn = conn)
}

meta_table_meta <- function(table_name, conn) {
  table_name <- to_upper(table_name)
  
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table <- meta_table[meta_table$TableMeta == table_name,]
  meta_table_meta <- meta_table$MetaMeta
  names(meta_table_meta) <- meta_table$ColumnMeta
  meta_table_meta
}

write_meta_data_column <- function (column, column_name, table_name, conn) {
  meta <- data_column_meta(column)
  column_name <- to_upper(column_name)
  table_name <- to_upper(table_name)
  
  meta_table <- read_data(.meta_table_name, meta = FALSE, conn = conn)
  meta_table$MetaMeta[meta_table$TableMeta == table_name & 
                        meta_table$ColumnMeta == column_name] <- meta
  replace_meta_table(meta_table, conn = conn)
  
  if(grepl("^class: logical", meta))
    return(as.integer(column))
  if(grepl("^class: Date", meta))
    return(as.character(column))
  if(grepl("^tz:", meta))
    return(as.character(column))
  if(grepl("^units:", meta))
    return(as.double(column))
  if(grepl("^proj:", meta))
    return(sf::st_as_binary(column, endian = "little"))
  
  column
}

validate_data_meta <- function(data, table_name, conn) {
  confirm_meta_table(conn)
  data_meta <- data_meta(data)
  meta <- meta_table_meta(table_name, conn)[to_upper(names(data_meta))]
  
  data_meta[is.na(data_meta)] <- "No"
  if(nrows_table(table_name, conn)) meta[is.na(meta)] <- "No"
  
  mismatch <- !is.na(meta) & data_meta != meta
  if(any(mismatch)) {
    wch <- which(mismatch)[1]
    data_meta <- data_meta[wch]
    meta <- meta[wch]
    column_name <- names(data_meta)
    
    err("column '", column_name, "' in table '", table_name, 
        "' has '", data_meta, "' meta data for the input data", 
        " but '", meta, "' for the existing data")
  }
  data_meta[data_meta != "No"]
}

write_meta_data <- function(data, table_name, conn) {
  data_meta <- validate_data_meta(data, table_name, conn)
  
  if(!length(data_meta)) return(data)
  
  column_names <- names(data_meta)
  
  data[column_names] <- 
    mapply(FUN = write_meta_data_column, data[column_names], column_names, 
           MoreArgs = list(table_name = table_name, conn = conn), SIMPLIFY = FALSE)
  data
}

read_meta_data <- function(data, table_name, conn) {
  confirm_meta_table(conn)
  meta <- meta_table_meta(table_name, conn)
  
  meta <- meta[to_upper(names(data))]
  names(meta) <- names(data)
  
  meta <- meta[!is.na(meta)]
  if(!length(meta)) return(data)
  
  data[names(meta)] <- mapply(FUN = read_meta_data_column, data[names(meta)], 
                              meta, SIMPLIFY = FALSE)
  data
}
