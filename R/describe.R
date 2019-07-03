#' Add Descriptions to SQL Meta Data Table
#'
#' @param x An object specifying the descriptions.
#' @inheritParams rws_write
#' @return An invisible copy of the updated meta table.
#' @family rws_describe_meta
#' @export
rws_describe_meta <- function(x, ..., conn) {
  UseMethod("rws_describe_meta")
}

#' Add Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A character vector of table name(s).
#' @param column A character vector of column name(s).
#' @param description A character vector of the description(s)
#' @inheritParams rws_write
#' 
#' @return An invisible copy of the updated meta table.
#' @family rws_describe_meta
#' @export
#' 
#' @examples 
#' conn <- rws_connect()
#' rws_write(rws_data, exists = FALSE, conn = conn)
#' rws_read_meta(conn)
#' rws_describe_meta("rws_data", "Units", "The site length.", conn = conn)
#' rws_describe_meta("rws_data", "POSIXct", "Time of the visit", conn =conn)
#' rws_read_meta(conn)
#' rws_disconnect(conn)
rws_describe_meta.character <- function(x, column, description, ..., conn) {
  check_vector(x, "")
  check_vector(column, "")
  check_vector(description, c("", NA))
  check_sqlite_connection(conn, connected = TRUE)
  check_unused(...)
  
  rws_describe_meta(data.frame(
    Table = x, Column = column, Description = description, 
    stringsAsFactors = FALSE), conn = conn)
}

#' Add Data Frame of Descriptions to SQL Meta Data Table
#'
#' @inheritParams rws_write
#' @param x A data frame with columns Table, Column, Description.
#' @return An invisible character vector of the previous descriptions.
#' @family rws_read
#' @export
rws_describe_meta.data.frame <- function(x, ..., conn) {
  check_data(x, values = list(Table = "", Column = "", Description = c("", NA)))
  check_sqlite_connection(conn, connected = TRUE)
  check_unused(...)
  
  if(!nrow(x)) return(invisible(rws_read_meta(conn)))
  
  x <- x[c("Table", "Column", "Description")]
  x$Table <- to_upper(x$Table)
  x$Column <- to_upper(x$Column)
  
  if(anyDuplicated(x[c("Table", "Column")])) 
    err("columns 'Table' and 'Column' in data 'x' must be unique")
  
  x$Row <- 1:nrow(x)
  
  meta <- rws_read_meta(conn)
  meta$RowMeta <- 1:nrow(meta)

  meta <- merge(meta, x, by.x = c("TableMeta", "ColumnMeta"), 
                by.y = c("Table", "Column"), all = TRUE)
  
  if(any(is.na(meta$RowMeta))) 
    err("all description tables and columns must exist in the meta table")
  
  meta$DescriptionMeta[!is.na(meta$Row)] <- meta$Description[!is.na(meta$Row)]
  meta <- meta[order(meta$RowMeta),]
  
  meta <- meta[c("TableMeta", "ColumnMeta", "MetaMeta", "DescriptionMeta")]
  
  replace_meta_table(meta, conn = conn)
  invisible(as_tibble_sf(meta))
}
